#import "ARTNSURL+ARTUtils.h"

@implementation NSURL (ARTUtils)

+ (NSURL *)copyFromURL:(NSURL *)url withHost:(NSString *)host {
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    components.host = host;
    
    return components.URL;
}

@end
