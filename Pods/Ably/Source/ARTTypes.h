#import <Foundation/Foundation.h>

#import <Ably/ARTStatus.h>
#import <Ably/ARTEventEmitter.h>

@class ARTStatus;
@class ARTHttpResponse;
@class ARTErrorInfo;
@class ARTMessage;
@class ARTPresenceMessage;
@class ARTTokenParams;
@class ARTTokenRequest;
@class ARTTokenDetails;
@class ARTHTTPPaginatedResponse;
@class ARTPaginatedResult<ItemType>;
@class ARTStats;
@class ARTPushChannelSubscription;
@class ARTDeviceDetails;
@protocol ARTTokenDetailsCompatible;

// More context
typedef NSDictionary<NSString *, id> ARTJsonObject;
typedef NSString ARTDeviceId;
typedef NSString ARTDeviceSecret;
typedef NSData ARTDeviceToken;
typedef ARTJsonObject ARTPushRecipient;

typedef NS_ENUM(NSUInteger, ARTAuthentication) {
    ARTAuthenticationOff,
    ARTAuthenticationOn,
    ARTAuthenticationUseBasic,
    ARTAuthenticationNewToken,
    ARTAuthenticationTokenRetry
};

typedef NS_ENUM(NSUInteger, ARTAuthMethod) {
    ARTAuthMethodBasic,
    ARTAuthMethodToken
};


#pragma mark - ARTRealtimeConnectionState

/**
 ARTRealtimeConnectionState is an enum representing all the Realtime Connection states.
 */
typedef NS_ENUM(NSUInteger, ARTRealtimeConnectionState) {
    ARTRealtimeInitialized,
    ARTRealtimeConnecting,
    ARTRealtimeConnected,
    ARTRealtimeDisconnected,
    ARTRealtimeSuspended,
    ARTRealtimeClosing,
    ARTRealtimeClosed,
    ARTRealtimeFailed
};

NSString *_Nonnull ARTRealtimeConnectionStateToStr(ARTRealtimeConnectionState state);


#pragma mark - ARTRealtimeConnectionEvent

/**
 ARTRealtimeConnectionEvent is an enum representing all the events that can be emitted be the Connection; either a Realtime Connection state or an Update event.
 */
typedef NS_ENUM(NSUInteger, ARTRealtimeConnectionEvent) {
    ARTRealtimeConnectionEventInitialized,
    ARTRealtimeConnectionEventConnecting,
    ARTRealtimeConnectionEventConnected,
    ARTRealtimeConnectionEventDisconnected,
    ARTRealtimeConnectionEventSuspended,
    ARTRealtimeConnectionEventClosing,
    ARTRealtimeConnectionEventClosed,
    ARTRealtimeConnectionEventFailed,
    ARTRealtimeConnectionEventUpdate
};

NSString *_Nonnull ARTRealtimeConnectionEventToStr(ARTRealtimeConnectionEvent event);


#pragma mark - ARTRealtimeChannelState

/**
 ARTRealtimeChannelState is an enum representing all the Realtime Channel states.
 */
typedef NS_ENUM(NSUInteger, ARTRealtimeChannelState) {
    ARTRealtimeChannelInitialized,
    ARTRealtimeChannelAttaching,
    ARTRealtimeChannelAttached,
    ARTRealtimeChannelDetaching,
    ARTRealtimeChannelDetached,
    ARTRealtimeChannelSuspended,
    ARTRealtimeChannelFailed
};

NSString *_Nonnull ARTRealtimeChannelStateToStr(ARTRealtimeChannelState state);


#pragma mark - ARTChannelEvent

/**
 ARTChannelEvent is the enum emitted as the event in ARTRealtimeChannel.on; either a ChannelState or an Update event.
 */
typedef NS_ENUM(NSUInteger, ARTChannelEvent) {
    ARTChannelEventInitialized,
    ARTChannelEventAttaching,
    ARTChannelEventAttached,
    ARTChannelEventDetaching,
    ARTChannelEventDetached,
    ARTChannelEventSuspended,
    ARTChannelEventFailed,
    ARTChannelEventUpdate
};

NSString *_Nonnull ARTChannelEventToStr(ARTChannelEvent event);


typedef NS_ENUM(NSInteger, ARTDataQueryError) {
    ARTDataQueryErrorLimit = 1,
    ARTDataQueryErrorTimestampRange = 2,
    ARTDataQueryErrorMissingRequiredFields = 3,
    ARTDataQueryErrorInvalidParameters = 4,
    ARTDataQueryErrorDeviceInactive = 5,
};

typedef NS_ENUM(NSInteger, ARTRealtimeHistoryError) {
    ARTRealtimeHistoryErrorNotAttached = ARTDataQueryErrorTimestampRange + 1
};

typedef NS_ENUM(NSInteger, ARTCustomRequestError) {
    ARTCustomRequestErrorInvalidMethod = 1,
    ARTCustomRequestErrorInvalidBody = 2,
    ARTCustomRequestErrorInvalidPath = 3,
};

NS_ASSUME_NONNULL_BEGIN

/// Decompose API key
NSArray<NSString *> *decomposeKey(NSString *key);

NSString *encodeBase64(NSString *value);
NSString *decodeBase64(NSString *base64);

uint64_t dateToMilliseconds(NSDate *date);
uint64_t timeIntervalToMilliseconds(NSTimeInterval seconds);
NSTimeInterval millisecondsToTimeInterval(uint64_t msecs);

NSString *generateNonce(void);

@protocol ARTCancellable
- (void)cancel;
@end

#pragma mark - ARTConnectionStateChange

/**
 ARTConnectionStateChange is a type encapsulating state change information emitted by the ``ARTConnection`` object.
 See ``ARTConnection/on`` to register a listener for one or more events.
 */
@interface ARTConnectionStateChange : NSObject

- (instancetype)initWithCurrent:(ARTRealtimeConnectionState)current
                       previous:(ARTRealtimeConnectionState)previous
                          event:(ARTRealtimeConnectionEvent)event
                         reason:(ARTErrorInfo *_Nullable)reason;

- (instancetype)initWithCurrent:(ARTRealtimeConnectionState)current
                       previous:(ARTRealtimeConnectionState)previous
                          event:(ARTRealtimeConnectionEvent)event
                         reason:(ARTErrorInfo *_Nullable)reason
                        retryIn:(NSTimeInterval)retryIn;

@property (readonly, nonatomic) ARTRealtimeConnectionState current;
@property (readonly, nonatomic) ARTRealtimeConnectionState previous;
@property (readonly, nonatomic) ARTRealtimeConnectionEvent event;
@property (readonly, nonatomic, nullable) ARTErrorInfo *reason;
@property (readonly, nonatomic) NSTimeInterval retryIn;

@end

#pragma mark - ARTChannelStateChange

@interface ARTChannelStateChange : NSObject

- (instancetype)initWithCurrent:(ARTRealtimeChannelState)current
                       previous:(ARTRealtimeChannelState)previous
                          event:(ARTChannelEvent)event
                         reason:(ARTErrorInfo *_Nullable)reason;

- (instancetype)initWithCurrent:(ARTRealtimeChannelState)current
                       previous:(ARTRealtimeChannelState)previous
                          event:(ARTChannelEvent)event
                         reason:(ARTErrorInfo *_Nullable)reason
                        resumed:(BOOL)resumed;

@property (readonly, nonatomic) ARTRealtimeChannelState current;
@property (readonly, nonatomic) ARTRealtimeChannelState previous;
@property (readonly, nonatomic) ARTChannelEvent event;
@property (readonly, nonatomic, nullable) ARTErrorInfo *reason;
@property (readonly, nonatomic) BOOL resumed;

@end

#pragma mark - ARTJsonCompatible

@protocol ARTJsonCompatible <NSObject>
- (NSDictionary *_Nullable)toJSON:(NSError *_Nullable *_Nullable)error;
- (NSString *_Nullable)toJSONString;
@end

@interface NSString (ARTEventIdentification) <ARTEventIdentification>
@end

@interface NSString (ARTJsonCompatible) <ARTJsonCompatible>
@end

@interface NSString (ARTUtilities)
- (NSString *)art_shortString NS_SWIFT_NAME(shortString());
- (NSString *)art_base64Encoded NS_SWIFT_NAME(base64Encoded());
@end

@interface NSDate (ARTUtilities)
+ (NSDate *)art_dateWithMillisecondsSince1970:(uint64_t)msecs NS_SWIFT_NAME(date(withMillisecondsSince1970:));
@end

@interface NSDictionary (ARTJsonCompatible) <ARTJsonCompatible>
@end

@interface NSURL (ARTLog)
@end

@interface NSDictionary (ARTURLQueryItemAdditions)
@property (nonatomic, readonly) NSArray<NSURLQueryItem *> *art_asURLQueryItems;
@end

@interface NSMutableArray (ARTQueueAdditions)
- (void)art_enqueue:(id)object;
- (nullable id)art_dequeue;
- (nullable id)art_peek;
@end

@interface NSObject (ARTArchive)
- (nullable NSData *)art_archive;
+ (nullable id)art_unarchiveFromData:(NSData *)data;
@end

@interface NSURLSessionTask (ARTCancellable) <ARTCancellable>
@end

#pragma mark - Typedefs

typedef NSDictionary<NSString *, NSString *> NSStringDictionary;

/**
 Signatures of completion handlers to improve readability and maintainability in properties and method parameters.
 Either result/response or error can be nil but not both.
 */
typedef void (^ARTCallback)(ARTErrorInfo *_Nullable error);
typedef void (^ARTResultCallback)(id _Nullable result, NSError *_Nullable error);
typedef void (^ARTDateTimeCallback)(NSDate *_Nullable result, NSError *_Nullable error);

typedef void (^ARTMessageCallback)(ARTMessage *message);
typedef void (^ARTChannelStateCallback)(ARTChannelStateChange *stateChange);
typedef void (^ARTConnectionStateCallback)(ARTConnectionStateChange *stateChange);
typedef void (^ARTPresenceMessageCallback)(ARTPresenceMessage *message);
typedef void (^ARTPresenceMessagesCallback)(NSArray<ARTPresenceMessage *> *_Nullable result, ARTErrorInfo *_Nullable error);

typedef void (^ARTStatusCallback)(ARTStatus *status);
typedef void (^ARTURLRequestCallback)(NSHTTPURLResponse *_Nullable result, NSData *_Nullable data, NSError *_Nullable error);
typedef void (^ARTTokenDetailsCallback)(ARTTokenDetails *_Nullable result, NSError *_Nullable error);
typedef void (^ARTTokenDetailsCompatibleCallback)(id<ARTTokenDetailsCompatible> _Nullable result, NSError *_Nullable error);
typedef void (^ARTAuthCallback)(ARTTokenParams *params, ARTTokenDetailsCompatibleCallback callback);

typedef void (^ARTHTTPPaginatedCallback)(ARTHTTPPaginatedResponse *_Nullable response, ARTErrorInfo *_Nullable error);
typedef void (^ARTPaginatedStatsCallback)(ARTPaginatedResult<ARTStats *> *_Nullable result, ARTErrorInfo *_Nullable error);
typedef void (^ARTPaginatedPresenceCallback)(ARTPaginatedResult<ARTPresenceMessage *> *_Nullable result, ARTErrorInfo *_Nullable error);
typedef void (^ARTPaginatedPushChannelCallback)(ARTPaginatedResult<ARTPushChannelSubscription *> *_Nullable result, ARTErrorInfo *_Nullable error);
typedef void (^ARTPaginatedMessagesCallback)(ARTPaginatedResult<ARTMessage *> *_Nullable result, ARTErrorInfo *_Nullable error);
typedef void (^ARTPaginatedDeviceDetailsCallback)(ARTPaginatedResult<ARTDeviceDetails *> *_Nullable result, ARTErrorInfo *_Nullable error);
typedef void (^ARTPaginatedTextCallback)(ARTPaginatedResult<NSString *> *_Nullable result, ARTErrorInfo *_Nullable error);

#pragma mark - Functions

/**
 Wraps the given callback in an ARTCancellable, offering the following
 protections:
 
 1) If the cancel method is called on the returned instance then the callback
    will not be invoked.
 2) The callback will only ever be invoked once.
 
 To make use of these benefits the caller needs to use the returned wrapper
 to invoke the callback. The wrapper will only work for as long as the returned
 instance remains allocated (i.e. has a strong reference to it somewhere).
 */
NSObject<ARTCancellable> * artCancellableFromCallback(ARTResultCallback callback, _Nonnull ARTResultCallback *_Nonnull wrapper);

NS_ASSUME_NONNULL_END
