#import <Foundation/Foundation.h>

@class ARTPushActivationStateMachine;
@class ARTPushActivationEvent;

@protocol ARTHTTPAuthenticatedExecutor;

NS_ASSUME_NONNULL_BEGIN

@interface ARTPushActivationState : NSObject <NSSecureCoding>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithMachine:(ARTPushActivationStateMachine *)machine;
+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)newWithMachine:(ARTPushActivationStateMachine *)machine;

@property (atomic, strong, nullable) ARTPushActivationStateMachine *machine;

- (nullable ARTPushActivationState *)transition:(ARTPushActivationEvent *)event;

- (NSData *)archive;
+ (nullable ARTPushActivationState *)unarchive:(NSData *)data;

@end

/// Persistent State
@interface ARTPushActivationPersistentState : ARTPushActivationState
@end

#pragma mark - States

@interface ARTPushActivationStateNotActivated : ARTPushActivationPersistentState
@end

@interface ARTPushActivationStateWaitingForDeviceRegistration : ARTPushActivationState
@end

@interface ARTPushActivationStateWaitingForPushDeviceDetails : ARTPushActivationPersistentState
@end

@interface ARTPushActivationStateWaitingForNewPushDeviceDetails : ARTPushActivationPersistentState
@end

@interface ARTPushActivationStateWaitingForRegistrationSync : ARTPushActivationState

- (instancetype)initWithMachine:(ARTPushActivationStateMachine *)machine NS_UNAVAILABLE;
+ (instancetype)newWithMachine:(ARTPushActivationStateMachine *)machine NS_UNAVAILABLE;

- (instancetype)initWithMachine:(ARTPushActivationStateMachine *)machine fromEvent:(ARTPushActivationEvent *)event;
+ (instancetype)newWithMachine:(ARTPushActivationStateMachine *)machine fromEvent:(ARTPushActivationEvent *)event;

@property (atomic, strong) ARTPushActivationEvent *fromEvent;

@end

@interface ARTPushActivationStateAfterRegistrationSyncFailed : ARTPushActivationPersistentState
@end

@interface ARTPushActivationStateWaitingForDeregistration : ARTPushActivationState
@end

// Deprecated states; kept around for persistence backwards-compatibility

@interface ARTPushActivationDeprecatedPersistentState : ARTPushActivationPersistentState

- (instancetype)initWithMachine:(ARTPushActivationStateMachine *)machine NS_UNAVAILABLE;
+ (instancetype)newWithMachine:(ARTPushActivationStateMachine *)machine NS_UNAVAILABLE;
- (nullable ARTPushActivationPersistentState *)migrate;

@end

@interface ARTPushActivationStateAfterRegistrationUpdateFailed : ARTPushActivationDeprecatedPersistentState
@end

NS_ASSUME_NONNULL_END
