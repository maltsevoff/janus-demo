#import "ARTURLSessionServerTrust.h"

@interface ARTURLSessionServerTrust() {
    NSURLSession *_session;
    dispatch_queue_t _queue;
}

@end

@implementation ARTURLSessionServerTrust

- (instancetype)init:(dispatch_queue_t)queue {
    if (self = [super init]) {
        _queue = queue;
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
#if TARGET_OS_MACCATALYST // if (@available(iOS 13.0, macCatalyst 13.0, ... doesn't help
        config.TLSMinimumSupportedProtocolVersion = tls_protocol_version_TLSv12;
#else
        if (@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)) {
            config.TLSMinimumSupportedProtocolVersion = tls_protocol_version_TLSv12;
        } else {
            config.TLSMinimumSupportedProtocol = kTLSProtocol12;
        }
#endif
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return self;
}

- (dispatch_queue_t)queue {
    return _queue;
}

- (void)finishTasksAndInvalidate {
    [_session finishTasksAndInvalidate];
}

- (NSObject<ARTCancellable> *)get:(NSURLRequest *)request completion:(ARTURLRequestCallback)callback {
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(self->_queue, ^{
            callback((NSHTTPURLResponse *)response, data, error);
        });
    }];
    [task resume];
    return task;
}

@end
