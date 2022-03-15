#import <Foundation/Foundation.h>

#import <Ably/ARTTypes.h>
#import <Ably/ARTLog.h>

@class ARTRest;
@class ARTLog;
@class ARTClientOptions;
@class ARTAuthOptions;
@class ARTTokenParams;
@class ARTTokenDetails;
@class ARTTokenRequest;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ARTAuth

@protocol ARTAuthProtocol

@property (nullable, readonly) NSString *clientId;

@property (nullable, readonly) ARTTokenDetails *tokenDetails;

- (instancetype)init NS_UNAVAILABLE;

/**
 # (RSA8) Auth#requestToken
 
 Implicitly creates a `TokenRequest` if required, and requests a token from Ably if required.
 
 `TokenParams` and `AuthOptions` are optional.
 When provided, the values supersede matching client library configured params and options.
 
 - Parameter tokenParams: Token params (optional).
 - Parameter authOptions: Authentication options (optional).
 - Parameter callback: Completion callback (ARTTokenDetails, NSError).
 */
- (void)requestToken:(nullable ARTTokenParams *)tokenParams
         withOptions:(nullable ARTAuthOptions *)authOptions
            callback:(ARTTokenDetailsCallback)callback;

- (void)requestToken:(ARTTokenDetailsCallback)callback;

- (void)authorize:(nullable ARTTokenParams *)tokenParams
          options:(nullable ARTAuthOptions *)authOptions
         callback:(ARTTokenDetailsCallback)callback;

- (void)authorize:(ARTTokenDetailsCallback)callback;

- (void)createTokenRequest:(nullable ARTTokenParams *)tokenParams
                   options:(nullable ARTAuthOptions *)options
                  callback:(void (^)(ARTTokenRequest *_Nullable tokenRequest, NSError *_Nullable error))callback;

- (void)createTokenRequest:(void (^)(ARTTokenRequest *_Nullable tokenRequest, NSError *_Nullable error))callback;

@end

@interface ARTAuth : NSObject <ARTAuthProtocol>

@end

NS_ASSUME_NONNULL_END
