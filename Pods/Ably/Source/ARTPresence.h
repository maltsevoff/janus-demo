#import <Foundation/Foundation.h>

#import <Ably/ARTTypes.h>
#import <Ably/ARTPresenceMessage.h>
#import <Ably/ARTPaginatedResult.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARTPresence : NSObject

- (void)history:(ARTPaginatedPresenceCallback)callback;

@end

NS_ASSUME_NONNULL_END
