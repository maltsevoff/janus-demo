#import <Ably/ARTRest.h>

@protocol ARTDeviceStorage;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const ARTDeviceIdKey;
extern NSString *const ARTDeviceSecretKey;
extern NSString *const ARTDeviceIdentityTokenKey;
extern NSString *const ARTAPNSDeviceTokenKey;

@interface ARTLocalDevice ()

@property (strong, nonatomic) id<ARTDeviceStorage> storage;

+ (ARTLocalDevice *)load:(NSString *)clientId storage:(id<ARTDeviceStorage>)storage;
- (nullable NSString *)apnsDeviceToken;
- (void)setAndPersistAPNSDeviceToken:(nullable NSString *)deviceToken;
- (void)setAndPersistIdentityTokenDetails:(nullable ARTDeviceIdentityTokenDetails *)tokenDetails;
- (BOOL)isRegistered;

+ (NSString *)generateId;
+ (NSString *)generateSecret;

@end

NS_ASSUME_NONNULL_END
