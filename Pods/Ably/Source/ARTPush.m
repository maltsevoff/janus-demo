#import "ARTPush+Private.h"
#import "ARTDeviceDetails.h"
#import "ARTDevicePushDetails.h"
#import "ARTRest+Private.h"
#import "ARTLog.h"
#import "ARTJsonEncoder.h"
#import "ARTJsonLikeEncoder.h"
#import "ARTEventEmitter.h"
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#import "ARTPushActivationStateMachine+Private.h"
#endif
#import "ARTPushAdmin.h"
#import "ARTPushActivationEvent.h"
#import "ARTClientOptions+Private.h"
#import "ARTPushAdmin+Private.h"
#import "ARTLocalDevice+Private.h"
#import "ARTDeviceStorage.h"
#import "ARTRealtime+Private.h"

@implementation ARTPush {
    ARTQueuedDealloc *_dealloc;
}

- (instancetype)initWithInternal:(ARTPushInternal *)internal queuedDealloc:(ARTQueuedDealloc *)dealloc {
    self = [super init];
    if (self) {
        _internal = internal;
        _dealloc = dealloc;
    }
    return self;
}

- (ARTPushAdmin *)admin {
    return [[ARTPushAdmin alloc] initWithInternal:_internal.admin queuedDealloc:_dealloc];
}

#if TARGET_OS_IOS

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken rest:(ARTRest *)rest; {
    return [ARTPushInternal didRegisterForRemoteNotificationsWithDeviceToken:deviceToken rest:rest];
}

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken realtime:(ARTRealtime *)realtime; {
    return [ARTPushInternal didRegisterForRemoteNotificationsWithDeviceToken:deviceToken realtime:realtime];
}

+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error rest:(ARTRest *)rest; {
    return [ARTPushInternal didFailToRegisterForRemoteNotificationsWithError:error rest:rest];
}

+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error realtime:(ARTRealtime *)realtime; {
    return [ARTPushInternal didFailToRegisterForRemoteNotificationsWithError:error realtime:realtime];
}

- (void)activate {
    [_internal activate];
}

- (void)deactivate {
    [_internal deactivate];
}

#endif

@end

NSString *const ARTDeviceIdKey = @"ARTDeviceId";
NSString *const ARTDeviceSecretKey = @"ARTDeviceSecret";
NSString *const ARTDeviceIdentityTokenKey = @"ARTDeviceIdentityToken";
NSString *const ARTAPNSDeviceTokenKey = @"ARTAPNSDeviceToken";

@implementation ARTPushInternal {
    __weak ARTRestInternal *_rest; // weak because rest owns self
    ARTLog *_logger;
    ARTPushActivationStateMachine *_activationMachine;
    NSLock *_activationMachineLock;
}

- (instancetype)init:(ARTRestInternal *)rest {
    if (self = [super init]) {
        _rest = rest;
        _logger = [rest logger];
        _admin = [[ARTPushAdminInternal alloc] initWithRest:rest];
        _activationMachine = nil;
        _activationMachineLock = [[NSLock alloc] init];
        _activationMachineLock.name = @"ActivationMachineLock";
    }
    return self;
}

- (dispatch_queue_t)queue {
    return _rest.queue;
}

#if TARGET_OS_IOS

- (void)getActivationMachine:(void (^)(ARTPushActivationStateMachine *const))block {
    if (!block) {
        [NSException raise:NSInvalidArgumentException
                    format:@"block is nil."];
    }

    if (![_activationMachineLock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:60]]) {
        block(nil);
        return;
    }

    void (^callbackWithUnlock)(ARTPushActivationStateMachine *const machine) = ^(ARTPushActivationStateMachine *machine) {
        [self->_activationMachineLock unlock];
        block(machine);
    };

    if (_activationMachine == nil) {
        const id<ARTPushRegistererDelegate, NSObject> delegate = _rest.options.pushRegistererDelegate;
        if (delegate) {
            callbackWithUnlock([self createActivationStateMachineWithDelegate:delegate]);
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                // -[UIApplication delegate] is an UI API call, so needs to be called from main thread.
                const id legacyDelegate = UIApplication.sharedApplication.delegate;
                [self createActivationStateMachineWithDelegate:legacyDelegate
                                             completionHandler:^(ARTPushActivationStateMachine *const machine) {
                    callbackWithUnlock(machine);
                }];
            });
        }
    }
    else {
        callbackWithUnlock(_activationMachine);
    }
}

- (void)createActivationStateMachineWithDelegate:(const id<ARTPushRegistererDelegate, NSObject>)delegate
                               completionHandler:(void (^const)(ARTPushActivationStateMachine *_Nonnull))block {
    dispatch_async(self.queue, ^{
        block([self createActivationStateMachineWithDelegate:delegate]);
    });
}

- (ARTPushActivationStateMachine *)createActivationStateMachineWithDelegate:(const id<ARTPushRegistererDelegate, NSObject>)delegate {
    if (_activationMachine) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"_activationMachine already set."];
    }
    
    _activationMachine = [[ARTPushActivationStateMachine alloc] initWithRest:self->_rest delegate:delegate];
    return _activationMachine;
}

- (ARTPushActivationStateMachine *)activationMachine {
    if (![_activationMachineLock tryLock]) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Failed to immediately acquire lock for internal testing purposes."];
    }
    
    ARTPushActivationStateMachine *const machine = _activationMachine;
    if (!machine) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"There is no activation machine for internal testing purposes."];
    }
    
    [_activationMachineLock unlock];
    
    return machine;
}

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceTokenData restInternal:(ARTRestInternal *)rest {
    [rest.logger debug:@"ARTPush: device token data received: %@", [deviceTokenData base64EncodedStringWithOptions:0]];

    NSUInteger dataLength = deviceTokenData.length;
    const unsigned char *dataBuffer = deviceTokenData.bytes;
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendFormat:@"%02x", dataBuffer[i]];
    }

    NSString *deviceToken = [hexString copy];

    [rest.logger info:@"ARTPush: device token: %@", deviceToken];
    NSString *currentDeviceToken = [rest.storage objectForKey:ARTAPNSDeviceTokenKey];
    if ([currentDeviceToken isEqualToString:deviceToken]) {
        // Already stored.
        return;
    }

    [rest.device_nosync setAndPersistAPNSDeviceToken:deviceToken];
    [rest.logger debug:@"ARTPush: device token stored"];
    [rest.push getActivationMachine:^(ARTPushActivationStateMachine *stateMachine) {
        [stateMachine sendEvent:[ARTPushActivationEventGotPushDeviceDetails new]];
    }];
}

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken realtime:(ARTRealtime *)realtime {
    [realtime internalAsync:^(ARTRealtimeInternal *realtime) {
        [ARTPushInternal didRegisterForRemoteNotificationsWithDeviceToken:deviceToken restInternal:realtime.rest];
    }];
}

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken rest:(ARTRest *)rest {
    [rest internalAsync:^(ARTRestInternal *rest) {
        [ARTPushInternal didRegisterForRemoteNotificationsWithDeviceToken:deviceToken restInternal:rest];
    }];
}

+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error restInternal:(ARTRestInternal *)rest {
    [rest.logger error:@"ARTPush: device token not received (%@)", [error localizedDescription]];
    [rest.push getActivationMachine:^(ARTPushActivationStateMachine *stateMachine) {
        [stateMachine sendEvent:[ARTPushActivationEventGettingPushDeviceDetailsFailed newWithError:[ARTErrorInfo createFromNSError:error]]];
    }];
}

+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error realtime:(ARTRealtime *)realtime {
    [realtime internalAsync:^(ARTRealtimeInternal *realtime) {
        [ARTPushInternal didFailToRegisterForRemoteNotificationsWithError:error restInternal:realtime.rest];
    }];
}

+ (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error rest:(ARTRest *)rest {
    [rest internalAsync:^(ARTRestInternal *rest) {
        [ARTPushInternal didFailToRegisterForRemoteNotificationsWithError:error restInternal:rest];
    }];
}

- (void)activate {
    [self getActivationMachine:^(ARTPushActivationStateMachine *stateMachine) {
        [stateMachine sendEvent:[ARTPushActivationEventCalledActivate new]];
    }];
}

- (void)deactivate {
    [self getActivationMachine:^(ARTPushActivationStateMachine *stateMachine) {
        [stateMachine sendEvent:[ARTPushActivationEventCalledDeactivate new]];
    }];
}

#endif

@end
