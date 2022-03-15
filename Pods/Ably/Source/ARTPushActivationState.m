#import "ARTPushActivationState.h"
#import "ARTPushActivationStateMachine+Private.h"
#import "ARTPushActivationEvent.h"
#import "ARTLocalDevice+Private.h"
#import "ARTDeviceStorage.h"
#import "ARTDevicePushDetails.h"
#import "ARTLog.h"
#import "ARTRest+Private.h"
#import "ARTAuth+Private.h"
#import "ARTHttp.h"

@implementation ARTPushActivationState

- (instancetype)initWithMachine:(ARTPushActivationStateMachine *)machine {
    if (self = [super init]) {
        _machine = machine;
    }
    return self;
}

+ (instancetype)newWithMachine:(ARTPushActivationStateMachine *)machine {
    return [[self alloc] initWithMachine:machine];
}

- (void)logEventTransition:(ARTPushActivationEvent *)event file:(const char *)file line:(NSUInteger)line {
    [self.machine.rest.logger debug:@"ARTPush Activation: %@ state: handling %@ event", NSStringFromClass(self.class), NSStringFromClass(event.class)];
}

- (ARTPushActivationState *)transition:(ARTPushActivationEvent *)event {
    NSAssert(false, @"-[%s:%d %s] should always be overriden; class %@ doesn't.", __FILE__, __LINE__, __FUNCTION__, NSStringFromClass(self.class));
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    // Implement NSCopying by retaining the original instead of creating a new copy when the class and its contents are immutable.
    return self;
}

#pragma mark - NSCoding

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    // Just to persist the class info, no properties
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return true;
}

#pragma mark - Archive/Unarchive

- (NSData *)archive {
    return [self art_archive];
}

+ (ARTPushActivationState *)unarchive:(NSData *)data {
    return [self art_unarchiveFromData:data];
}

@end

#pragma mark - Persistent State

@implementation ARTPushActivationPersistentState
@end

#pragma mark - Activation States

ARTPushActivationState *validateAndSync(ARTPushActivationStateMachine *machine, ARTPushActivationEvent *event) {
    #if TARGET_OS_IOS
    ARTLocalDevice *const local = machine.rest.device_nosync;

    if (local.identityTokenDetails) {
        // Already registered.
        NSString *const instanceClientId = machine.rest.auth.clientId_nosync;
        if (local.clientId != nil && instanceClientId && ![local.clientId isEqualToString:instanceClientId]) {
            ARTErrorInfo *const error = [ARTErrorInfo createWithCode:61002 message:@"Activation failed: present clientId is not compatible with existing device registration"];
            [machine sendEvent:[ARTPushActivationEventSyncRegistrationFailed newWithError:error]];
        } else {
            [machine syncDevice];
        }
        
        return [ARTPushActivationStateWaitingForRegistrationSync newWithMachine:machine fromEvent:event];
    } else if ([local apnsDeviceToken]) {
        [machine sendEvent:[ARTPushActivationEventGotPushDeviceDetails new]];
    }
    #endif

    return [ARTPushActivationStateWaitingForPushDeviceDetails newWithMachine:machine];
}

@implementation ARTPushActivationStateNotActivated

- (ARTPushActivationState *)transition:(ARTPushActivationEvent *)event {
    [self logEventTransition:event file:__FILE__ line:__LINE__];
    if ([event isKindOfClass:[ARTPushActivationEventCalledDeactivate class]]) {
        [self.machine callDeactivatedCallback:nil];
        return self;
    }
    else if ([event isKindOfClass:[ARTPushActivationEventCalledActivate class]]) {
        return validateAndSync(self.machine, event);
    }
    return nil;
}

@end

@implementation ARTPushActivationStateWaitingForDeviceRegistration

- (ARTPushActivationState *)transition:(ARTPushActivationEvent *)event {
    [self logEventTransition:event file:__FILE__ line:__LINE__];
    if ([event isKindOfClass:[ARTPushActivationEventCalledActivate class]]) {
        return self;
    }
    else if ([event isKindOfClass:[ARTPushActivationEventGotDeviceRegistration class]]) {
        #if TARGET_OS_IOS
        ARTPushActivationEventGotDeviceRegistration *gotDeviceRegistrationEvent = (ARTPushActivationEventGotDeviceRegistration *)event;
        ARTLocalDevice *local = self.machine.rest.device_nosync;
        [local setAndPersistIdentityTokenDetails:gotDeviceRegistrationEvent.identityTokenDetails];
        #endif
        [self.machine callActivatedCallback:nil];
        return [ARTPushActivationStateWaitingForNewPushDeviceDetails newWithMachine:self.machine];
    }
    else if ([event isKindOfClass:[ARTPushActivationEventGettingDeviceRegistrationFailed class]]) {
        [self.machine callActivatedCallback:[(ARTPushActivationEventGettingDeviceRegistrationFailed *)event error]];
        return [ARTPushActivationStateNotActivated newWithMachine:self.machine];
    }
    return nil;
}

@end

@implementation ARTPushActivationStateWaitingForPushDeviceDetails

- (ARTPushActivationState *)transition:(ARTPushActivationEvent *)event {
    [self logEventTransition:event file:__FILE__ line:__LINE__];
    if ([event isKindOfClass:[ARTPushActivationEventCalledActivate class]]) {
        return [ARTPushActivationStateWaitingForPushDeviceDetails newWithMachine:self.machine];
    }
    else if ([event isKindOfClass:[ARTPushActivationEventCalledDeactivate class]]) {
        [self.machine callDeactivatedCallback:nil];
        return [ARTPushActivationStateNotActivated newWithMachine:self.machine];
    }
    else if ([event isKindOfClass:[ARTPushActivationEventGotPushDeviceDetails class]]) {
        [self.machine deviceRegistration:nil];
        return [ARTPushActivationStateWaitingForDeviceRegistration newWithMachine:self.machine];
    }
    else if ([event isKindOfClass:[ARTPushActivationEventGettingPushDeviceDetailsFailed class]]) {
        [self.machine callActivatedCallback:((ARTPushActivationEventGettingPushDeviceDetailsFailed *) event).error];
        return [ARTPushActivationStateNotActivated newWithMachine:self.machine];
    }
    return nil;
}

@end

@implementation ARTPushActivationStateWaitingForNewPushDeviceDetails

- (ARTPushActivationState *)transition:(ARTPushActivationEvent *)event {
    [self logEventTransition:event file:__FILE__ line:__LINE__];
    if ([event isKindOfClass:[ARTPushActivationEventCalledActivate class]]) {
        [self.machine callActivatedCallback:nil];
        return self;
    }
    else if ([event isKindOfClass:[ARTPushActivationEventCalledDeactivate class]]) {
        [self.machine deviceUnregistration:nil];
        return [ARTPushActivationStateWaitingForDeregistration newWithMachine:self.machine];
    }
    else if ([event isKindOfClass:[ARTPushActivationEventGotPushDeviceDetails class]]) {
        [self.machine deviceUpdateRegistration:nil];
        return [ARTPushActivationStateWaitingForRegistrationSync newWithMachine:self.machine fromEvent:event];
    }
    return nil;
}

@end

@implementation ARTPushActivationStateWaitingForRegistrationSync {
    ARTPushActivationEvent *_fromEvent;
}

- (instancetype)initWithMachine:(ARTPushActivationStateMachine *)machine fromEvent:(ARTPushActivationEvent *)event {
    if (self = [super initWithMachine:machine]) {
        _fromEvent = event;
    }
    return self;
}

+ (instancetype)newWithMachine:(ARTPushActivationStateMachine *)machine fromEvent:(ARTPushActivationEvent *)event {
    return [[self alloc] initWithMachine:machine fromEvent:event];
}

- (ARTPushActivationState *)transition:(ARTPushActivationEvent *)event {
    [self logEventTransition:event file:__FILE__ line:__LINE__];
    if ([event isKindOfClass:[ARTPushActivationEventCalledActivate class]] && ![_fromEvent isKindOfClass:[ARTPushActivationEventCalledActivate class]]) {
        [self.machine callActivatedCallback:nil];
        return self;
    }
    else if ([event isKindOfClass:[ARTPushActivationEventRegistrationSynced class]]) {
        #if TARGET_OS_IOS
        ARTPushActivationEventRegistrationSynced *registrationUpdatedEvent = (ARTPushActivationEventRegistrationSynced *)event;
        if (registrationUpdatedEvent.identityTokenDetails) {
            ARTLocalDevice *local = self.machine.rest.device_nosync;
            [local setAndPersistIdentityTokenDetails:registrationUpdatedEvent.identityTokenDetails];
        }
        #endif

        if ([_fromEvent isKindOfClass:[ARTPushActivationEventCalledActivate class]]) {
            [self.machine callActivatedCallback:nil];
        }

        return [ARTPushActivationStateWaitingForNewPushDeviceDetails newWithMachine:self.machine];
    }
    else if ([event isKindOfClass:[ARTPushActivationEventSyncRegistrationFailed class]]) {
        ARTErrorInfo *const error = [(ARTPushActivationEventSyncRegistrationFailed *)event error];
        if ([_fromEvent isKindOfClass:[ARTPushActivationEventCalledActivate class]]) {
            [self.machine callActivatedCallback:error];
        } else {
            [self.machine callUpdateFailedCallback:error];
        }

        return [ARTPushActivationStateAfterRegistrationSyncFailed newWithMachine:self.machine];
    }
    return nil;
}

@end

@implementation ARTPushActivationStateAfterRegistrationSyncFailed

- (ARTPushActivationState *)transition:(ARTPushActivationEvent *)event {
    [self logEventTransition:event file:__FILE__ line:__LINE__];
    if ([event isKindOfClass:[ARTPushActivationEventCalledActivate class]] ||
        [event isKindOfClass:[ARTPushActivationEventGotPushDeviceDetails class]]) {

        return validateAndSync(self.machine, event);
    }
    else if ([event isKindOfClass:[ARTPushActivationEventCalledDeactivate class]]) {
        [self.machine deviceUnregistration:nil];
        return [ARTPushActivationStateWaitingForDeregistration newWithMachine:self.machine];
    }
    return nil;
}

@end

@implementation ARTPushActivationStateWaitingForDeregistration

- (ARTPushActivationState *)transition:(ARTPushActivationEvent *)event {
    [self logEventTransition:event file:__FILE__ line:__LINE__];
    if ([event isKindOfClass:[ARTPushActivationEventCalledDeactivate class]]) {
        return [ARTPushActivationStateWaitingForDeregistration newWithMachine:self.machine];
    }
    else if ([event isKindOfClass:[ARTPushActivationEventDeregistered class]]) {
        #if TARGET_OS_IOS
        ARTLocalDevice *local = self.machine.rest.device_nosync;
        [local setAndPersistIdentityTokenDetails:nil];
        #endif
        [self.machine callDeactivatedCallback:nil];
        return [ARTPushActivationStateNotActivated newWithMachine:self.machine];
    }
    else if ([event isKindOfClass:[ARTPushActivationEventDeregistrationFailed class]]) {
        [self.machine callDeactivatedCallback:[(ARTPushActivationEventDeregistrationFailed *)event error]];
        return [ARTPushActivationStateWaitingForDeregistration newWithMachine:self.machine];
    }
    return nil;
}

@end

@implementation ARTPushActivationDeprecatedPersistentState

- (ARTPushActivationPersistentState *)migrate {
    NSAssert(false, @"must be implemented by subclass");
    return nil;
}

@end

@implementation ARTPushActivationStateAfterRegistrationUpdateFailed

- (ARTPushActivationPersistentState *)migrate {
    return [[ARTPushActivationStateAfterRegistrationSyncFailed alloc] initWithMachine:self.machine];
}

@end
