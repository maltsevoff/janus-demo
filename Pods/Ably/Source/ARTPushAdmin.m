#import "ARTPushAdmin.h"
#import "ARTHttp.h"
#import "ARTRest+Private.h"
#import "ARTPushDeviceRegistrations+Private.h"
#import "ARTPushChannelSubscriptions+Private.h"
#import "ARTLog.h"
#import "ARTJsonEncoder.h"
#import "ARTJsonLikeEncoder.h"

@implementation ARTPushAdmin {
    ARTQueuedDealloc *_dealloc;
}

- (instancetype)initWithInternal:(ARTPushAdminInternal *)internal queuedDealloc:(ARTQueuedDealloc *)dealloc {
    self = [super init];
    if (self) {
        _internal = internal;
        _dealloc = dealloc;
    }
    return self;
}

- (void)publish:(ARTPushRecipient *)recipient data:(ARTJsonObject *)data callback:(nullable ARTCallback)callback {
    [_internal publish:recipient data:data callback:callback];
}

- (ARTPushDeviceRegistrations *)deviceRegistrations {
    return [[ARTPushDeviceRegistrations alloc] initWithInternal:_internal.deviceRegistrations queuedDealloc:_dealloc];
}

- (ARTPushChannelSubscriptions *)channelSubscriptions {
    return [[ARTPushChannelSubscriptions alloc] initWithInternal:_internal.channelSubscriptions queuedDealloc:_dealloc];
}

@end

@implementation ARTPushAdminInternal {
    __weak ARTRestInternal *_rest; // weak because rest owns self
    ARTLog *_logger;
    dispatch_queue_t _userQueue;
    dispatch_queue_t _queue;
}

- (instancetype)initWithRest:(ARTRestInternal *)rest {
    if (self = [super init]) {
        _rest = rest;
        _logger = [rest logger];
        _deviceRegistrations = [[ARTPushDeviceRegistrationsInternal alloc] initWithRest:rest];
        _channelSubscriptions = [[ARTPushChannelSubscriptionsInternal alloc] initWithRest:rest];
        _userQueue = rest.userQueue;
        _queue = rest.queue;
    }
    return self;
}

- (void)publish:(ARTPushRecipient *)recipient data:(ARTJsonObject *)data callback:(nullable ARTCallback)callback {
    if (callback) {
        ARTCallback userCallback = callback;
        callback = ^(ARTErrorInfo *error) {
            dispatch_async(self->_userQueue, ^{
                userCallback(error);
            });
        };
    }

    dispatch_async(_queue, ^{
            if (![[recipient allKeys] count]) {
                if (callback) callback([ARTErrorInfo createWithCode:0 message:@"Recipient is missing"]);
                return;
            }

            if (![[data allKeys] count]) {
                if (callback) callback([ARTErrorInfo createWithCode:0 message:@"Data payload is missing"]);
                return;
            }

            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"/push/publish"]];
            request.HTTPMethod = @"POST";
            NSMutableDictionary *body = [NSMutableDictionary dictionary];
            [body setObject:recipient forKey:@"recipient"];
            [body addEntriesFromDictionary:data];
            request.HTTPBody = [[self->_rest defaultEncoder] encode:body error:nil];
            [request setValue:[[self->_rest defaultEncoder] mimeType] forHTTPHeaderField:@"Content-Type"];

            [self->_logger debug:__FILE__ line:__LINE__ message:@"push notification to a single device %@", request];
            [self->_rest executeRequest:request withAuthOption:ARTAuthenticationOn completion:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
                if (error) {
                    [self->_logger error:@"%@: push notification to a single device failed (%@)", NSStringFromClass(self.class), error.localizedDescription];
                    if (callback) callback([ARTErrorInfo createFromNSError:error]);
                    return;
                }
                if (callback) callback(nil);
            }];
    });
}

@end
