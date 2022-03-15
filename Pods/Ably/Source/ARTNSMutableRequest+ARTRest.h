#import <Foundation/Foundation.h>

@protocol ARTEncoder;

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableURLRequest (ARTRest)

- (void)setAcceptHeader:(id<ARTEncoder>)defaultEncoder encoders:(NSDictionary<NSString *, id<ARTEncoder>> *)encoders;

@end

NS_ASSUME_NONNULL_END
