#import <Foundation/Foundation.h>

@interface NSDictionary (ARTDictionaryUtil)

- (NSString *)artString:(id)key;
- (NSNumber *)artNumber:(id)key;
- (NSDate *)artTimestamp:(id)key;
- (NSArray *)artArray:(id)key;
- (NSDictionary *)artDictionary:(id)key;
- (NSInteger)artInteger:(id)key;

- (id)artTyped:(Class)cls key:(id)key;

@end
