#import <Foundation/Foundation.h>

#import <Ably/ARTTypes.h>

@class ARTRealtime;
@class ARTEventEmitter;

NS_ASSUME_NONNULL_BEGIN

@protocol ARTConnectionProtocol <NSObject>

@property (nullable, readonly) NSString *id;
@property (nullable, readonly) NSString *key;
@property (nullable, readonly) NSString *recoveryKey;
@property (readonly) int64_t serial;
@property (readonly) NSInteger maxMessageSize;
@property (readonly) ARTRealtimeConnectionState state;
@property (nullable, readonly) ARTErrorInfo *errorReason;

- (void)connect;
- (void)close;
- (void)ping:(ARTCallback)cb;

ART_EMBED_INTERFACE_EVENT_EMITTER(ARTRealtimeConnectionEvent, ARTConnectionStateChange *)

@end

/**
 * ARTConnection represens the connection associated with an ``ARTRealtime`` instance.
 * It exposes the lifecycle and parameters of the realtime connection.
 */
@interface ARTConnection: NSObject <ARTConnectionProtocol>

@end

#pragma mark - ARTEvent

@interface ARTEvent (ConnectionEvent)
- (instancetype)initWithConnectionEvent:(ARTRealtimeConnectionEvent)value;
+ (instancetype)newWithConnectionEvent:(ARTRealtimeConnectionEvent)value;
@end

NS_ASSUME_NONNULL_END
