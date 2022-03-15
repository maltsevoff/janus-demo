#import <Foundation/Foundation.h>

@interface ARTStringifiable()

- (nonnull instancetype)initWithString:(nonnull NSString *)value;
- (nonnull instancetype)initWithNumber:(nonnull NSNumber *)value;
- (nonnull instancetype)initWithBool:(BOOL)value;

@end
