#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARTDeviceIdentityTokenDetails : NSObject <NSSecureCoding>

/**
 Token string.
 */
@property (nonatomic, readonly) NSString *token;

/**
 Contains the time the token was issued in milliseconds.
 */
@property (nonatomic, readonly) NSDate *issued;

/**
 Contains the expiry time in milliseconds.
 */
@property (nonatomic, readonly) NSDate *expires;

/**
 Contains the capability JSON stringified.
 */
@property (nonatomic, readonly) NSString *capability;

/**
 Contains the clientId assigned to the token if provided.
 */
@property (nonatomic, readonly, nullable) NSString *clientId;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithToken:(NSString *)token issued:(NSDate *)issued expires:(NSDate *)expires capability:(NSString *)capability clientId:(nullable NSString *)clientId;

- (NSData *)archive;
+ (nullable ARTDeviceIdentityTokenDetails *)unarchive:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
