#import <Foundation/Foundation.h>

@class ARTRest;
@class ARTRestChannel;
@class ARTChannelOptions;

@interface ARTChannels<ChannelType> : NSObject

- (BOOL)exists:(NSString *)name;
- (ChannelType)get:(NSString *)name;
- (ChannelType)get:(NSString *)name options:(ARTChannelOptions *)options;
- (void)release:(NSString *)name;
- (id<NSFastEnumeration>)copyIntoIteratorWithMapper:(id (^)(ChannelType))mapper;

@end
