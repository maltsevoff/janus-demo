#import "ARTNSMutableURLRequest+ARTUtils.h"

@implementation NSMutableURLRequest (ARTUtils)

- (void)appendQueryItem:(NSURLQueryItem *)item {
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.URL resolvingAgainstBaseURL:YES];
    if(components == nil) {
        return;
    }
    
    NSMutableArray<NSURLQueryItem *> *mutableQueryItems = [NSMutableArray arrayWithArray:components.queryItems];
    [mutableQueryItems addObject:item];
    components.queryItems = mutableQueryItems;
    
    NSURL *modifiedURL = components.URL;
    if (modifiedURL != nil) {
        self.URL = modifiedURL;
    }
}

- (void)replaceHostWith:(NSString *)host {
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.URL resolvingAgainstBaseURL:YES];
    components.host = host;
    
    if(components != nil) {
        self.URL = components.URL;
    }
}

@end
