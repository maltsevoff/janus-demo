#import <Foundation/Foundation.h>
#import <Ably/ARTTypes.h>

@class ARTDeviceDetails;
@class ARTPaginatedResult;

NS_ASSUME_NONNULL_BEGIN

@protocol ARTPushDeviceRegistrationsProtocol

- (instancetype)init NS_UNAVAILABLE;

- (void)save:(ARTDeviceDetails *)deviceDetails callback:(ARTCallback)callback;

- (void)get:(ARTDeviceId *)deviceId callback:(void (^)(ARTDeviceDetails *_Nullable,  ARTErrorInfo *_Nullable))callback;

- (void)list:(NSStringDictionary *)params callback:(ARTPaginatedDeviceDetailsCallback)callback;

- (void)remove:(NSString *)deviceId callback:(ARTCallback)callback;
- (void)removeWhere:(NSStringDictionary *)params callback:(ARTCallback)callback;

@end

@interface ARTPushDeviceRegistrations : NSObject <ARTPushDeviceRegistrationsProtocol>

@end

NS_ASSUME_NONNULL_END
