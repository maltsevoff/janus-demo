#import "NSURLQueryItem+Stringifiable.h"
#import "ARTStringifiable.h"

@implementation NSURLQueryItem (ARTNSURLQueryItem_Stringifiable)

+ (NSURLQueryItem *)itemWithName:(NSString *)name value:(ARTStringifiable *)value {
    return [NSURLQueryItem queryItemWithName:name value:[value stringValue]];
}

@end
