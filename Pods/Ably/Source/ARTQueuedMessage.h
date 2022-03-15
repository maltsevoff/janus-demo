#import <Foundation/Foundation.h>
#import <Ably/ARTTypes.h>

@class ARTProtocolMessage;

NS_ASSUME_NONNULL_BEGIN

@interface ARTQueuedMessage : NSObject

@property (readonly, strong, nonatomic) ARTProtocolMessage *msg;
@property (readonly, strong, nonatomic) NSMutableArray *sentCallbacks;
@property (readonly, strong, nonatomic) NSMutableArray *ackCallbacks;

- (instancetype)initWithProtocolMessage:(ARTProtocolMessage *)msg sentCallback:(nullable ARTCallback)sentCallback ackCallback:(nullable ARTStatusCallback)ackCallback;

- (BOOL)mergeFrom:(ARTProtocolMessage *)msg sentCallback:(nullable ARTCallback)sentCallback ackCallback:(nullable ARTStatusCallback)ackCallback;

- (ARTCallback)sentCallback;
- (ARTStatusCallback)ackCallback;

@end

NS_ASSUME_NONNULL_END
