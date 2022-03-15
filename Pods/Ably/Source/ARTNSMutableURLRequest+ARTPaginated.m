#import "ARTNSMutableURLRequest+ARTPaginated.h"

@implementation NSMutableURLRequest (ARTPaginated)

+ (NSMutableURLRequest *)requestWithPath:(NSString *)path relativeTo:(NSURLRequest *)request {
    if (!path) {
        return nil;
    }
    NSURL *url = [NSURL URLWithString:path relativeToURL:request.URL];
    return [NSMutableURLRequest requestWithURL:url];
}

@end
