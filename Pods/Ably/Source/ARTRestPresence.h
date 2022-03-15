#import <Foundation/Foundation.h>

#import <Ably/ARTPresence.h>
#import <Ably/ARTDataQuery.h>

@class ARTRestChannel;

NS_ASSUME_NONNULL_BEGIN

@interface ARTPresenceQuery : NSObject

@property (nonatomic, readwrite) NSUInteger limit;
@property (nullable, nonatomic, strong, readwrite) NSString *clientId;
@property (nullable, nonatomic, strong, readwrite) NSString *connectionId;

- (instancetype)init;
- (instancetype)initWithClientId:(NSString *_Nullable)clientId connectionId:(NSString *_Nullable)connectionId;
- (instancetype)initWithLimit:(NSUInteger)limit clientId:(NSString *_Nullable)clientId connectionId:(NSString *_Nullable)connectionId;

@end

@protocol ARTRestPresenceProtocol

- (void)get:(ARTPaginatedPresenceCallback)callback;
- (BOOL)get:(ARTPaginatedPresenceCallback)callback error:(NSError *_Nullable *_Nullable)errorPtr;
- (BOOL)get:(ARTPresenceQuery *)query callback:(ARTPaginatedPresenceCallback)callback error:(NSError *_Nullable *_Nullable)errorPtr;

- (BOOL)history:(nullable ARTDataQuery *)query callback:(ARTPaginatedPresenceCallback)callback error:(NSError *_Nullable *_Nullable)errorPtr;

@end

@interface ARTRestPresence : ARTPresence <ARTRestPresenceProtocol>

- (void)get:(ARTPaginatedPresenceCallback)callback;
- (BOOL)get:(ARTPaginatedPresenceCallback)callback error:(NSError *_Nullable *_Nullable)errorPtr;
- (BOOL)get:(ARTPresenceQuery *)query callback:(ARTPaginatedPresenceCallback)callback error:(NSError *_Nullable *_Nullable)errorPtr;

- (BOOL)history:(nullable ARTDataQuery *)query callback:(ARTPaginatedPresenceCallback)callback error:(NSError *_Nullable *_Nullable)errorPtr;

@end

NS_ASSUME_NONNULL_END
