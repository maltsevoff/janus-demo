#import "ARTNSDictionary+ARTDictionaryUtil.h"
#import "ARTNSDate+ARTUtil.h"

@implementation NSDictionary (ARTDictionaryUtil)

- (NSString *)artString:(id)key {
    return [self artTyped:[NSString class] key:key];
}

- (NSNumber *)artNumber:(id)key {
    return [self artTyped:[NSNumber class] key:key];
}

- (NSDate *)artTimestamp:(id)key {
    NSNumber *number = [self artNumber:key];
    if (number != nil) {
        return [NSDate artDateFromNumberMs:number];
    }
    NSString *string = [self artString:key];
    if (string) {
        return [NSDate artDateFromIntegerMs:[string longLongValue]];
    }
    return nil;
}

- (NSArray *)artArray:(id)key {
    return [self artTyped:[NSArray class] key:key];
}

- (NSDictionary *)artDictionary:(id)key {
    return [self artTyped:[NSDictionary class] key:key];
}

- (id)artTyped:(Class)cls key:(id)key {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:cls]) {
        return obj;
    }
    return nil;
}

- (NSInteger)artInteger:(id)key {
    NSNumber *number = [self artNumber:key];
    if (number != nil) {
        return [number integerValue];
    }
    NSString *string = [self artString:key];
    if (string) {
        return [string integerValue];
    }
    return 0;
}

@end
