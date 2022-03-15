#import "ARTNSMutableDictionary+ARTDictionaryUtil.h"

@implementation NSMutableDictionary (ARTDictionaryUtil)

- (void)addValueAsURLQueryItem:(NSString *)value forKey:(NSString *)key {
    self[key] = [NSURLQueryItem queryItemWithName:key value:value];
}

@end
