#import <Foundation/Foundation.h>

#import <Ably/ARTRestPresence.h>
#import <Ably/ARTDataQuery.h>
#import <Ably/ARTEventEmitter.h>
#import <Ably/ARTRealtimeChannel.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARTRealtimePresenceQuery : ARTPresenceQuery

@property (readwrite, nonatomic) BOOL waitForSync;

@end

@protocol ARTRealtimePresenceProtocol

@property (readonly) BOOL syncComplete;

- (void)get:(ARTPresenceMessagesCallback)callback;
- (void)get:(ARTRealtimePresenceQuery *)query callback:(ARTPresenceMessagesCallback)callback;

- (void)enter:(id _Nullable)data;
- (void)enter:(id _Nullable)data callback:(nullable ARTCallback)cb;

- (void)update:(id _Nullable)data;
- (void)update:(id _Nullable)data callback:(nullable ARTCallback)cb;

- (void)leave:(id _Nullable)data;
- (void)leave:(id _Nullable)data callback:(nullable ARTCallback)cb;

- (void)enterClient:(NSString *)clientId data:(id _Nullable)data;
- (void)enterClient:(NSString *)clientId data:(id _Nullable)data callback:(nullable ARTCallback)cb;

- (void)updateClient:(NSString *)clientId data:(id _Nullable)data;
- (void)updateClient:(NSString *)clientId data:(id _Nullable)data callback:(nullable ARTCallback)cb;

- (void)leaveClient:(NSString *)clientId data:(id _Nullable)data;
- (void)leaveClient:(NSString *)clientId data:(id _Nullable)data callback:(nullable ARTCallback)cb;

- (ARTEventListener *_Nullable)subscribe:(ARTPresenceMessageCallback)callback;
- (ARTEventListener *_Nullable)subscribeWithAttachCallback:(nullable ARTCallback)onAttach callback:(ARTPresenceMessageCallback)cb;
- (ARTEventListener *_Nullable)subscribe:(ARTPresenceAction)action callback:(ARTPresenceMessageCallback)cb;
- (ARTEventListener *_Nullable)subscribe:(ARTPresenceAction)action onAttach:(nullable ARTCallback)onAttach callback:(ARTPresenceMessageCallback)cb;

- (void)unsubscribe;
- (void)unsubscribe:(ARTEventListener *)listener;
- (void)unsubscribe:(ARTPresenceAction)action listener:(ARTEventListener *)listener;

- (void)history:(ARTPaginatedPresenceCallback)callback;
- (BOOL)history:(ARTRealtimeHistoryQuery *_Nullable)query callback:(ARTPaginatedPresenceCallback)callback error:(NSError *_Nullable *_Nullable)errorPtr;

@end

@interface ARTRealtimePresence : ARTPresence <ARTRealtimePresenceProtocol>
@end

NS_ASSUME_NONNULL_END
