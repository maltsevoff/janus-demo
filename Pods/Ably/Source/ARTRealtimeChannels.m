#import <Foundation/Foundation.h>
#import "ARTRealtimeChannels+Private.h"
#import "ARTChannels+Private.h"
#import "ARTRealtimeChannel+Private.h"
#import "ARTRealtime+Private.h"
#import "ARTRealtimePresence+Private.h"
#import "ARTClientOptions+Private.h"

@implementation ARTRealtimeChannels {
    ARTQueuedDealloc *_dealloc;
}

- (instancetype)initWithInternal:(ARTRealtimeChannelsInternal *)internal queuedDealloc:(ARTQueuedDealloc *)dealloc {
    self = [super init];
    if (self) {
        _internal = internal;
        _dealloc = dealloc;
    }
    return self;
}

- (BOOL)exists:(NSString *)name {
    return [_internal exists:(NSString *)name];
}

- (ARTRealtimeChannel *)get:(NSString *)name {
    return [[ARTRealtimeChannel alloc] initWithInternal:[_internal get:(NSString *)name] queuedDealloc:_dealloc];
}

- (ARTRealtimeChannel *)get:(NSString *)name options:(ARTRealtimeChannelOptions *)options {
    return [[ARTRealtimeChannel alloc] initWithInternal:[_internal get:(NSString *)name options:options] queuedDealloc:_dealloc];
}

- (void)release:(NSString *)name callback:(nullable ARTCallback)errorInfo {
    [_internal release:(NSString *)name callback:errorInfo];
}

- (void)release:(NSString *)name {
    [_internal release:(NSString *)name];
}

- (id<NSFastEnumeration>)iterate {
    return [_internal copyIntoIteratorWithMapper:^ARTRealtimeChannel *(ARTRealtimeChannelInternal *internalChannel) {
        return [[ARTRealtimeChannel alloc] initWithInternal:internalChannel queuedDealloc:self->_dealloc];
    }];
}

@end

@interface ARTRealtimeChannelsInternal ()

@property (weak, nonatomic) ARTRealtimeInternal *realtime; // weak because realtime owns self

@end

@interface ARTRealtimeChannelsInternal () <ARTChannelsDelegate>
@end

@implementation ARTRealtimeChannelsInternal {
    ARTChannels *_channels;
    dispatch_queue_t _userQueue;
}

- (instancetype)initWithRealtime:(ARTRealtimeInternal *)realtime {
    if (self = [super init]) {
        _realtime = realtime;
        _userQueue = _realtime.rest.userQueue;
        _queue = _realtime.rest.queue;
        _channels = [[ARTChannels alloc] initWithDelegate:self dispatchQueue:_queue prefix:_realtime.options.channelNamePrefix];
    }
    return self;
}

- (id)makeChannel:(NSString *)name options:(ARTRealtimeChannelOptions *)options {
    return [ARTRealtimeChannelInternal channelWithRealtime:_realtime andName:name withOptions:options];
}

- (id<NSFastEnumeration>)copyIntoIteratorWithMapper:(ARTRealtimeChannel *(^)(ARTRealtimeChannelInternal *))mapper {
    return [_channels copyIntoIteratorWithMapper:mapper];
}

- (ARTRealtimeChannelInternal *)get:(NSString *)name {
    return [_channels get:name];
}

- (ARTRealtimeChannelInternal *)get:(NSString *)name options:(ARTChannelOptions *)options {
    return [_channels get:name options:options];
}

- (BOOL)exists:(NSString *)name {
    return [_channels exists:name];
}

- (void)release:(NSString *)name callback:(ARTCallback)cb {
    name = [_channels addPrefix:name];

    if (cb) {
        ARTCallback userCallback = cb;
        cb = ^(ARTErrorInfo *error) {
            dispatch_async(self->_userQueue, ^{
                userCallback(error);
            });
        };
    }

dispatch_sync(_queue, ^{
    if (![self->_channels _exists:name]) {
        if (cb) cb(nil);
        return;
    }

    ARTRealtimeChannelInternal *channel = [self->_channels _get:name];
    [channel _detach:^(ARTErrorInfo *errorInfo) {
        [channel off_nosync];
        [channel _unsubscribe];
        [channel.presence _unsubscribe];

        // Only release if the stored channel now is the same as whne.
        // Otherwise, subsequent calls to this release method race, and
        // a new channel, created between the first call releases the stored
        // one and the second call's detach callback is called, can be
        // released unwillingly.
        if ([self->_channels _exists:name] && [self->_channels _get:name] == channel) {
            [self->_channels _release:name];
        }

        if (cb) cb(errorInfo);
    }];
});
}

- (void)release:(NSString *)name {
    [self release:name callback:nil];
}

- (NSMutableDictionary *)getCollection {
    return _channels.channels;
}

- (id<NSFastEnumeration>)getNosyncIterable {
    return [_channels getNosyncIterable];
}

- (ARTRealtimeChannelInternal *)_getChannel:(NSString *)name options:(ARTChannelOptions *)options addPrefix:(BOOL)addPrefix {
    return [_channels _getChannel:name options:options addPrefix:addPrefix];
}

@end
