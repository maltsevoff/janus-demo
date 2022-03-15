#import <Foundation/Foundation.h>

#import <Ably/ARTTypes.h>
#import <Ably/ARTDataEncoder.h>
#import <Ably/ARTLog.h>

@class ARTRest;
@class ARTChannelOptions;
@class ARTMessage;
@class ARTBaseMessage;
@class ARTPaginatedResult<ItemType>;
@class ARTDataQuery;
@class ARTLocalDevice;

NS_ASSUME_NONNULL_BEGIN

@protocol ARTChannelProtocol

@property (readonly) NSString *name;

- (void)publish:(nullable NSString *)name data:(nullable id)data;
- (void)publish:(nullable NSString *)name data:(nullable id)data callback:(nullable ARTCallback)callback;

- (void)publish:(nullable NSString *)name data:(nullable id)data clientId:(NSString *)clientId;
- (void)publish:(nullable NSString *)name data:(nullable id)data clientId:(NSString *)clientId callback:(nullable ARTCallback)callback;

- (void)publish:(nullable NSString *)name data:(nullable id)data extras:(nullable id<ARTJsonCompatible>)extras;
- (void)publish:(nullable NSString *)name data:(nullable id)data extras:(nullable id<ARTJsonCompatible>)extras callback:(nullable ARTCallback)callback;

- (void)publish:(nullable NSString *)name data:(nullable id)data clientId:(NSString *)clientId extras:(nullable id<ARTJsonCompatible>)extras;
- (void)publish:(nullable NSString *)name data:(nullable id)data clientId:(NSString *)clientId extras:(nullable id<ARTJsonCompatible>)extras callback:(nullable ARTCallback)callback;

- (void)publish:(NSArray<ARTMessage *> *)messages;
- (void)publish:(NSArray<ARTMessage *> *)messages callback:(nullable ARTCallback)callback;

- (void)history:(ARTPaginatedMessagesCallback)callback;

@end

/**
 The base class for ``ARTRestChannel`` and ``ARTRealtimeChannel``.
 Ably platform service organizes the message traffic within applications into named channels. Channels are the medium through which messages are distributed; clients attach to channels to subscribe to messages, and every message published to a unique channel is broadcast by Ably to all subscribers.
 */
@interface ARTChannel : NSObject<ARTChannelProtocol>

@property (nonatomic, strong, readonly) NSString *name;

@end

NS_ASSUME_NONNULL_END
