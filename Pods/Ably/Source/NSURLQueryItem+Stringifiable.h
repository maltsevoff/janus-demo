#import <Foundation/Foundation.h>
@class ARTStringifiable;

NS_ASSUME_NONNULL_BEGIN

@interface NSURLQueryItem (ARTNSURLQueryItem_Stringifiable)

+ (NSURLQueryItem*)itemWithName:(NSString *)name value:(ARTStringifiable *)value;

@end

NS_ASSUME_NONNULL_END
