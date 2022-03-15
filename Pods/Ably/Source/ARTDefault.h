#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARTDefault : NSObject

+ (NSString *)apiVersion;
+ (NSString *)libraryVersion;

+ (NSArray<NSString *> *)fallbackHosts;
+ (NSArray<NSString *> *)fallbackHostsWithEnvironment:(NSString *_Nullable)environment;
+ (NSString*)restHost;
+ (NSString*)realtimeHost;
+ (int)port;
+ (int)tlsPort;

/**
 Default in seconds of requested time to live for the token.
 */
+ (NSTimeInterval)ttl;

/**
 When the client is in the DISCONNECTED state, once this TTL has passed, the client should change the state to the SUSPENDED state signifying that the state is now lost i.e. channels need to be reattached manually.
 
 Note that this default is override by any connectionStateTtl specified in the ConnectionDetails of the CONNECTED ProtocolMessage.
 */
+ (NSTimeInterval)connectionStateTtl;

/**
 When a realtime client library is establishing a connection with Ably, or sending a HEARTBEAT, CONNECT, ATTACH, DETACH or CLOSE ProtocolMessage to Ably, this is the amount of time that the client library will wait before considering that request as failed and triggering a suitable failure condition.
 */
+ (NSTimeInterval)realtimeRequestTimeout;

+ (NSString *)libraryAgent;

+ (NSString *)platformAgent;

+ (NSInteger)maxMessageSize;

/**
 The period in seconds before HTTP requests are retried against the default endpoint
 */
+ (NSTimeInterval)fallbackRetryTimeout;

@end

NS_ASSUME_NONNULL_END
