#import <Ably/ARTPresence.h>
#import <Ably/ARTChannel.h>

@interface ARTPresenceQuery ()

- (NSMutableArray<NSURLQueryItem *> *)asQueryItems;

@end

@interface ARTPresence ()

@property (readonly, getter=getChannel) ARTChannel *channel;

- (instancetype)initWithChannel:(ARTChannel *)channel;

@end
