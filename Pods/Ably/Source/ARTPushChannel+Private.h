#ifndef ARTPushChannel_Private_h
#define ARTPushChannel_Private_h

#import <Ably/ARTPushChannel.h>
#import "ARTQueuedDealloc.h"

@class ARTRestInternal;

@interface ARTPushChannelInternal : NSObject <ARTPushChannelProtocol>

- (instancetype)init:(ARTRestInternal *)rest withChannel:(ARTChannel *)channel;

@end

@interface ARTPushChannel ()

@property (nonatomic, readonly) ARTPushChannelInternal *internal;

- (instancetype)initWithInternal:(ARTPushChannelInternal *)internal queuedDealloc:(ARTQueuedDealloc *)dealloc;

@end

#endif /* ARTPushChannel_Private_h */
