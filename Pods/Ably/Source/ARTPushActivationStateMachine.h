#import <Foundation/Foundation.h>

@class ARTErrorInfo;
@class ARTPushActivationState;
@class ARTPushActivationEvent;
@class ARTRest;

@protocol ARTDeviceStorage;

NS_ASSUME_NONNULL_BEGIN

@interface ARTPushActivationStateMachine : NSObject

@property (readonly, nonatomic) ARTPushActivationEvent *lastEvent;
@property (readonly, nonatomic) ARTPushActivationState *current;
@property (readonly, nonatomic) NSMutableArray<ARTPushActivationEvent *> *pendingEvents;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)sendEvent:(ARTPushActivationEvent *)event;

@end

@interface ARTPushActivationStateMachine (Protected)
- (void)deviceRegistration:(nullable ARTErrorInfo *)error;
- (void)syncDevice;
- (void)deviceUpdateRegistration:(nullable ARTErrorInfo *)error;
- (void)deviceUnregistration:(nullable ARTErrorInfo *)error;
- (void)callActivatedCallback:(nullable ARTErrorInfo *)error;
- (void)callDeactivatedCallback:(nullable ARTErrorInfo *)error;
- (void)callUpdateFailedCallback:(nullable ARTErrorInfo *)error;
@end

NS_ASSUME_NONNULL_END
