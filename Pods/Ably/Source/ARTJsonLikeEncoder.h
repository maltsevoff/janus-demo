#ifndef ARTJsonLikeEncoder_h
#define ARTJsonLikeEncoder_h

#import <Ably/ARTRest+Private.h>
#import <Ably/ARTEncoder.h>
#import <Ably/ARTTokenDetails.h>
#import <Ably/ARTTokenRequest.h>
#import <Ably/ARTAuthDetails.h>
#import <Ably/ARTStats.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ARTJsonLikeEncoderDelegate <NSObject>

- (NSString *)mimeType;
- (ARTEncoderFormat)format;
- (NSString *)formatAsString;

- (nullable id)decode:(NSData *)data error:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (nullable NSData *)encode:(id)obj error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end

@interface ARTJsonLikeEncoder : NSObject <ARTEncoder>

@property (nonatomic, strong, nullable) id<ARTJsonLikeEncoderDelegate> delegate;

- (instancetype)initWithDelegate:(id<ARTJsonLikeEncoderDelegate>)delegate;
- (instancetype)initWithLogger:(ARTLog *)logger delegate:(nullable id<ARTJsonLikeEncoderDelegate>)delegate;
- (instancetype)initWithRest:(ARTRestInternal *)rest delegate:(nullable id<ARTJsonLikeEncoderDelegate>)delegate;

@end

@interface ARTJsonLikeEncoder ()

- (nullable ARTMessage *)messageFromDictionary:(NSDictionary *)input;
- (nullable NSArray *)messagesFromArray:(NSArray *)input;

- (nullable ARTPresenceMessage *)presenceMessageFromDictionary:(NSDictionary *)input;
- (nullable NSArray *)presenceMessagesFromArray:(NSArray *)input;

- (NSDictionary *)messageToDictionary:(ARTMessage *)message;
- (NSArray *)messagesToArray:(NSArray *)messages;

- (NSDictionary *)presenceMessageToDictionary:(ARTPresenceMessage *)message;
- (NSArray *)presenceMessagesToArray:(NSArray *)messages;

- (NSDictionary *)protocolMessageToDictionary:(ARTProtocolMessage *)message;
- (nullable ARTProtocolMessage *)protocolMessageFromDictionary:(NSDictionary *)input;

- (NSDictionary *)tokenRequestToDictionary:(ARTTokenRequest *)tokenRequest;

- (NSDictionary *)authDetailsToDictionary:(ARTAuthDetails *)authDetails;
- (nullable ARTAuthDetails *)authDetailsFromDictionary:(NSDictionary *)input;

- (nullable NSArray *)statsFromArray:(NSArray *)input;
- (nullable ARTStats *)statsFromDictionary:(NSDictionary *)input;
- (nullable ARTStatsMessageTypes *)statsMessageTypesFromDictionary:(NSDictionary *)input;
- (nullable ARTStatsMessageCount *)statsMessageCountFromDictionary:(NSDictionary *)input;
- (nullable ARTStatsMessageTraffic *)statsMessageTrafficFromDictionary:(NSDictionary *)input;
- (nullable ARTStatsConnectionTypes *)statsConnectionTypesFromDictionary:(NSDictionary *)input;
- (nullable ARTStatsResourceCount *)statsResourceCountFromDictionary:(NSDictionary *)input;
- (nullable ARTStatsRequestCount *)statsRequestCountFromDictionary:(NSDictionary *)input;

- (void)writeData:(id)data encoding:(NSString *)encoding toDictionary:(NSMutableDictionary *)output;

- (nullable NSDictionary *)decodeDictionary:(NSData *)data error:(NSError **)error;
- (nullable NSArray *)decodeArray:(NSData *)data error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

#endif /* ARTJsonLikeEncoder_h */
