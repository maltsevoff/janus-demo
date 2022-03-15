#import <Ably/ARTDefault.h>

extern NSString *const ARTDefaultProduction;
extern NSString *const ARTDefault_libraryName;
extern NSString *const ARTDefault_variant;

@interface ARTDefault (Private)

+ (void)setRealtimeRequestTimeout:(NSTimeInterval)value;
+ (void)setConnectionStateTtl:(NSTimeInterval)value;
+ (void)setMaxMessageSize:(NSInteger)value;
+ (void)setFallbackRetryTimeout:(NSTimeInterval)value;

@end
