#import <Foundation/Foundation.h>

#import <Ably/ARTTypes.h>
#import <Ably/ARTLog.h>
#import <Ably/ARTRestChannel.h>
#import <Ably/ARTPresenceMessage.h>
#import <Ably/ARTEventEmitter.h>
#import <Ably/ARTRealtimePresence.h>
#import <Ably/ARTDataQuery.h>

NS_ASSUME_NONNULL_BEGIN

@class ARTRealtimePresence;
@class ARTRealtimeChannelOptions;
#if TARGET_OS_IPHONE
@class ARTPushChannel;
#endif

@protocol ARTRealtimeChannelProtocol <ARTChannelProtocol>

@property (readonly) ARTRealtimeChannelState state;
@property (readonly, nullable) ARTErrorInfo *errorReason;
@property (readonly, nullable, getter=getOptions) ARTRealtimeChannelOptions *options;

- (void)attach;
- (void)attach:(nullable ARTCallback)callback;

- (void)detach;
- (void)detach:(nullable ARTCallback)callback;

- (ARTEventListener *_Nullable)subscribe:(ARTMessageCallback)callback;
- (ARTEventListener *_Nullable)subscribeWithAttachCallback:(nullable ARTCallback)onAttach callback:(ARTMessageCallback)cb;
- (ARTEventListener *_Nullable)subscribe:(NSString *)name callback:(ARTMessageCallback)cb;
- (ARTEventListener *_Nullable)subscribe:(NSString *)name onAttach:(nullable ARTCallback)onAttach callback:(ARTMessageCallback)cb;

- (void)unsubscribe;
- (void)unsubscribe:(ARTEventListener *_Nullable)listener;
- (void)unsubscribe:(NSString *)name listener:(ARTEventListener *_Nullable)listener;

- (BOOL)history:(ARTRealtimeHistoryQuery *_Nullable)query callback:(ARTPaginatedMessagesCallback)callback error:(NSError *_Nullable *_Nullable)errorPtr;

- (void)setOptions:(ARTRealtimeChannelOptions *_Nullable)options callback:(nullable ARTCallback)cb;

ART_EMBED_INTERFACE_EVENT_EMITTER(ARTChannelEvent, ARTChannelStateChange *)

@end

/**
 ARTRealtimeChannel provides a straightforward API for publishing and subscribing to messages on a channel.
 In order to publish, subscribe to, or be present on a channel, you must first obtain a channel instance via ``ARTRealtime/channels/get``.
 */
@interface ARTRealtimeChannel : NSObject <ARTRealtimeChannelProtocol>

@property (readonly) ARTRealtimePresence *presence;
#if TARGET_OS_IPHONE
@property (readonly) ARTPushChannel *push;
#endif

@end

#pragma mark - ARTEvent

@interface ARTEvent (ChannelEvent)
- (instancetype)initWithChannelEvent:(ARTChannelEvent)value;
+ (instancetype)newWithChannelEvent:(ARTChannelEvent)value;
@end

NS_ASSUME_NONNULL_END
