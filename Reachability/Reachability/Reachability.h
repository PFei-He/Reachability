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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSInteger {
	NotReachable = 0,   // 无网络
	ReachableViaWiFi,   // 通过 WiFi 连接
    ReachableVia2G,     // 通过 2G 连接
    ReachableVia3G,     // 通过 3G 连接
    ReachableVia4G      // 通过 4G 连接
} NetworkStatus;

// 网络状态发生改变的通知
extern NSString *kReachabilityChangedNotification;

@class Reachability;

@protocol ReachabilityDelegate <NSObject>

/*!
 网络状态发生改变
 @param reachability 网络监听实例
 @param status 当前状态
 */
- (void)reachability:(Reachability *)reachability changeStatus:(NetworkStatus)status;

@end

@interface Reachability : NSObject

/*!
 网络可达性代理
 */
@property (nonatomic, weak) id<ReachabilityDelegate> delegate;

#pragma mark -

/*!
 检查是否可以连接到指定主机域名
 @param hostName 指定主机域名
 @return Reachability 实例
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

/*!
 检查是否可以连接到指定主机 IP 地址
 @param hostAddress 指定主机 IP 地址
 @return Reachability 实例
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

/*!
 检查是否可以连接到默认路由
 @return Reachability 实例
 */
+ (instancetype)reachabilityForInternetConnection;

#pragma mark -

/*!
 打开网络监听
 @return 打开监听是否成功
 */
- (BOOL)startMonitor;

/*!
 关闭网络监听
 */
- (void)stopMonitor;

#pragma mark -

/*!
 判断设备是否按需连接
 @return 当前网络状态是否按需请求
 */
- (BOOL)connectionRequired;

#pragma mark -

/*!
 当前网络状态
 @discussion 使用 <<通知>> 接收网络状态时调用
 @return 网络状态
 */
- (NetworkStatus)currentStatus;

#pragma mark -

/*!
 监听网络状态发生改变
 @discussion 使用 <<代码块>> 接收网络状态时调用
 @param monitor 监听者
 @param block 网络状态发生改变时的回调
 @see status 当前状态
 */
- (void)addMonitor:(id)monitor reachabilityStatusChanged:(nonnull void (^)(NetworkStatus status))block;

@end

NS_ASSUME_NONNULL_END
