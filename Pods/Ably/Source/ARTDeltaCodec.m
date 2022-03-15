#import "ARTDeltaCodec.h"

@implementation ARTDeltaCodec (ARTDeltaCodec_VCDiffDecoder)

- (NSData *)decode:(NSData *)delta base:(NSData *)base error:(NSError **)error{
    return [ARTDeltaCodec applyDelta:delta previous:base error:error];
}

@end
