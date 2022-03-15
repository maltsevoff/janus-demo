#import <Foundation/Foundation.h>

#import <Ably/ARTTypes.h>

@class ARTAuth;
@class ARTTokenDetails;

NS_ASSUME_NONNULL_BEGIN

@protocol ARTTokenDetailsCompatible <NSObject>
- (void)toTokenDetails:(ARTAuth *)auth callback:(ARTTokenDetailsCallback)callback;
@end

@interface NSString (ARTTokenDetailsCompatible) <ARTTokenDetailsCompatible>
@end

/**
 ARTAuthOptions is used when making authentication requests. These options will supplement or override the corresponding options given when the library was instantiated.
 */
@interface ARTAuthOptions : NSObject<NSCopying>

/**
 Full Ably key string as obtained from dashboard.
 */
@property (nonatomic, copy, nullable) NSString *key;

/**
 An authentication token issued for this application against a specific key and `TokenParams`.
 */
@property (nonatomic, copy, nullable) NSString *token;

/**
 An authentication token issued for this application against a specific key and `TokenParams`.
 */
@property (nonatomic, strong, nullable) ARTTokenDetails *tokenDetails;

/**
 A callback to call to obtain a signed token request.
 
 This enables a client to obtain token requests from another entity, so tokens can be renewed without the client requiring access to keys.
 */
@property (nonatomic, copy, nullable) ARTAuthCallback authCallback;

/**
 A URL to queryto obtain a signed token request.
 
 This enables a client to obtain token requests from another entity, so tokens can be renewed without the client requiring access to keys.
 */
@property (nonatomic, strong, nullable) NSURL *authUrl;

/**
 The HTTP verb to be used when a request is made by the library to the authUrl. Defaults to GET, supports GET and POST.
 */
@property (nonatomic, copy, null_resettable) NSString *authMethod;

/**
 Headers to be included in any request made by the library to the authURL.
 */
@property (nonatomic, copy, nullable) NSStringDictionary *authHeaders;

/**
 Additional params to be included in any request made by the library to the authUrl, either as query params in the case of GET or in the body in the case of POST.
 */
@property (nonatomic, copy, nullable) NSArray<NSURLQueryItem *> *authParams;

/**
 This may be set in instances that the library is to sign token requests based on a given key.
 If true, the library will query the Ably system for the current time instead of relying on a locally-available time of day.
 */
@property (nonatomic, assign, nonatomic) BOOL queryTime;

/**
 Forces authentication with token.
 */
@property (readwrite, assign, nonatomic) BOOL useTokenAuth;

- (instancetype)init;
- (instancetype)initWithKey:(NSString *)key;
- (instancetype)initWithToken:(NSString *)token;
- (instancetype)initWithTokenDetails:(ARTTokenDetails *)tokenDetails;

- (NSString *)description;

- (ARTAuthOptions *)mergeWith:(ARTAuthOptions *)precedenceOptions;

- (BOOL)isMethodGET;
- (BOOL)isMethodPOST;

@end

NS_ASSUME_NONNULL_END
