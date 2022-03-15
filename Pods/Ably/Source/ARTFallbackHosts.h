#import <Foundation/Foundation.h>

@class ARTClientOptions;

NS_ASSUME_NONNULL_BEGIN

@interface ARTFallbackHosts : NSObject

+ (nullable NSArray<NSString *> *)hostsFromOptions:(ARTClientOptions *)options;

@end

NS_ASSUME_NONNULL_END
