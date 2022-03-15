#import "Ably.h"
#import "ARTDefault+Private.h"
#import "ARTNSArray+ARTFunctional.h"
#import <sys/utsname.h>

// NSOperatingSystemVersion has NSInteger as version components for some reason, so mitigate it here.
static inline UInt32 conformVersionComponent(const NSInteger component) {
    return (component < 0) ? 0 : (UInt32)component;
}

NSString *const ARTDefault_apiVersion = @"1.2";
NSString *const ARTDefault_libraryVersion = @"1.2.10";

NSString *const ARTDefaultProduction = @"production";

NSString *const ARTDefault_restHost = @"rest.ably.io";
NSString *const ARTDefault_realtimeHost = @"realtime.ably.io";
NSString *const ARTDefault_ablyBundleId = @"io.ably.Ably";
NSString *const ARTDefault_bundleVersionKey = @"CFBundleShortVersionString";
NSString *const ARTDefault_bundleBuildNumberKey = @"CFBundleVersion";
NSString *const ARTDefault_platform = @"cocoa";
NSString *const ARTDefault_libraryName = @"ably-cocoa";
NSString *const ARTDefault_variant =
    #if TARGET_OS_IOS
        @".ios"
    #elif TARGET_OS_TV
        @".tvos"
    #elif TARGET_OS_WATCH
        @".watchos"
    #elif TARGET_OS_OSX
        @".macos"
    #else
        @""
    #endif
    ;

static NSTimeInterval _realtimeRequestTimeout = 10.0;
static NSTimeInterval _fallbackRetryTimeout = 600.0; // TO3l10
static NSTimeInterval _connectionStateTtl = 60.0;
static NSInteger _maxMessageSize = 65536;

@implementation ARTDefault

+ (NSString *)apiVersion {
    return ARTDefault_apiVersion;
}

+ (NSString *)libraryVersion {
    return ARTDefault_libraryVersion;
}

+ (NSArray*)fallbackHostsWithEnvironment:(NSString *)environment {
    NSArray<NSString *> * fallbacks = @[@"a", @"b", @"c", @"d", @"e"];
    NSString *prefix = @"";
    NSString *suffix = @"";
    if (environment && ![[environment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] && ![environment isEqualToString:ARTDefaultProduction]) {
        prefix = [NSString stringWithFormat:@"%@-", environment];
        suffix = @"-fallback";
    }
    
    return [fallbacks artMap:^NSString *(NSString * fallback) {
        return [NSString stringWithFormat:@"%@%@%@.ably-realtime.com", prefix, fallback, suffix];
    }];
}

+ (NSArray*)fallbackHosts {
    return [self fallbackHostsWithEnvironment:nil];
}

+ (NSString*)restHost {
    return ARTDefault_restHost;
}

+ (NSString*)realtimeHost {
    return ARTDefault_realtimeHost;
}

+ (int)port {
    return 80;
}

+ (int)tlsPort {
    return 443;
}

+ (NSTimeInterval)ttl {
    return 60 * 60;
}

+ (NSTimeInterval)fallbackRetryTimeout {
    return _fallbackRetryTimeout;
}

+ (NSTimeInterval)connectionStateTtl {
    return _connectionStateTtl;
}

+ (NSTimeInterval)realtimeRequestTimeout {
    return _realtimeRequestTimeout;
}

+ (NSInteger)maxMessageSize {
    return _maxMessageSize;
}

+ (void)setRealtimeRequestTimeout:(NSTimeInterval)value {
    @synchronized (self) {
        _realtimeRequestTimeout = value;
    }
}

+ (void)setConnectionStateTtl:(NSTimeInterval)value {
    @synchronized (self) {
        _connectionStateTtl = value;
    }
}

+ (void)setMaxMessageSize:(NSInteger)value {
    @synchronized (self) {
        _maxMessageSize = value;
    }
}

+ (void)setFallbackRetryTimeout:(NSTimeInterval)value {
    @synchronized (self) {
        _fallbackRetryTimeout = value;
    }
}

+ (NSString *)bundleVersion {
    NSDictionary *infoDictionary = [[NSBundle bundleForClass: [ARTDefault class]] infoDictionary];
    return infoDictionary[ARTDefault_bundleVersionKey];
}

+ (NSString *)bundleBuildNumber {
    NSDictionary *infoDictionary = [[NSBundle bundleForClass: [ARTDefault class]] infoDictionary];
    return infoDictionary[ARTDefault_bundleBuildNumberKey];
}

+ (NSString *)osName {
    return
        #if TARGET_OS_IOS
            @"iOS"
        #elif TARGET_OS_TV
            @"tvOS"
        #elif TARGET_OS_WATCH
            @"watchOS"
        #elif TARGET_OS_OSX
            @"macOS"
        #else
            nil
        #endif
        ;
}

+ (NSString *)osVersionString {
    static NSString *versionString;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
        versionString = [NSString stringWithFormat:@"%lu.%lu.%lu",
             (unsigned long)conformVersionComponent(version.majorVersion),
             (unsigned long)conformVersionComponent(version.minorVersion),
             (unsigned long)conformVersionComponent(version.patchVersion)];
    });
    return versionString;
}

+ (NSString *)deviceModel {
    struct utsname systemInfo;
    if (uname(&systemInfo) < 0) {
        return nil;
    }
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)libraryAgent {
    NSMutableString *agent = [NSMutableString stringWithFormat:@"%@/%@", ARTDefault_libraryName, ARTDefault_libraryVersion];
    return agent;
}

+ (NSString *)platformAgent {
    NSMutableString *agent = [NSMutableString string];
    NSString *osName = [self osName];
    if (osName != nil) {
        [agent appendFormat:@"%@/%@", osName, [self osVersionString]];
    }
    return agent;
}

@end
