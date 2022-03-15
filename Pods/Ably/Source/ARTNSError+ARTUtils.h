#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (ARTUtils)

@property (nullable, readonly) NSString *requestId;

+ (NSError *)copyFromError:(NSError *)error withRequestId:(nullable NSString *)requestId;

@end

NS_ASSUME_NONNULL_END
