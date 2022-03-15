#import "ARTConnection+Private.h"

#import "ARTRealtime+Private.h"
#import "ARTEventEmitter+Private.h"
#import "ARTQueuedDealloc.h"

@implementation ARTConnection {
    ARTQueuedDealloc *_dealloc;
}

- (ARTConnectionInternal *_Nonnull)internal_nosync {
    return _internal;
}

- (NSString *)id {
    return _internal.id;
}

- (NSString *)key {
    return _internal.key;
}

- (NSString *)recoveryKey {
    return _internal.recoveryKey;
}

- (int64_t)serial {
    return _internal.serial;
}

- (NSInteger)maxMessageSize {
    return _internal.maxMessageSize;
}

- (ARTRealtimeConnectionState)state {
    return _internal.state;
}

- (ARTErrorInfo *)errorReason {
    return _internal.errorReason;
}

- (instancetype)initWithInternal:(ARTConnectionInternal *)internal queuedDealloc:(ARTQueuedDealloc *)dealloc {
    self = [super init];
    if (self) {
        _internal = internal;
        _dealloc = dealloc;
    }
    return self;
}

- (void)close {
    [_internal close];
}

- (void)connect {
    [_internal connect];
}

- (void)off {
    [_internal off];
}

- (void)off:(nonnull ARTEventListener *)listener {
    [_internal off:listener];
}

- (void)off:(ARTRealtimeConnectionEvent)event listener:(nonnull ARTEventListener *)listener {
    [_internal off:event listener:listener];
}

- (nonnull ARTEventListener *)on:(nonnull ARTConnectionStateCallback)cb {
    return [_internal on:cb];
}

- (nonnull ARTEventListener *)on:(ARTRealtimeConnectionEvent)event callback:(nonnull ARTConnectionStateCallback)cb {
    return [_internal on:event callback:cb];
}

- (nonnull ARTEventListener *)once:(nonnull ARTConnectionStateCallback)cb {
    return [_internal once:cb];
}

- (nonnull ARTEventListener *)once:(ARTRealtimeConnectionEvent)event callback:(nonnull ARTConnectionStateCallback)cb {
    return [_internal once:event callback:cb];
}

- (void)ping:(nonnull ARTCallback)cb {
    [_internal ping:cb];
}

@end

@implementation ARTConnectionInternal {
    _Nonnull dispatch_queue_t _queue;
    NSString *_id;
    NSString *_key;
    NSInteger _maxMessageSize;
    int64_t _serial;
    ARTRealtimeConnectionState _state;
    ARTErrorInfo *_errorReason;
}

- (instancetype)initWithRealtime:(ARTRealtimeInternal *)realtime {
    if (self = [super init]) {
        _eventEmitter = [[ARTPublicEventEmitter alloc] initWithRest:realtime.rest];
        _realtime = realtime;
        _queue = _realtime.rest.queue;
        _serial = -1;
    }
    return self;
}

- (void)connect {
    [_realtime connect];
}

- (void)close {
    [_realtime close];
}

- (void)ping:(ARTCallback)cb {
    [_realtime ping:cb];
}

- (NSString *)id {
    __block NSString *ret;   
dispatch_sync(_queue, ^{
    ret = [self id_nosync];
});
    return ret;
} 

- (NSString *)key {
    __block NSString *ret;   
dispatch_sync(_queue, ^{
    ret = [self key_nosync];
});
    return ret;
} 

- (int64_t)serial {
    __block int64_t ret;   
dispatch_sync(_queue, ^{
    ret = [self serial_nosync];
});
    return ret;
} 

- (ARTRealtimeConnectionState)state {
    __block ARTRealtimeConnectionState ret;   
dispatch_sync(_queue, ^{
    ret = [self state_nosync];
});
    return ret;
}

- (ARTErrorInfo *)errorReason {
    __block ARTErrorInfo *ret;   
dispatch_sync(_queue, ^{
    ret = [self errorReason_nosync];
});
    return ret;
}

- (ARTErrorInfo *)error_nosync {
    if (self.errorReason_nosync) {
        return self.errorReason_nosync;
    }
    switch (self.state_nosync) {
        case ARTRealtimeDisconnected:
            return [ARTErrorInfo createWithCode:ARTErrorDisconnected status:400 message:@"Connection to server temporarily unavailable"];
        case ARTRealtimeSuspended:
            return [ARTErrorInfo createWithCode:ARTErrorConnectionSuspended status:400 message:@"Connection to server unavailable"];
        case ARTRealtimeFailed:
            return [ARTErrorInfo createWithCode:ARTErrorConnectionFailed status:400 message:@"Connection failed or disconnected by server"];
        case ARTRealtimeClosing:
            return [ARTErrorInfo createWithCode:ARTErrorConnectionClosed status:400 message:@"Connection closing"];
        case ARTRealtimeClosed:
            return [ARTErrorInfo createWithCode:ARTErrorDisconnected status:400 message:@"Connection closed"];
        default:
            return [ARTErrorInfo createWithCode:ARTErrorInvalidTransportHandle status:400 message:[NSString stringWithFormat:@"Invalid operation (connection state is %lu - %@)", (unsigned long)self.state_nosync, ARTRealtimeConnectionStateToStr(self.state_nosync)]];
    }
}

- (BOOL)isActive_nosync {
    return self.realtime.isActive;
}

- (NSString *)id_nosync {
    return _id;
} 

- (NSString *)key_nosync {
    return _key;
} 

- (int64_t)serial_nosync {
    return _serial;
} 

- (ARTRealtimeConnectionState)state_nosync {
    return _state;
}

- (ARTErrorInfo *)errorReason_nosync {
    return _errorReason;
}

- (void)setId:(NSString *)newId {
    _id = newId;
}

- (void)setKey:(NSString *)key {
    _key = key;
}

- (void)setSerial:(int64_t)serial {
    _serial = serial;
}

- (void)setMaxMessageSize:(NSInteger)maxMessageSize {
    _maxMessageSize = maxMessageSize;
}

- (void)setState:(ARTRealtimeConnectionState)state {
    _state = state;
}

- (void)setErrorReason:(ARTErrorInfo *_Nullable)errorReason {
    _errorReason = errorReason;
}

- (NSString *)recoveryKey {
    __block NSString *ret;
dispatch_sync(_queue, ^{
    ret = [self recoveryKey_nosync];
});
    return ret;
}

- (NSString *)recoveryKey_nosync {
    switch(self.state_nosync) {
        case ARTRealtimeConnecting:
        case ARTRealtimeConnected:
        case ARTRealtimeDisconnected:
        case ARTRealtimeSuspended: {
            return [self.key_nosync stringByAppendingString:[NSString stringWithFormat:@":%ld:%ld", (long)self.serial_nosync, (long)_realtime.msgSerial]];
        }
        default: {
            return nil;
        }
    }
}

- (ARTEventListener *)on:(ARTRealtimeConnectionEvent)event callback:(ARTConnectionStateCallback)cb {
    return [_eventEmitter on:[ARTEvent newWithConnectionEvent:event] callback:cb];
}

- (ARTEventListener *)on:(ARTConnectionStateCallback)cb {
    return [_eventEmitter on:cb];
}

- (ARTEventListener *)once:(ARTRealtimeConnectionEvent)event callback:(ARTConnectionStateCallback)cb {
    return [_eventEmitter once:[ARTEvent newWithConnectionEvent:event] callback:cb];
}

- (ARTEventListener *)once:(ARTConnectionStateCallback)cb {
    return [_eventEmitter once:cb];
}

- (void)off {
    if (_realtime && _realtime.rest) {
        [_eventEmitter off];
    } else {
        [_eventEmitter off];
    }
}
- (void)off:(ARTRealtimeConnectionEvent)event listener:(ARTEventListener *)listener {
    [_eventEmitter off:[ARTEvent newWithConnectionEvent:event] listener:listener];
}

- (void)off:(ARTEventListener *)listener {
    [_eventEmitter off:listener];
}

- (void)emit:(ARTRealtimeConnectionEvent)event with:(ARTConnectionStateChange *)data {
    [_eventEmitter emit:[ARTEvent newWithConnectionEvent:event] with:data];
}

@end

#pragma mark - ARTEvent

@implementation ARTEvent (ConnectionEvent)

- (instancetype)initWithConnectionEvent:(ARTRealtimeConnectionEvent)value {
    return [self initWithString:[NSString stringWithFormat:@"ARTRealtimeConnectionEvent%@", ARTRealtimeConnectionEventToStr(value)]];
}

+ (instancetype)newWithConnectionEvent:(ARTRealtimeConnectionEvent)value {
    return [[self alloc] initWithConnectionEvent:value];
}

@end
