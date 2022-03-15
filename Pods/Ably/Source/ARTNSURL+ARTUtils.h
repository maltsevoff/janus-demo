#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (ARTUtils)

+ (nullable NSURL *)copyFromURL:(NSURL *)url withHost:(NSString *)host;

@end

NS_ASSUME_NONNULL_END
