#import "ARTPendingMessage.h"

@implementation ARTPendingMessage

- (instancetype)initWithProtocolMessage:(ARTProtocolMessage *)msg ackCallback:(nullable ARTStatusCallback)ackCallback {
    self = [super initWithProtocolMessage:msg sentCallback:nil ackCallback:ackCallback];
    return self;
}

@end
