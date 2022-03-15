#import <Foundation/Foundation.h>

#import <Ably/ARTPaginatedResult.h>

NS_ASSUME_NONNULL_BEGIN

/**
 ARTHTTPPaginatedResponse is a superset of ``ARTPaginatedResult``, which is a type that represents a page of results plus metadata indicating the relative queries available to it. ARTHTTPPaginatedResponse additionally carries information about the response to an HTTP request. It is used when making custom HTTP requests.
 */
@interface ARTHTTPPaginatedResponse : ARTPaginatedResult<NSDictionary *>

/// Return the HTTP status code of the response
@property (nonatomic, readonly) NSInteger statusCode;

/// Returns true when the HTTP status code indicates success i.e. 200 <= statusCode < 300
@property (nonatomic, readonly) BOOL success;

/// Returns the error code if the X-Ably-ErrorCode HTTP header is sent in the response
@property (nonatomic, readonly) NSInteger errorCode;

/// Returns error message if the X-Ably-ErrorMessage HTTP header is sent in the response
@property (nullable, nonatomic, readonly) NSString *errorMessage;

/// Returns a dictionary containing all the HTTP header fields of the response header.
@property (nonatomic, readonly) NSStringDictionary *headers;

- (void)first:(ARTHTTPPaginatedCallback)callback;
- (void)next:(ARTHTTPPaginatedCallback)callback;

@end

NS_ASSUME_NONNULL_END
