#import "ARTChannelOptions.h"

#import "ARTEncoder.h"

@implementation ARTChannelOptions

- (instancetype)initWithCipher:(id<ARTCipherParamsCompatible>)cipherParams {
    if (self = [super init]) {
        self->_cipher = [cipherParams toCipherParams];
    }
    return self;
}

- (instancetype)initWithCipherKey:(id<ARTCipherKeyCompatible>)key {
    return [self initWithCipher:@{@"key": key}];
}

@end
