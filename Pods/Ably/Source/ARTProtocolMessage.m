#import "ARTDefault.h"
#import "ARTProtocolMessage.h"
#import "ARTProtocolMessage+Private.h"
#import "ARTStatus.h"
#import "ARTConnectionDetails.h"
#import "ARTNSString+ARTUtil.h"
#import "ARTNSArray+ARTFunctional.h"

@implementation ARTProtocolMessage

- (id)init {
    self = [super init];
    if (self) {
        _count = 0;
        _id = nil;
        _channel = nil;
        _channelSerial = nil;
        _connectionId = nil;
        _connectionKey = nil;
        _connectionSerial = 0;
        _hasConnectionSerial = false;
        _msgSerial = nil;
        _timestamp = nil;
        _messages = nil;
        _presence = nil;
        _flags = 0;
        _error = nil;
        _connectionDetails = nil;
    }
    return self;
}

- (NSString *)getConnectionKey {
    if (_connectionDetails && _connectionDetails.connectionKey) {
        return _connectionDetails.connectionKey;
    }
    return _connectionKey;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: %p> {\n", self.class, self];
    [description appendFormat:@" count: %d,\n", self.count];
    [description appendFormat:@" id: %@,\n", self.id];
    [description appendFormat:@" action: %lu (%@),\n", (unsigned long)self.action, ARTProtocolMessageActionToStr(self.action)];
    [description appendFormat:@" channel: %@,\n", self.channel];
    [description appendFormat:@" channelSerial: %@,\n", self.channelSerial];
    [description appendFormat:@" connectionId: %@,\n", self.connectionId];
    [description appendFormat:@" connectionKey: %@,\n", self.connectionKey];
    [description appendFormat:@" connectionSerial: %lld,\n", self.connectionSerial];
    [description appendFormat:@" msgSerial: %@,\n", self.msgSerial];
    [description appendFormat:@" timestamp: %@,\n", self.timestamp];
    [description appendFormat:@" flags: %lld,\n", self.flags];
    [description appendFormat:@" flags.hasPresence: %@,\n", NSStringFromBOOL(self.hasPresence)];
    [description appendFormat:@" flags.hasBacklog: %@,\n", NSStringFromBOOL(self.hasBacklog)];
    [description appendFormat:@" flags.resumed: %@,\n", NSStringFromBOOL(self.resumed)];
    [description appendFormat:@" messages: %@\n", self.messages];
    [description appendFormat:@" params: %@\n", self.params];
    [description appendFormat:@"}"];
    return description;
}

- (id)copyWithZone:(NSZone *)zone {
    ARTProtocolMessage *pm = [[[self class] allocWithZone:zone] init];
    pm.action = self.action;
    pm.count = self.count;
    pm.id = self.id;
    pm.channel = self.channel;
    pm.channelSerial = self.channelSerial;
    pm.connectionId = self.connectionId;
    pm.connectionKey = self.connectionKey;
    pm.connectionSerial = self.connectionSerial;
    pm.hasConnectionSerial = self.hasConnectionSerial;
    pm.msgSerial = self.msgSerial;
    pm.timestamp = self.timestamp;
    pm.messages = self.messages;
    pm.presence = self.presence;
    pm.flags = self.flags;
    pm.error = self.error;
    pm.connectionDetails = self.connectionDetails;
    pm.params = self.params;
    return pm;
}

 - (BOOL)mergeFrom:(ARTProtocolMessage *)src {
     if (![src.channel isEqualToString:self.channel] || src.action != self.action) {
         // RTL6d3
         return NO;
     }
     if ([self mergeWouldExceedMaxSize:src.messages]) {
         // RTL6d1
         return NO;
     }
     if ([self clientIdsAreDifferent:src.messages]) {
         // RTL6d2
         return NO;
     }

     NSArray *proposed = nil;
     switch (self.action) {
         // RTL6d4, RTL6d6
         case ARTProtocolMessageMessage:
             proposed = [self.messages arrayByAddingObjectsFromArray:src.messages];
             break;
         case ARTProtocolMessagePresence:
             proposed = [self.presence arrayByAddingObjectsFromArray:src.presence];
             break;
         default:
             proposed = nil;
             return NO;
     }

     NSUInteger ids = [proposed artFilter:^BOOL(ARTMessage *message) {
         return message.id != nil;
     }].count;
     if (ids > 0) {
         // RTL6d7
         return NO;
     }

     switch (self.action) {
         case ARTProtocolMessageMessage:
             self.messages = proposed;
             return YES;
         case ARTProtocolMessagePresence:
             self.presence = proposed;
             return YES;
         default:
             return NO;
     }
}

- (BOOL)clientIdsAreDifferent:(NSArray<ARTMessage*>*)messages {
    NSMutableSet *queuedClientIds = [NSMutableSet new];
    NSMutableSet *incomingClientIds = [NSMutableSet new];
    for (ARTMessage *message in self.messages) {
        [queuedClientIds addObject:[NSString nilToEmpty:message.clientId]];
    }
    for (ARTMessage *message in messages) {
        [incomingClientIds addObject:[NSString nilToEmpty:message.clientId]];
    }
    [queuedClientIds unionSet:incomingClientIds];
    if (queuedClientIds.count == 1) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)mergeWouldExceedMaxSize:(NSArray<ARTMessage*>*)messages {
    NSInteger queuedMessagesSize = 0;
    for (ARTMessage *message in self.messages) {
        queuedMessagesSize += [message messageSize];
    }
    NSInteger messagesSize = 0;
    for (ARTMessage *message in messages) {
        messagesSize += [message messageSize];
    }
    NSInteger totalSize = queuedMessagesSize + messagesSize;
    NSInteger maxSize = [ARTDefault maxMessageSize];
    if (_connectionDetails.maxMessageSize) {
        maxSize = _connectionDetails.maxMessageSize;
    }
    return totalSize > maxSize;
}

- (void)setConnectionSerial:(int64_t)connectionSerial {
    _connectionSerial =connectionSerial;
    _hasConnectionSerial = true;
}

- (BOOL)ackRequired {
    return self.action == ARTProtocolMessageMessage || self.action == ARTProtocolMessagePresence;
}

- (BOOL)hasPresence {
    return self.flags & ARTProtocolMessageFlagHasPresence;
}

- (BOOL)hasBacklog {
    return self.flags & ARTProtocolMessageFlagHasBacklog;
}

- (BOOL)resumed {
    return self.flags & ARTProtocolMessageFlagResumed;
}

- (ARTConnectionDetails *)getConnectionDetails {
    return _connectionDetails;
}

@end

NSString* ARTProtocolMessageActionToStr(ARTProtocolMessageAction action) {
    switch(action) {
        case ARTProtocolMessageHeartbeat:
            return @"Heartbeat"; //0
        case ARTProtocolMessageAck:
            return @"Ack"; //1
        case ARTProtocolMessageNack:
            return @"Nack"; //2
        case ARTProtocolMessageConnect:
            return @"Connect"; //3
        case ARTProtocolMessageConnected:
            return @"Connected"; //4
        case ARTProtocolMessageDisconnect:
            return @"Disconnect"; //5
        case ARTProtocolMessageDisconnected:
            return @"Disconnected"; //6
        case ARTProtocolMessageClose:
            return @"Close"; //7
        case ARTProtocolMessageClosed:
            return @"Closed"; //8
        case ARTProtocolMessageError:
            return @"Error"; //9
        case ARTProtocolMessageAttach:
            return @"Attach"; //10
        case ARTProtocolMessageAttached:
            return @"Attached"; //11
        case ARTProtocolMessageDetach:
            return @"Detach"; //12
        case ARTProtocolMessageDetached:
            return @"Detached"; //13
        case ARTProtocolMessagePresence:
            return @"Presence"; //14
        case ARTProtocolMessageMessage:
            return @"Message"; //15
        case ARTProtocolMessageSync:
            return @"Sync"; //16
        case ARTProtocolMessageAuth:
            return @"Auth"; //17
    }
}
