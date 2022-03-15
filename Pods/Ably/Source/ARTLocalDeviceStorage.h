#import <Foundation/Foundation.h>
#import <Ably/ARTDeviceStorage.h>

@class ARTLog;

NS_ASSUME_NONNULL_BEGIN

@interface ARTLocalDeviceStorage : NSObject<ARTDeviceStorage>

- (instancetype)initWithLogger:(ARTLog *)logger;

+ (instancetype)newWithLogger:(ARTLog *)logger;

@end

NS_ASSUME_NONNULL_END
