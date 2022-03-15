#import <Foundation/Foundation.h>

#import <Ably/ARTBaseMessage.h>
#import <Ably/ARTTypes.h>

NS_ASSUME_NONNULL_BEGIN

/// ARTMessage represents an individual message that is sent to or received from Ably.
@interface ARTMessage : ARTBaseMessage

/// The event name, if available
@property (nullable, readwrite, strong, nonatomic) NSString *name;

- (instancetype)initWithName:(nullable NSString *)name data:(id)data;
- (instancetype)initWithName:(nullable NSString *)name data:(id)data clientId:(NSString *)clientId;

@end

NS_ASSUME_NONNULL_END
