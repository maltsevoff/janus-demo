#import <Foundation/Foundation.h>

@interface ARTScheduledBlockHandle : NSObject
- (instancetype)initWithDelay:(NSTimeInterval)delay queue:(dispatch_queue_t)queue block:(dispatch_block_t)block;
- (void)cancel;
@end

ARTScheduledBlockHandle *artDispatchScheduled(NSTimeInterval seconds, dispatch_queue_t queue, dispatch_block_t block);
static inline void artDispatchCancel(ARTScheduledBlockHandle *handle) {
    if (handle) {
        [handle cancel];
    }
}
