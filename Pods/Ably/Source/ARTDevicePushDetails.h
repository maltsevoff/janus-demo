#import <Foundation/Foundation.h>

@class ARTErrorInfo;

NS_ASSUME_NONNULL_BEGIN

@interface ARTDevicePushDetails : NSObject

@property (nonatomic) NSMutableDictionary<NSString *, NSString *> *recipient;
@property (nullable, nonatomic) NSString *state;
@property (nullable, nonatomic) ARTErrorInfo *errorReason;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
