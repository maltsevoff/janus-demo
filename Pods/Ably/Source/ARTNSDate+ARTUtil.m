#import "ARTNSDate+ARTUtil.h"

@implementation NSDate (ARTUtil)

+ (instancetype)artDateFromIntegerMs:(long long)ms {
    NSTimeInterval intervalSince1970 = ms / 1000.0;
    return [NSDate dateWithTimeIntervalSince1970:intervalSince1970];
}

+ (instancetype)artDateFromNumberMs:(NSNumber *)number {
    return [self artDateFromIntegerMs:[number longLongValue]];
}

- (NSNumber *)artToNumberMs {
    return [NSNumber numberWithInteger:[self artToIntegerMs]];
}

- (NSInteger)artToIntegerMs {
    return (NSInteger)round([self timeIntervalSince1970] * 1000.0);
}

@end
