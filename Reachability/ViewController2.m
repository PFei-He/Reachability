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

#import "ViewController2.h"
#import "AppDelegate.h"

@interface ViewController2 () <ReachabilityDelegate>

@end

@implementation ViewController2

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 使用通知接收网络状态改变消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    // -
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    // 使用代理接收网络状态改变消息
    appDelegate.reachability.delegate = self;
    
    // 使用代码块接收网络状态改变消息
    __weak __typeof__(self) weakSelf = self;
    [appDelegate.reachability addMonitor:self reachabilityStatusChanged:^(NetworkStatus status) {
        __typeof__(weakSelf) self = weakSelf;
        [self logWithStatus:status type:@"Block"];
    }];
}

#pragma mark - Events Managements

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Private Methods

- (void)logWithStatus:(NetworkStatus)status type:(NSString *)type
{
    if (status == ReachableVia2G) {
        NSLog(@"Class '%@' work in 2G -[ %@ ]-", self.classForCoder, type);
    } else if (status == ReachableVia3G) {
        NSLog(@"Class '%@' work in 3G -[ %@ ]-", self.classForCoder, type);
    } else if (status == ReachableVia4G) {
        NSLog(@"Class '%@' work in 4G -[ %@ ]-", self.classForCoder, type);
    } else if (status == ReachableViaWiFi) {
        NSLog(@"Class '%@' work in WIFI -[ %@ ]-", self.classForCoder, type);
    } else {
        NSLog(@"Class '%@' work in NONE -[ %@ ]-", self.classForCoder, type);
    }
}

#pragma mark - Reachability Notification Methods

- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *reachability = [notification object];
    NetworkStatus status = [reachability currentStatus];
    [self logWithStatus:status type:@"Notification"];
}

#pragma mark - ReachabilityDelegate Implementation

- (void)reachability:(Reachability *)reachability changeStatus:(NetworkStatus)status
{
    [self logWithStatus:status type:@"Delegate"];
}

@end
