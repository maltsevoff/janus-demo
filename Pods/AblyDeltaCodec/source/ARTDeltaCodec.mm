//
//  ARTDeltaCodec.mm
//  AblyDeltaCodec
//
//  Created by Ricardo Pereira on 05/09/2019.
//  Copyright © 2019 Ably. All rights reserved.
//

#import "ARTDeltaCodec.h"

#import "xdelta3.h"

NSString *const ARTDeltaCodecErrorDomain = @"io.ably.delta-codec";

@implementation ARTDeltaCodec

+ (BOOL)isDelta:(NSData *)delta {
    if (!delta || delta.length <= 0) {
        return false;
    }

    const uint8_t *delta_buf = (const uint8_t *)delta.bytes;

    if (delta_buf &&
        delta_buf[0] == 214 && //V
        delta_buf[1] == 195 && //C
        delta_buf[2] == 196 && //D
        delta_buf[3] == 0) { //\0
        return true;
    }

    return false;
}

+ (NSData *)applyDelta:(NSData *)current previous:(NSData *)previous error:(NSError *__autoreleasing  _Nullable *)error {
    if (![self.class isDelta:current]) {
        if (error) {
            *error = [NSError errorWithDomain:ARTDeltaCodecErrorDomain
                                         code:ARTDeltaCodecCodeErrorInvalidDeltaData
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: @"Current delta is not accepted",
                                                NSLocalizedFailureReasonErrorKey: @"Delta should be a valid VCDiff/RFC3284 stream"
                                                }];
        }
        return nil;
    }

    if (!previous) {
        if (error) {
            *error = [NSError errorWithDomain:ARTDeltaCodecErrorDomain
                                         code:ARTDeltaCodecCodeErrorInvalidBaseData
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: @"Previous delta is invalid",
                                                NSLocalizedFailureReasonErrorKey: @"Previous is nil"
                                                }];
        }
        return nil;
    }

    const uint8_t *base_buf = (const uint8_t *)previous.bytes;
    usize_t base_size = previous.length;
    const uint8_t *delta_buf = (const uint8_t *)current.bytes;
    usize_t delta_size = current.length;

    int result;
    // The output array must be large enough
    usize_t output_size = sizeof(uint8_t) * 32 * 1024 * 1024; //32 MB
    NSMutableData *outputData = [NSMutableData dataWithLength:output_size];
    uint8_t *output_buf = (uint8_t *)outputData.mutableBytes;

    result = xd3_decode_memory(delta_buf, delta_size, base_buf, base_size, output_buf, &output_size, output_size, 0);

    switch (result) {
        case ENOSPC:
            if (error) {
                *error = [NSError errorWithDomain:ARTDeltaCodecErrorDomain
                                             code:ARTDeltaCodecCodeErrorInternalFailure
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Output size is not large enough",
                                                    NSLocalizedFailureReasonErrorKey: @"ENOSPC"
                                                    }];
            }
            return nil;
        case XD3_INVALID_INPUT:
            if (error) {
                *error = [NSError errorWithDomain:ARTDeltaCodecErrorDomain
                                             code:ARTDeltaCodecCodeErrorInvalidDeltaData
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Invalid input/decoder error",
                                                    NSLocalizedFailureReasonErrorKey: @"XD3_INVALID_INPUT"
                                                    }];
            }
            return nil;
    }

    if (result) {
        if (error) {
            *error = [NSError errorWithDomain:ARTDeltaCodecErrorDomain
                                         code:ARTDeltaCodecCodeErrorInternalFailure
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unspecified error %d", result],
                                                }];
        }
        return nil;
    }

    [outputData setLength:output_size];

    return outputData;
}

- (NSData *)applyDelta:(NSData *)delta deltaId:(NSString *)deltaId baseId:(NSString *)baseId error:(NSError **)error {
    if (!self.base) {
        if (error) {
            *error = [NSError errorWithDomain:ARTDeltaCodecErrorDomain
                                         code:ARTDeltaCodecCodeErrorUninitializedDecoder
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: @"Decoder was not initialized with a valid base",
                                                NSLocalizedFailureReasonErrorKey: @"Base is nil"
                                                }];
        }
        return nil;
    }

    if (![self.baseId isEqualToString:baseId]) {
        if (error) {
            *error = [NSError errorWithDomain:ARTDeltaCodecErrorDomain
                                         code:ARTDeltaCodecCodeErrorBaseIdMismatch
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: @"Provided baseId does not match the last preserved baseId in the sequence",
                                                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Last baseId is '%@' and the provided is '%@'", self.baseId, baseId]
                                                }];
        }
        return nil;
    }

    NSData *outputData = [self.class applyDelta:delta previous:self.base error:error];

    [self setBase:outputData withId:deltaId];

    return outputData;
}

- (void)setBase:(NSData *)base withId:(NSString *)baseId {
    _base = base;
    _baseId = baseId;
}

@end
