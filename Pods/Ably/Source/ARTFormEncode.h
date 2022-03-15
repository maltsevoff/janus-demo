#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Express the input dictionary as a `application/x-www-form-urlencoded` string.
 If the parameters dictionary is nil or empty, returns nil.
*/
NSString *ARTFormEncode(NSDictionary *parameters);

NS_ASSUME_NONNULL_END
