#import <Foundation/Foundation.h>

#import <Ably/ARTTypes.h>
#import <Ably/ARTURLSession.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARTURLSessionServerTrust : NSObject<NSURLSessionDelegate, NSURLSessionTaskDelegate, ARTURLSession>

@end

NS_ASSUME_NONNULL_END
