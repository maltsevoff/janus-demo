#import <Foundation/Foundation.h>

#define NSStringFromBOOL(aBOOL) ((aBOOL) ? @"YES" : @"NO")

@interface NSString (ARTUtil)

+ (NSString *)nilToEmpty:(NSString*)aString;
- (BOOL)isEmptyString;
- (BOOL)isNotEmptyString;

@end
