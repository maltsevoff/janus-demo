#import <Foundation/Foundation.h>

#import <Ably/ARTTypes.h>
#import <Ably/ARTLog.h>
#import <Ably/ARTRestChannels.h>
#import <Ably/ARTLocalDevice.h>

@protocol ARTHTTPExecutor;

@class ARTRestChannels;
@class ARTClientOptions;
@class ARTAuth;
@class ARTPush;
@class ARTCancellable;
@class ARTStatsQuery;
@class ARTHTTPPaginatedResponse;

NS_ASSUME_NONNULL_BEGIN

@protocol ARTRestProtocol

- (instancetype)init NS_UNAVAILABLE;

/**
 Instance the Ably library with the given options.
 :param options: see ``ARTClientOptions`` for options
 */
- (instancetype)initWithOptions:(ARTClientOptions *)options;

/**
 Instance the Ably library using a key only. This is simply a convenience constructor for the simplest case of instancing the library with a key for basic authentication and no other options.
 :param key; String key (obtained from application dashboard)
 */
- (instancetype)initWithKey:(NSString *)key;
- (instancetype)initWithToken:(NSString *)tokenId;

- (void)time:(ARTDateTimeCallback)callback;

- (BOOL)request:(NSString *)method
           path:(NSString *)path
         params:(nullable NSStringDictionary *)params
           body:(nullable id)body
        headers:(nullable NSStringDictionary *)headers
       callback:(ARTHTTPPaginatedCallback)callback
          error:(NSError *_Nullable *_Nullable)errorPtr;

- (BOOL)stats:(ARTPaginatedStatsCallback)callback;

- (BOOL)stats:(nullable ARTStatsQuery *)query
     callback:(ARTPaginatedStatsCallback)callback
        error:(NSError *_Nullable *_Nullable)errorPtr;

#if TARGET_OS_IOS
@property (readonly) ARTLocalDevice *device;
#endif

@end

/**
 ARTRest object offers a simple stateless API to interact directly with Ably’s REST API.
 */
@interface ARTRest : NSObject <ARTRestProtocol>

@property (readonly) ARTRestChannels *channels;
@property (readonly) ARTPush *push;
@property (readonly) ARTAuth *auth;

+ (instancetype)createWithOptions:(ARTClientOptions *)options NS_SWIFT_UNAVAILABLE("Use instance initializer instead");
+ (instancetype)createWithKey:(NSString *)key NS_SWIFT_UNAVAILABLE("Use instance initializer instead");
+ (instancetype)createWithToken:(NSString *)tokenId NS_SWIFT_UNAVAILABLE("Use instance initializer instead");

@end

NS_ASSUME_NONNULL_END
