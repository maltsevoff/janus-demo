#include <Ably/ARTEventEmitter.h>
#include <Ably/ARTRest+Private.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ARTEventListener

@interface ARTEventListener ()

@property (nonatomic, readonly) NSString *eventId;
@property (nonatomic, readonly) NSUInteger count;
@property (nullable, nonatomic, readonly) id<NSObject> observer;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithId:(NSString *)eventId observer:(id<NSObject>)observer handler:(ARTEventEmitter *)eventHandler center:(NSNotificationCenter *)center;

- (ARTEventListener *)setTimer:(NSTimeInterval)timeoutDeadline onTimeout:(void (^)(void))timeoutBlock;
- (void)startTimer;
- (void)stopTimer;
- (void)restartTimer;

@end

@interface ARTEventEmitter<EventType, ItemType> ()

- (void)emit:(nullable EventType)event with:(nullable ItemType)data;

@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, readonly) dispatch_queue_t queue;
@property (nullable, nonatomic, readonly) dispatch_queue_t userQueue;

@property (readonly, atomic) NSMutableDictionary<NSString *, NSMutableArray<ARTEventListener *> *> *listeners;
@property (readonly, atomic) NSMutableArray<ARTEventListener *> *anyListeners;

@end

@interface ARTPublicEventEmitter<EventType:id<ARTEventIdentification>, ItemType> : ARTEventEmitter<EventType, ItemType>

- (instancetype)initWithRest:(ARTRestInternal *)rest;
- (void)off_nosync;

@end

@interface ARTInternalEventEmitter<EventType:id<ARTEventIdentification>, ItemType> : ARTEventEmitter<EventType, ItemType>

- (instancetype)initWithQueue:(dispatch_queue_t)queue;
- (instancetype)initWithQueues:(dispatch_queue_t)queue userQueue:(_Nullable dispatch_queue_t)userQueue;

@end

NS_ASSUME_NONNULL_END

