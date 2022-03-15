#import <Foundation/Foundation.h>
#import <Ably/ARTPush.h>

@class ARTDevicePushDetails;

NS_ASSUME_NONNULL_BEGIN

@interface ARTDeviceDetails : NSObject

@property (nonatomic) ARTDeviceId *id;
@property (nullable, nonatomic) NSString *clientId;
@property (nonatomic) NSString *platform;
@property (nonatomic) NSString *formFactor;
@property (nonatomic) NSMutableDictionary<NSString *, NSString *> *metadata;
@property (nonatomic) ARTDevicePushDetails *push;

- (instancetype)init;
- (instancetype)initWithId:(ARTDeviceId *)deviceId;

@end

NS_ASSUME_NONNULL_END
