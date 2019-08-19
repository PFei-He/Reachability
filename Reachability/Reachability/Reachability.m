//
//  Copyright (c) 2019 faylib.top
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <netdb.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "Reachability.h"

// 上一个网络状态
static NetworkStatus previousStatus;

// 网络状态改变通知
NSString *kReachabilityChangedNotification = @"kNetworkReachabilityChangedNotification";

// 声明网络状态发送变化时回调
static void ReachabilityCallback(SCNetworkReachabilityRef ref, SCNetworkReachabilityFlags flags, void* info);

// 回调
typedef void(^Block)(NetworkStatus);

#pragma mark -

@interface Reachability ()

// 代理数组
@property (nonatomic, strong) NSPointerArray *delegates;

// 监听者数组
@property (nonatomic, strong) NSMapTable *monitors;

// 代码块数组
@property (nonatomic, strong) NSMutableDictionary *blocks;

@end

@implementation Reachability
{
	SCNetworkReachabilityRef reachabilityRef;
}

#pragma mark - Life Cycle

// 释放
- (void)dealloc
{
    [self stopMonitor];
    if (reachabilityRef != NULL) {
        CFRelease(reachabilityRef);
    }
}

#pragma mark - Getter / Setter Methods

// 代理数组
- (NSPointerArray *)delegates
{
    if (!_delegates) {
        _delegates = [NSPointerArray weakObjectsPointerArray];
    }
    return _delegates;
}

// 监听者数组
- (NSMapTable *)monitors
{
    if (!_monitors) {
        _monitors = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return _monitors;
}

// 代码块数组
- (NSMutableDictionary *)blocks
{
    if (!_blocks) {
        _blocks = [NSMutableDictionary dictionary];
    }
    return _blocks;
}

// 设置代理
- (void)setDelegate:(id<ReachabilityDelegate>)delegate
{
    if ([delegate respondsToSelector:@selector(reachability:changeStatus:)]) {
        [self.delegates addPointer:(__bridge void*)delegate];
    }
}

#pragma mark - Private Methods

// 根据标记获取网络状态
- (NetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) { // 网络不通
		return NotReachable;
	}

    // 定义网络状态
    NetworkStatus status = NotReachable;

	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) { // 可连上目标主机
		status = ReachableViaWiFi;
	}

	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) { // 按需连接状态（CFSocketStream）
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) { // 不需用户干预
            status = ReachableViaWiFi;
        }
    }

	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) { // 使用的是 WWAN 网络接口（CFNetwork）
        
        // 获取当前数据网络的类型
        CTTelephonyNetworkInfo *info = [CTTelephonyNetworkInfo new];
        if ([info respondsToSelector:@selector(currentRadioAccessTechnology)]) {
            // 定义网络类型
            NSArray *type2G = @[CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x];
            NSArray *type3G = @[CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA, CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB, CTRadioAccessTechnologyeHRPD];
            NSArray *type4G = @[CTRadioAccessTechnologyLTE];
            
            // 当前网络类型
            NSString *generation = info.currentRadioAccessTechnology;
            
            // 获取当前网络状态
            if ([type2G containsObject:generation]) {
                status = ReachableVia2G;
            } else if ([type3G containsObject:generation]) {
                status = ReachableVia3G;
            } else if ([type4G containsObject:generation]){
                status = ReachableVia4G;
            }
        }
	}
    
	return status;
}

// 回调网络状态改变
- (void)changeStatusCallback
{
    /* --- Notification --- */
    
    // 使用通知回调状态
    [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotification object:self];
    
    
    /* --- Delegate --- */
    
    // 使用代理回调状态
    for (id<ReachabilityDelegate> delegate in self.delegates) {
        [delegate reachability:self changeStatus:previousStatus];
    }
    
    
    /* --- Block --- */
    
    // 使用代码块回调状态
    __weak __typeof__(self) weakSelf = self;
    [self.blocks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        __typeof__(weakSelf) self = weakSelf;
        if ([[[self.monitors keyEnumerator] allObjects] containsObject:key]) {
            Block block = obj;
            block(previousStatus);
        } else {
            [self.blocks removeObjectForKey:key];
        }
    }];
}

#pragma mark - Public Methods

// 检查是否可以连接到指定主机域名
+ (instancetype)reachabilityWithHostName:(NSString *)hostName
{
    Reachability *reachability = NULL;
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (ref != NULL) {
        reachability = [[self alloc] init];
        if (reachability != NULL) {
            reachability->reachabilityRef = ref;
        } else {
            CFRelease(ref);
        }
    }
    return reachability;
}

// 检查是否可以连接到指定主机 IP 地址
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress
{
    Reachability *reachability = NULL;
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);
    if (ref != NULL) {
        reachability = [[self alloc] init];
        if (reachability != NULL) {
            reachability->reachabilityRef = ref;
        } else {
            CFRelease(ref);
        }
    }
    return reachability;
}

// 检查是否可以连接到默认路由
+ (instancetype)reachabilityForInternetConnection
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress:(const struct sockaddr *)&zeroAddress];
}

#pragma mark -

// 打开网络监听
- (BOOL)startMonitor
{
    BOOL started = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    // 设置网络状态改变的回调
    if (SCNetworkReachabilitySetCallback(reachabilityRef, ReachabilityCallback, &context)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            started = YES;
        }
    }
    
    return started;
}

// 关闭网络监听
- (void)stopMonitor
{
    if (reachabilityRef != NULL) {
        SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

#pragma mark -

// 判断设备是否按需连接
- (BOOL)connectionRequired
{
    NSAssert(reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    
    return NO;
}

#pragma mark -

// 当前网络状态
- (NetworkStatus)currentStatus
{
    NSAssert(reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    NetworkStatus status = NotReachable;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
        status = [self networkStatusForFlags:flags];
    }
    
    return status;
}

#pragma mark -

// 监听网络状态发生改变
- (void)addMonitor:(id)monitor reachabilityStatusChanged:(void (^)(NetworkStatus))block
{
    [self.monitors setObject:monitor forKey:NSStringFromClass([monitor classForCoder])];
    [self.blocks setObject:block forKey:NSStringFromClass([monitor classForCoder])];
}

@end

#pragma mark - Supporting Functions

// 网络状态发送变化时回调
static void ReachabilityCallback(SCNetworkReachabilityRef ref, SCNetworkReachabilityFlags flags, void* info) {
#pragma unused (ref, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject *)info isKindOfClass:[Reachability class]], @"info was wrong class in ReachabilityCallback");
    
    Reachability *reachability = (__bridge Reachability *)info;
    NetworkStatus currentStatus = [reachability currentStatus];
    if (previousStatus != currentStatus) {
        previousStatus = currentStatus;
        
        // 网络状态改变时，发起回调
        [reachability changeStatusCallback];
    }
}
