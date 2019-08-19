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

#import "AppDelegate.h"

@interface AppDelegate ()  <ReachabilityDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 初始化
    self.reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
    
    // 使用通知接收网络状态改变消息
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    // 使用代理接收网络状态改变消息
    self.reachability.delegate = self;
    
    // 使用代码块接收网络状态改变消息
//    __weak __typeof__(self) weakSelf = self;
//    [self.reachability addMonitor:self reachabilityStatusChanged:^(NetworkStatus status) {
//        __typeof__(weakSelf) self = weakSelf;
//        if (status == ReachableVia2G) {
//            NSLog(@"Class '%@' work in 2G -[ Block ]-", self.classForCoder);
//        } else if (status == ReachableVia3G) {
//            NSLog(@"Class '%@' work in 3G -[ Block ]-", self.classForCoder);
//        } else if (status == ReachableVia4G) {
//            NSLog(@"Class '%@' work in 4G -[ Block ]-", self.classForCoder);
//        } else if (status == ReachableViaWiFi) {
//            NSLog(@"Class '%@' work in WIFI -[ Block ]-", self.classForCoder);
//        } else {
//            NSLog(@"Class '%@' work in NONE -[ Block ]-", self.classForCoder);
//        }
//    }];
    
    // 打开监控
    [self.reachability startMonitor];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//#pragma mark - Reachability Notification Methods
//
//- (void)reachabilityChanged:(NSNotification *)notification
//{
//    Reachability *reachability = [notification object];
//    NetworkStatus status = [reachability currentStatus];
//    if (status == ReachableVia2G) {
//        NSLog(@"Class '%@' work in 2G -[ Notification ]-", self.classForCoder);
//    } else if (status == ReachableVia3G) {
//        NSLog(@"Class '%@' work in 3G -[ Notification ]-", self.classForCoder);
//    } else if (status == ReachableVia4G) {
//        NSLog(@"Class '%@' work in 4G -[ Notification ]-", self.classForCoder);
//    } else if (status == ReachableViaWiFi) {
//        NSLog(@"Class '%@' work in WIFI -[ Notification ]-", self.classForCoder);
//    } else {
//        NSLog(@"Class '%@' work in NONE -[ Notification ]-", self.classForCoder);
//    }
//}

#pragma mark - ReachabilityDelegate Implementation

- (void)reachability:(Reachability *)reachability changeStatus:(NetworkStatus)status
{
    if (status == ReachableVia2G) {
        NSLog(@"Class '%@' work in 2G -[ Delegate ]-", self.classForCoder);
    } else if (status == ReachableVia3G) {
        NSLog(@"Class '%@' work in 3G -[ Delegate ]-", self.classForCoder);
    } else if (status == ReachableVia4G) {
        NSLog(@"Class '%@' work in 4G -[ Delegate ]-", self.classForCoder);
    } else if (status == ReachableViaWiFi) {
        NSLog(@"Class '%@' work in WIFI -[ Delegate ]-", self.classForCoder);
    } else {
        NSLog(@"Class '%@' work in NONE -[ Delegate ]-", self.classForCoder);
    }
}

@end
