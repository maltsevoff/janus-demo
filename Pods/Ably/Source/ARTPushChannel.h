#import <Foundation/Foundation.h>
#import <Ably/ARTPush.h>
#import <Ably/ARTHttp.h>
#import <Ably/ARTChannel.h>

@class ARTPushChannelSubscription;
@class ARTPaginatedResult;

NS_ASSUME_NONNULL_BEGIN

@protocol ARTPushChannelProtocol

- (instancetype)init NS_UNAVAILABLE;

- (void)subscribeDevice;
- (void)subscribeDevice:(nullable ARTCallback)callback;
- (void)subscribeClient;
- (void)subscribeClient:(nullable ARTCallback)callback;

- (void)unsubscribeDevice;
- (void)unsubscribeDevice:(nullable ARTCallback)callback;
- (void)unsubscribeClient;
- (void)unsubscribeClient:(nullable ARTCallback)callback;

- (BOOL)listSubscriptions:(NSStringDictionary *)params
                 callback:(ARTPaginatedPushChannelCallback)callback
                    error:(NSError *_Nullable *_Nullable)errorPtr;

@end

@interface ARTPushChannel : NSObject <ARTPushChannelProtocol>

@end

NS_ASSUME_NONNULL_END
