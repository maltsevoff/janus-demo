#import <Foundation/Foundation.h>

#import <Ably/ARTTypes.h>
#import <Ably/ARTStatus.h>

NS_ASSUME_NONNULL_BEGIN

/**
 ARTPaginatedResult is a type that represents a page of results for all message and presence history, stats and REST presence requests. The response from a Ably REST API paginated query is accompanied by metadata that indicates the relative queries available to the ARTPaginatedResult object.
 */
@interface ARTPaginatedResult<ItemType> : NSObject

@property (nonatomic, strong, readonly) NSArray<ItemType> *items;
@property (nonatomic, readonly) BOOL hasNext;
@property (nonatomic, readonly) BOOL isLast;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (void)first:(void (^)(ARTPaginatedResult<ItemType> *_Nullable result, ARTErrorInfo *_Nullable error))callback;
- (void)next:(void (^)(ARTPaginatedResult<ItemType> *_Nullable result, ARTErrorInfo *_Nullable error))callback;

@end

NS_ASSUME_NONNULL_END
