#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARTPushChannelSubscription : NSObject

@property (nullable, nonatomic, readonly) NSString *deviceId;
@property (nullable, nonatomic, readonly) NSString *clientId;
@property (nonatomic, readonly) NSString *channel;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDeviceId:(NSString *)deviceId channel:(NSString *)channelName;
- (instancetype)initWithClientId:(NSString *)clientId channel:(NSString *)channelName;

@end

NS_ASSUME_NONNULL_END
