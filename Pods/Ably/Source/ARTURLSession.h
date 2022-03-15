#ifndef ARTURLSession_h
#define ARTURLSession_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ARTURLSession <NSObject>

@property (readonly) dispatch_queue_t queue;

- (instancetype)init:(dispatch_queue_t)queue;

- (NSObject<ARTCancellable> *)get:(NSURLRequest *)request completion:(ARTURLRequestCallback)callback;

- (void)finishTasksAndInvalidate;

@end

NS_ASSUME_NONNULL_END

#endif /* ARTURLSession_h */
