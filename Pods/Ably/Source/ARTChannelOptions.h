#import <Foundation/Foundation.h>

#import <Ably/ARTTypes.h>
#import <Ably/ARTCrypto.h>

NS_ASSUME_NONNULL_BEGIN

/**
 ARTChannelOptions are used for setting channel parameters and configuring encryption.
 */
@interface ARTChannelOptions : NSObject

@property (nonatomic, strong, nullable) ARTCipherParams *cipher;

- (instancetype)initWithCipher:(id<ARTCipherParamsCompatible> _Nullable)cipherParams;
- (instancetype)initWithCipherKey:(id<ARTCipherKeyCompatible>)key;

@end

NS_ASSUME_NONNULL_END
