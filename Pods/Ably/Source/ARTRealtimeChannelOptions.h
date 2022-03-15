#import <Foundation/Foundation.h>

#import <Ably/ARTChannelOptions.h>

/**
 ARTChannelMode bitmask matching the ARTProtocolMessageFlag.
 */
typedef NS_OPTIONS(NSUInteger, ARTChannelMode) {
    ARTChannelModePresence = 1 << 16,
    ARTChannelModePublish = 1 << 17,
    ARTChannelModeSubscribe = 1 << 18,
    ARTChannelModePresenceSubscribe = 1 << 19
};

NS_ASSUME_NONNULL_BEGIN

@interface ARTRealtimeChannelOptions : ARTChannelOptions

@property (nonatomic, strong, nullable) NSStringDictionary *params;
@property (nonatomic, assign) ARTChannelMode modes;

@end

NS_ASSUME_NONNULL_END
