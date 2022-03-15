#import <Foundation/Foundation.h>

@interface NSArray (ARTFunctional)

- (NSArray *)artMap:(id(^)(id))f;
- (NSArray *)artFilter:(BOOL(^)(id))f;

@end
