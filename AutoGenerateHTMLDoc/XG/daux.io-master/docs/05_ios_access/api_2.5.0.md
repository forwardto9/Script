#信鸽 iOS SDK 开发指南

## 简介

---

信鸽iOS SDK是一个能够提供Push服务的开发平台，提供给开发者简便、易用的API接口，方便快速接入。

## 接入方法

---

\(1\)获取 AppId 和 AppKey

\(2\)工程配置

### 获取 AppId 和 AppKey

前往[http://xg.qq.com](http://xg.qq.com)注册并获取AppKey

### 工程配置

（1）下载信鸽 SDK, 解压缩。注：使用CocoaPods的用户可以通过如下名称管理信鸽：

```shell
pod 'QQ_XGPush'
```

（2）将 XGSetting.h, XGPush.h 以及 libXG-SDK.a 添加到工程

（3）添加以下库/framework 的引用 CoreTelephony.framework, SystemConfiguration.framework, UserNotifications.framework, libXG-SDK.a 以及 libz.tbd.添加完成以后,库的引用如下

![library](https://raw.githubusercontent.com/iosmonster/mta_xg/master/doc/img/xg_library_ref.png)

（4）在工程配置和后台模式中打开推送,如下图

![projcfg](https://raw.githubusercontent.com/iosmonster/mta_xg/master/doc/img/xg_proj_cfg.png)

（5）参考 Demo, 添加相关代码

## API 接口

### 开启 Debug

打开 Debug 模式以后可以在终端看到详细的信鸽 Debug 信息.方便定位问题

**示例**

```obj-c
//打开debug开关
XGSetting *setting = [XGSetting getInstance];
[setting enableDebug:YES];
//查看debug开关是否打开
BOOL debugEnabled = [setting isEnableDebug];
```

### 初始化信鸽

在使用信鸽之前,需要先在UIApplicationDelegate中的

```obj-c
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
```

回调中调用信鸽的初始化方法才能正常使用信鸽

**\(1\)接口**

```obj-c
/**
初始化信鸽

@param appId 通过前台申请的应用ID
@param appKey 通过前台申请的appKey
*/
+(void)startApp:(uint32_t)appId appKey:(nonnull NSString *)appKey;
```

**\(2\)示例**

```obj-c
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
[XGPush startApp:1234567890 appKey:@"ABCDEFGHIJKLMN"];
}
```

### 注册苹果推送服务

使用推送前,需要先向苹果注册推送服务. 请参考 Demo 向苹果注册推送服务.

**示例**

```obj-c
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
// 详细代码参考 Demo 中 registerAPNS 的实现
[self registerAPNS];
}
```

**注: 在 iOS 10 中也可以可以使用 iOS 10 之前的注册方法来注册推送,但是对应的,也要使用 iOS 10 之前的方法来接收推送**

### 注册信鸽

向苹果注册完成推送服务以后,还需要向信鸽注册推送.在UIApplicationDelegate的

```obj-c
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
```

回调中调用信鸽的 registerDevice 方法即可完成信鸽注册

**\(1\)接口**

```obj-c
/**
注册设备

@param deviceToken 通过appdelegate的didRegisterForRemoteNotificationsWithDeviceToken
回调的获取
@param successCallback 成功回调
@param errorCallback 失败回调
@return 获取的 deviceToken 字符串
*/
+(nullable NSString *)registerDevice:(nonnull NSData *)deviceToken
successCallback:(nullable void (^)(void)) successCallback
errorCallback:(nullable void (^)(void)) errorCallback;

/**
注册设备并且设置账号

@param deviceToken 通过appDelegate的didRegisterForRemoteNotificationsWithDeviceToken
回调的获取
@param account 需要设置的账号,长度为2个字节以上，不要使用"test","123456"这种过于简单的字符串,
若不想设置账号,请传入nil
@param successCallback 成功回调
@param errorCallback 失败回调
@return 获取的 deviceToken 字符串
*/
+(nullable NSString *)registerDevice:(nonnull NSData *)deviceToken
account:(nullable NSString *)account
successCallback:(nullable void (^)(void)) successCallback
errorCallback:(nullable void (^)(void)) errorCallback;

/**
注册设备并且设置账号, 字符串 token 版本

@param deviceToken NSString *类型的 token
@param account 需要设置的账号,若不想设置账号,请传入 nil
@param successCallback 成功回调
@param errorCallback 失败回调
@return 获取的 deviceToken 字符串
*/
+(nullable NSString *)registerDeviceStr:(nonnull NSString *)deviceToken
account:(nullable NSString *) account
successCallback:(nullable void(^)(void)) successCallback
errorCallback:(nullable void(^)(void))errorCallback;
```

**\(2\)示例**

```obj-c
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

NSString *deviceTokenStr = [XGPush registerDevice:deviceToken
account:nil
successCallback:^{
NSLog(@"[XGPush Demo] register push success");
} errorCallback:^{
NSLog(@"[XGPush Demo] register push error");
}];
NSLog(@"[XGPush Demo] device token is %@", deviceTokenStr);
}
```
**注意：account是需要设置的账号,视业务需求自定义,可以是用户的名称或者ID等,长度为2个字节以上，不要使用"myAccount"或者"test","123456"这种过于简单的字符串,若不想设置账号，请传入nil**

### 设置/删除标签

开发者可以针对不同的用户设置标签,然后对该标签推送.对标签推送会让该标签下的所有设备都收到推送.一个设备可以设置多个标签.

**\(1\)接口**

```obj-c
/**
设置 tag

@param tag 需要设置的 tag
@param successCallback 成功回调
@param errorCallback 失败回调
*/
+(void)setTag:(nonnull NSString *)tag
successCallback:(nullable void (^)(void)) successCallback
errorCallback:(nullable void (^)(void)) errorCallback;


/**
删除tag

@param tag 需要删除的 tag
@param successCallback 成功回调
@param errorCallback 失败回调
*/
+(void)delTag:(nonnull NSString *)tag
successCallback:(nullable void (^)(void)) successCallback
errorCallback:(nullable void (^)(void)) errorCallback;
```

**\(2\)示例**

```obj-c
- (void)setTag:(NSString *)tag {
[XGPush setTag:@"myTag" successCallback:^{
NSLog(@"[XGDemo] Set tag success");
} errorCallback:^{
NSLog(@"[XGDemo] Set tag error");
}];
}


- (void)delTag:(NSString *)tag {
[XGPush delTag:@"myTag" successCallback:^{
NSLog(@"[XGDemo] Del tag success");
} errorCallback:^{
NSLog(@"[XGDemo] Del tag error");
}];
}
```

### 设置/删除账号

开发者可以针对不同的用户设置账号,然后对账号推送.对账号推送会让该账号下的所有设备都收到推送.

**注1: 一个账号最多绑定15台设备,超过之后会随机解绑一台设备,然后再进行注册.**

**注2: 老版本不带回调的接口要求设置/删除账号后再调用一次注册设备的方法,但是新版带回调的接口不需要再调用注册设备的方法**

**\(1\)接口**

```obj-c
/**
设置设备的帐号. 设置账号前需要调用一次registerDevice

@param account 需要设置的账号,长度为2个字节以上，不要使用"test","123456"这种过于简单的字符串
@param successCallback 成功回调
@param errorCallback 失败回调
*/
+(void)setAccount:(nonnull NSString *)account
successCallback:(nullable void(^)(void)) successCallback
errorCallback:(nullable void(^)(void)) errorCallback;


/**
删除已经设置的账号. 删除账号前需要调用一次registerDevice

@param successCallback 成功回调
@param errorCallback 失败回调
*/
+(void)delAccount:(nullable void(^)(void)) successCallback
errorCallback:(nullable void(^)(void)) errorCallback;
```

**\(2\)示例**

```obj-c
- (void)setAccount:(NSString *)account {
[XGPush setAccount:@"myAccount" successCallback:^{
NSLog(@"[XGDemo] Set account success");
} errorCallback:^{
NSLog(@"[XGDemo] Set account error");
}];
}

- (void)delAccount {
[XGPush delAccount:^{
NSLog(@"[XGDemo] Del account success");
} errorCallback:^{
NSLog(@"[XGDemo] Del account error");
}];
}
```

### 注销设备

注销设备以后,可以让该设备不再接收推送.

**（1）接口**

```object-c
/**
注销设备，设备不再进行推送
@param successCallback 成功回调
@param errorCallback 失败回调
*/
+(void)unRegisterDevice:(nullable void (^)(void)) successCallback
errorCallback:(nullable void (^)(void)) errorCallback;
```

**（2）示例**

```object-c
[XGPush unRegisterDevice:^{
NSLog(@"[XGDemo] unregister success");
} errorCallback:^{
NSLog(@"[XGDemo] unregister error");
}];
```

**注意：重新开启推送功能需要再次调用registerAPNS和registerDevice接口。**

## 推送效果统计

如果需要统计由信鸽推送的点击或者打开.

### 统计打开

对于统计打开需要开发者在UIApplicationDelegate中的

```obj-c
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
```

调用 handleLaunching 方法

**\(1\)接口**

```obj-c
/**
在didFinishLaunchingWithOptions中调用，用于推送反馈.(app没有运行时，点击推送启动时)

@param launchOptions didFinishLaunchingWithOptions中的userinfo参数
@param successCallback 成功回调
@param errorCallback 失败回调
*/
+(void)handleLaunching:(nonnull NSDictionary *)launchOptions
successCallback:(nullable void (^)(void)) successCallback
errorCallback:(nullable void (^)(void)) errorCallback;
```

**\(2\)示例**

```obj-c
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

[XGPush handleLaunching:launchOptions successCallback:^{
NSLog(@"[XGDemo] Handle launching success");
} errorCallback:^{
NSLog(@"[XGDemo] Handle launching error");
}];
}
```

### 统计点击

* iOS 10 以前的系统版本

对于 iOS 10 以前的系统版本,需要在 UIApplicationDelegate 中的

```obj-c
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo;
```

中调用 handleReceiveNotification 方法

**\(1\)接口**

```obj-c
/**
在didReceiveRemoteNotification中调用，用于推送反馈。(app在运行时)

@param userInfo 苹果 apns 的推送信息

@param successCallback 成功回调

@param errorCallback 失败回调
*/
+(void)handleReceiveNotification:(nonnull NSDictionary *)userInfo
successCallback:(nullable void (^)(void)) successCallback
errorCallback:(nullable void (^)(void)) errorCallback;
```

**\(2\)示例**

```obj-c
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {

NSLog(@"[XGPush Demo] receive Notification");
[XGPush handleReceiveNotification:userInfo
successCallback:^{
NSLog(@"[XGDemo] Handle receive success");
} errorCallback:^{
NSLog(@"[XGDemo] Handle receive error");
}];
}
```

* iOS 10
对于 iOS 10, 需要在 UNUserNotificationCenterDelegate 的

```obj-c
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
withCompletionHandler:(void(^)())completionHandler;
```

中调用 handleReceiveNotification 方法

**\(1\)接口**

```obj-c
/**
在didReceiveRemoteNotification中调用，用于推送反馈。(app在运行时)

@param userInfo 苹果 apns 的推送信息
@param successCallback 成功回调
@param errorCallback 失败回调
*/
+(void)handleReceiveNotification:(nonnull NSDictionary *)userInfo
successCallback:(nullable void (^)(void)) successCallback
errorCallback:(nullable void (^)(void)) errorCallback;
```

**\(2\)示例**

```obj-c
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
withCompletionHandler:(void(^)())completionHandler {

[XGPush handleReceiveNotification:response.notification
.request.content.userInfo
successCallback:^{
NSLog(@"[XGDemo] Handle receive success");
} errorCallback:^{
NSLog(@"[XGDemo] Handle receive error");
}];

completionHandler()
}
```

## 本地推送

本地推送相关功能请参考[苹果开发者文档](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/SchedulingandHandlingLocalNotifications.html#//apple_ref/doc/uid/TP40008194-CH5-SW1).

