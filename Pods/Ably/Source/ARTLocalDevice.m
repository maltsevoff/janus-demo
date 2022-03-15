#import "ARTLocalDevice+Private.h"
#import "ARTDevicePushDetails.h"
#import "ARTPush.h"
#import "ARTEncoder.h"
#import "ARTDeviceStorage.h"
#import "ARTDeviceIdentityTokenDetails.h"
#import "ARTCrypto+Private.h"

NSString *const ARTDevicePlatform = @"ios";

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
NSString *const ARTDeviceFormFactor = @"phone";
#elif TARGET_OS_TV
NSString *const ARTDeviceFormFactor = @"tv";
#elif TARGET_OS_WATCH
NSString *const ARTDeviceFormFactor = @"watch";
#elif TARGET_OS_SIMULATOR
NSString *const ARTDeviceFormFactor = @"simulator";
#elif TARGET_OS_MAC
NSString *const ARTDeviceFormFactor = @"desktop";
#else
NSString *const ARTDeviceFormFactor = @"embedded";
#endif

NSString *const ARTDevicePushTransportType = @"apns";

@implementation ARTLocalDevice

- (instancetype)initWithClientId:(NSString *)clientId storage:(id<ARTDeviceStorage>)storage {
    if (self = [super init]) {
        self.clientId = clientId;
        self.storage = storage;
    }
    return self;
}

+ (ARTLocalDevice *)load:(NSString *)clientId storage:(id<ARTDeviceStorage>)storage {
    ARTLocalDevice *device = [[ARTLocalDevice alloc] initWithClientId:clientId storage:storage];
    device.platform = ARTDevicePlatform;
    #if TARGET_OS_IOS
    switch ([[UIDevice currentDevice] userInterfaceIdiom]) {
        case UIUserInterfaceIdiomPad:
            device.formFactor = @"tablet";
        case UIUserInterfaceIdiomCarPlay:
            device.formFactor = @"car";
        default:
            device.formFactor = ARTDeviceFormFactor;
    }
    #else
    device.formFactor = ARTDeviceFormFactor;
    #endif
    device.push.recipient[@"transportType"] = ARTDevicePushTransportType;

    NSString *deviceId = [storage objectForKey:ARTDeviceIdKey];
    NSString *deviceSecret = deviceId == nil ? nil : [storage secretForDevice:deviceId];
    
    if (deviceId == nil || deviceSecret == nil) { // generate both at the same time
        deviceId = [self generateId];
        deviceSecret = [self generateSecret];
        
        [storage setObject:deviceId forKey:ARTDeviceIdKey];
        [storage setSecret:deviceSecret forDevice:deviceId];
    }
    
    device.id = deviceId;
    device.secret = deviceSecret;

    id identityTokenDetailsInfo = [storage objectForKey:ARTDeviceIdentityTokenKey];
    ARTDeviceIdentityTokenDetails *identityTokenDetails = [ARTDeviceIdentityTokenDetails unarchive:identityTokenDetailsInfo];
    device->_identityTokenDetails = identityTokenDetails;

    [device setAPNSDeviceToken:[storage objectForKey:ARTAPNSDeviceTokenKey]];

    return device;
}

+ (NSString *)generateId {
    return [NSUUID new].UUIDString;
}

+ (NSString *)generateSecret {
    NSData *randomData = [ARTCrypto generateSecureRandomData:32];
    NSData *hash = [ARTCrypto generateHashSHA256:randomData];
    return [hash base64EncodedStringWithOptions:0];
}

- (NSString *)apnsDeviceToken {
    return self.push.recipient[@"deviceToken"];
}

- (void)setAPNSDeviceToken:(NSString *_Nonnull)token {
    self.push.recipient[@"deviceToken"] = token;
}

- (void)setAndPersistAPNSDeviceToken:(NSString *)token {
    [self.storage setObject:token forKey:ARTAPNSDeviceTokenKey];
    [self setAPNSDeviceToken:token];
}

- (void)setAndPersistIdentityTokenDetails:(ARTDeviceIdentityTokenDetails *)tokenDetails {
    [self.storage setObject:[tokenDetails archive] forKey:ARTDeviceIdentityTokenKey];
    _identityTokenDetails = tokenDetails;
    if (self.clientId == nil) {
        self.clientId = tokenDetails.clientId;
    }
}

- (BOOL)isRegistered {
    return _identityTokenDetails != nil;
}

@end
