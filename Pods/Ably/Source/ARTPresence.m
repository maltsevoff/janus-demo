#import "ARTPresence.h"

@implementation ARTPresence

- (void)history:(ARTPaginatedPresenceCallback)callback {
    NSAssert(false, @"-[%@ %@] should always be overriden.", self.class, NSStringFromSelector(_cmd));
}

@end
