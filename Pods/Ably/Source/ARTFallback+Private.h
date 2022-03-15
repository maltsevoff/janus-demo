#include <Ably/ARTFallback.h>

NS_ASSUME_NONNULL_BEGIN

extern void (^ARTFallback_shuffleArray)(NSMutableArray *);

@interface ARTFallback ()

@property (readwrite, strong, nonatomic) NSMutableArray<NSString *> *hosts;

@end

NS_ASSUME_NONNULL_END
