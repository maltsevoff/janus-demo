#import <Foundation/Foundation.h>

@interface NSDate (ARTUtil)

+ (instancetype)artDateFromNumberMs:(NSNumber *)number;
+ (instancetype)artDateFromIntegerMs:(long long)ms;

- (NSNumber *)artToNumberMs;
- (NSInteger)artToIntegerMs;

@end
