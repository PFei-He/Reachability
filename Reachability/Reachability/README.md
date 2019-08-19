Reachability
============
Reachability 是基于 `苹果公司 (Apple.Inc)` 的开放源代码  [Reachability](https://developer.apple.com/library/archive/samplecode/Reachability/Introduction/Intro.html) 的基础上二次开发的网络状态监测工具，可实时对网络状态的改变发出消息，并检测出当前网络类型。

Usage
============
初始化
```
self.reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
```
打开监控
```
[self.reachability startMonitor];
```

关闭监控
```
[self.reachability stopMonitor];
```

Reachability 可用 3 种方法接收网络状态改变的消息
------------
- 使用通知
```
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
```
```
- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability* reachability = [notification object];
    NetworkStatus status = [reachability currentStatus];
    if (status == ReachableVia2G) {
        NSLog(@"2G");
    } else if (status == ReachableVia3G) {
        NSLog(@"3G");
    } else if (status == ReachableVia4G) {
        NSLog(@"4G");
    } else if (status == ReachableViaWiFi) {
        NSLog(@"WIFI");
    } else {
        NSLog(@"NONE");
    }
}
```

- 使用代理
```
@interface AppDelegate () <ReachabilityDelegate>
```
```
self.reachability.delegate = self;
```
```
- (void)reachability:(Reachability *)reachability changeStatus:(NetworkStatus)status {
    if (status == ReachableVia2G) {
        NSLog(@"2G");
    } else if (status == ReachableVia3G) {
        NSLog(@"3G");
    } else if (status == ReachableVia4G) {
        NSLog(@"4G");
    } else if (status == ReachableViaWiFi) {
        NSLog(@"WIFI");
    } else {
        NSLog(@"UNKNOW");
    }
}
```

- 使用代码块
```
[self.reachability addMonitor:self reachabilityStatusChanged:^(NetworkStatus status) {
    if (status == ReachableVia2G) {
        NSLog(@"2G");
    } else if (status == ReachableVia3G) {
        NSLog(@"3G");
    } else if (status == ReachableVia4G) {
        NSLog(@"4G");
    } else if (status == ReachableViaWiFi) {
        NSLog(@"WIFI");
    } else {
        NSLog(@"UNKNOW");
    }
}];
```

NOTE
============
需创建全局性的 `Reachability` 实例才能正常接收网络状态改变的消息
```
@property (nonatomic, strong) Reachability *reachability;
```

LICENSE
============
`Reachability` 使用 MIT 许可证，详情见 LICENSE 文件。
