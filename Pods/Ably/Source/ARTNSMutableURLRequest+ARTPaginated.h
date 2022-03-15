#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableURLRequest (ARTPaginated)

+ (nullable NSMutableURLRequest *)requestWithPath:(NSString *)path relativeTo:(NSURLRequest *)request;

@end

NS_ASSUME_NONNULL_END
