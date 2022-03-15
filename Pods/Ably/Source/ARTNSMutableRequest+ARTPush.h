#import <Foundation/Foundation.h>

#import <Ably/ARTTypes.h>

@class ARTLog;
@class ARTLocalDevice;

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableURLRequest (ARTPush)

- (void)setDeviceAuthentication:(ARTDeviceId *)deviceId localDevice:(ARTLocalDevice *)localDevice;
- (void)setDeviceAuthentication:(ARTDeviceId *)deviceId localDevice:(ARTLocalDevice *)localDevice logger:(nullable ARTLog *)logger;
- (void)setDeviceAuthentication:(ARTLocalDevice *)localDevice;
- (void)setDeviceAuthentication:(ARTLocalDevice *)localDevice logger:(nullable ARTLog *)logger;

@end

NS_ASSUME_NONNULL_END
