#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSHTTPURLResponse (ARTPaginated)

- (nullable NSDictionary *)extractLinks;

@end

NS_ASSUME_NONNULL_END
