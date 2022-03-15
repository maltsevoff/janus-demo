#import "ARTPushDeviceRegistrations+Private.h"
#import "ARTHttp.h"
#import "ARTLog.h"
#import "ARTPaginatedResult+Private.h"
#import "ARTDeviceDetails.h"
#import "ARTDevicePushDetails.h"
#import "ARTDeviceIdentityTokenDetails.h"
#import "ARTClientOptions.h"
#import "ARTEncoder.h"
#import "ARTRest+Private.h"
#import "ARTLocalDevice.h"
#import "ARTNSMutableRequest+ARTPush.h"

@implementation ARTPushDeviceRegistrations {
    ARTQueuedDealloc *_dealloc;
}

- (instancetype)initWithInternal:(ARTPushDeviceRegistrationsInternal *)internal queuedDealloc:(ARTQueuedDealloc *)dealloc {
    self = [super init];
    if (self) {
        _internal = internal;
        _dealloc = dealloc;
    }
    return self;
}

- (void)save:(ARTDeviceDetails *)deviceDetails callback:(ARTCallback)callback {
    [_internal save:deviceDetails callback:callback];
}

- (void)get:(ARTDeviceId *)deviceId callback:(void (^)(ARTDeviceDetails *_Nullable,  ARTErrorInfo *_Nullable))callback {
    [_internal get:deviceId callback:callback];
}

- (void)list:(NSStringDictionary *)params callback:(ARTPaginatedDeviceDetailsCallback)callback {
    [_internal list:params callback:callback];
}

- (void)remove:(NSString *)deviceId callback:(ARTCallback)callback {
    [_internal remove:deviceId callback:callback];
}

- (void)removeWhere:(NSStringDictionary *)params callback:(ARTCallback)callback {
    [_internal removeWhere:params callback:callback];
}

@end

@implementation ARTPushDeviceRegistrationsInternal {
    __weak ARTRestInternal *_rest; // weak because rest owns self
    ARTLog* _logger;
    dispatch_queue_t _queue;
    dispatch_queue_t _userQueue;
}

- (instancetype)initWithRest:(ARTRestInternal *)rest {
    if (self = [super init]) {
        _rest = rest;
        _logger = [rest logger];
        _queue = rest.queue;
        _userQueue = rest.userQueue;
    }
    return self;
}

- (void)save:(ARTDeviceDetails *)deviceDetails callback:(ARTCallback)callback {
    if (callback) {
        ARTCallback userCallback = callback;
        callback = ^(ARTErrorInfo *error) {
            dispatch_async(self->_userQueue, ^{
                userCallback(error);
            });
        };
    }

    #if TARGET_OS_IOS
    ARTLocalDevice *local = _rest.device;
    #else
    ARTLocalDevice *local = nil;
    #endif

dispatch_async(_queue, ^{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[[NSURL URLWithString:@"/push/deviceRegistrations"] URLByAppendingPathComponent:deviceDetails.id] resolvingAgainstBaseURL:NO];
    if (self->_rest.options.pushFullWait) {
        components.queryItems = @[[NSURLQueryItem queryItemWithName:@"fullWait" value:@"true"]];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[components URL]];
    request.HTTPMethod = @"PUT";
    request.HTTPBody = [[self->_rest defaultEncoder] encodeDeviceDetails:deviceDetails error:nil];
    [request setValue:[[self->_rest defaultEncoder] mimeType] forHTTPHeaderField:@"Content-Type"];
    [request setDeviceAuthentication:deviceDetails.id localDevice:local logger:self->_logger];

    [self->_logger debug:__FILE__ line:__LINE__ message:@"save device with request %@", request];
    [self->_rest executeRequest:request withAuthOption:ARTAuthenticationOn completion:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        if (response.statusCode == 200 /*OK*/) {
            NSError *decodeError = nil;
            ARTDeviceDetails *deviceDetails = [[self->_rest defaultEncoder] decodeDeviceDetails:data error:&decodeError];
            if (decodeError) {
                [self->_logger debug:__FILE__ line:__LINE__ message:@"%@: decode device failed (%@)", NSStringFromClass(self.class), error.localizedDescription];
                callback([ARTErrorInfo createFromNSError:decodeError]);
            }
            else {
                [self->_logger debug:__FILE__ line:__LINE__ message:@"%@: successfully saved device %@", NSStringFromClass(self.class), deviceDetails.id];
                callback(nil);
            }
        }
        else if (error) {
            [self->_logger error:@"%@: save device failed (%@)", NSStringFromClass(self.class), error.localizedDescription];
            callback([ARTErrorInfo createFromNSError:error]);
        }
        else {
            [self->_logger error:@"%@: save device failed with status code %ld", NSStringFromClass(self.class), (long)response.statusCode];
            NSString *plain = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback([ARTErrorInfo createWithCode:response.statusCode*100 status:response.statusCode message:[plain art_shortString]]);
        }
    }];
});
}

- (void)get:(ARTDeviceId *)deviceId callback:(void (^)(ARTDeviceDetails *, ARTErrorInfo *))callback {
    if (callback) {
        void (^userCallback)(ARTDeviceDetails *, ARTErrorInfo *error) = callback;
        callback = ^(ARTDeviceDetails *device, ARTErrorInfo *error) {
            dispatch_async(self->_userQueue, ^{
                userCallback(device, error);
            });
        };
    }

    #if TARGET_OS_IOS
    ARTLocalDevice *local = _rest.device;
    #else
    ARTLocalDevice *local = nil;
    #endif

dispatch_async(_queue, ^{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL URLWithString:@"/push/deviceRegistrations"] URLByAppendingPathComponent:deviceId]];
    request.HTTPMethod = @"GET";
    [request setDeviceAuthentication:deviceId localDevice:local logger:self->_logger];

    [self->_logger debug:__FILE__ line:__LINE__ message:@"get device with request %@", request];
    [self->_rest executeRequest:request withAuthOption:ARTAuthenticationOn completion:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        if (response.statusCode == 200 /*OK*/) {
            NSError *decodeError = nil;
            ARTDeviceDetails *device = [self->_rest.encoders[response.MIMEType] decodeDeviceDetails:data error:&decodeError];
            if (decodeError) {
                [self->_logger debug:__FILE__ line:__LINE__ message:@"%@: decode device failed (%@)", NSStringFromClass(self.class), error.localizedDescription];
                callback(nil, [ARTErrorInfo createFromNSError:decodeError]);
            }
            else if (device) {
                [self->_logger debug:__FILE__ line:__LINE__ message:@"%@: get device successfully", NSStringFromClass(self.class)];
                callback(device, nil);
            }
            else {
                [self->_logger debug:__FILE__ line:__LINE__ message:@"%@: get device failed with unknown error", NSStringFromClass(self.class)];
                callback(nil, [ARTErrorInfo createUnknownError]);
            }
        }
        else if (error) {
            [self->_logger error:@"%@: get device failed (%@)", NSStringFromClass(self.class), error.localizedDescription];
            callback(nil, [ARTErrorInfo createFromNSError:error]);
        }
        else {
            [self->_logger error:@"%@: get device failed with status code %ld", NSStringFromClass(self.class), (long)response.statusCode];
            NSString *plain = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback(nil, [ARTErrorInfo createWithCode:response.statusCode*100 status:response.statusCode message:[plain art_shortString]]);
        }
    }];
});
}

- (void)list:(NSStringDictionary *)params callback:(ARTPaginatedDeviceDetailsCallback)callback {
    if (callback) {
        void (^userCallback)(ARTPaginatedResult *, ARTErrorInfo *error) = callback;
        callback = ^(ARTPaginatedResult *result, ARTErrorInfo *error) {
            dispatch_async(self->_userQueue, ^{
                userCallback(result, error);
            });
        };
    }

dispatch_async(_queue, ^{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:@"/push/deviceRegistrations"] resolvingAgainstBaseURL:NO];
    components.queryItems = [params art_asURLQueryItems];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[components URL]];
    request.HTTPMethod = @"GET";

    ARTPaginatedResultResponseProcessor responseProcessor = ^(NSHTTPURLResponse *response, NSData *data, NSError **error) {
        return [self->_rest.encoders[response.MIMEType] decodeDevicesDetails:data error:error];
    };
    [ARTPaginatedResult executePaginated:self->_rest withRequest:request andResponseProcessor:responseProcessor callback:callback];
});
}

- (void)remove:(NSString *)deviceId callback:(ARTCallback)callback {
    if (callback) {
        ARTCallback userCallback = callback;
        callback = ^(ARTErrorInfo *error) {
            dispatch_async(self->_userQueue, ^{
                userCallback(error);
            });
        };
    }

dispatch_async(_queue, ^{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[[NSURL URLWithString:@"/push/deviceRegistrations"] URLByAppendingPathComponent:deviceId] resolvingAgainstBaseURL:NO];
        if (self->_rest.options.pushFullWait) {
        components.queryItems = @[[NSURLQueryItem queryItemWithName:@"fullWait" value:@"true"]];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[components URL]];
    request.HTTPMethod = @"DELETE";
    [request setValue:[[self->_rest defaultEncoder] mimeType] forHTTPHeaderField:@"Content-Type"];

    [self->_logger debug:__FILE__ line:__LINE__ message:@"remove device with request %@", request];
    [self->_rest executeRequest:request withAuthOption:ARTAuthenticationOn completion:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        if (response.statusCode == 200 /*Ok*/ || response.statusCode == 204 /*not returning any content*/) {
            [self->_logger debug:__FILE__ line:__LINE__ message:@"%@: save device successfully", NSStringFromClass(self.class)];
            callback(nil);
        }
        else if (error) {
            [self->_logger error:@"%@: remove device failed (%@)", NSStringFromClass(self.class), error.localizedDescription];
            callback([ARTErrorInfo createFromNSError:error]);
        }
        else {
            [self->_logger error:@"%@: remove device failed with status code %ld", NSStringFromClass(self.class), (long)response.statusCode];
            NSString *plain = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback([ARTErrorInfo createWithCode:response.statusCode*100 status:response.statusCode message:[plain art_shortString]]);
        }
    }];
});
}

- (void)removeWhere:(NSStringDictionary *)params callback:(ARTCallback)callback {
    if (callback) {
        ARTCallback userCallback = callback;
        callback = ^(ARTErrorInfo *error) {
            dispatch_async(self->_userQueue, ^{
                userCallback(error);
            });
        };
    }

    #if TARGET_OS_IOS
    ARTLocalDevice *local = _rest.device;
    #else
    ARTLocalDevice *local = nil;
    #endif

dispatch_async(_queue, ^{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:@"/push/deviceRegistrations"] resolvingAgainstBaseURL:NO];
    components.queryItems = [params art_asURLQueryItems];
    if (self->_rest.options.pushFullWait) {
        components.queryItems = [components.queryItems arrayByAddingObject:[NSURLQueryItem queryItemWithName:@"fullWait" value:@"true"]];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[components URL]];
    request.HTTPMethod = @"DELETE";
    [request setDeviceAuthentication:[params objectForKey:@"deviceId"] localDevice:local];

    [self->_logger debug:__FILE__ line:__LINE__ message:@"remove devices with request %@", request];
    [self->_rest executeRequest:request withAuthOption:ARTAuthenticationOn completion:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        if (response.statusCode == 200 /*Ok*/ || response.statusCode == 204 /*not returning any content*/) {
            [self->_logger debug:__FILE__ line:__LINE__ message:@"%@: remove devices successfully", NSStringFromClass(self.class)];
            callback(nil);
        }
        else if (error) {
            [self->_logger error:@"%@: remove devices failed (%@)", NSStringFromClass(self.class), error.localizedDescription];
            callback([ARTErrorInfo createFromNSError:error]);
        }
        else {
            [self->_logger error:@"%@: remove devices failed with status code %ld", NSStringFromClass(self.class), (long)response.statusCode];
            NSString *plain = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback([ARTErrorInfo createWithCode:response.statusCode*100 status:response.statusCode message:[plain art_shortString]]);
        }
    }];
});
}

@end
