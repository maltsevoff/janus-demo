#import "ARTNSString+ARTUtil.h"

@implementation NSString (ARTUtil)

+ (NSString *)nilToEmpty:(NSString*)aString {
    if ([aString length] == 0) {
        return @"";
    }
    return aString;
}

- (BOOL)isEmptyString {
    return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""];
}

- (BOOL)isNotEmptyString {
    return ![self isEmptyString];
}

@end
