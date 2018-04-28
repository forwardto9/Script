**信鸽基础介绍**
![](/assets/jichu01.png)

##平台简介
<hr>

信鸽（XG Push）是一款专业的移动App推送平台，支持百亿级的通知/消息推送，秒级触达移动用户，现已全面支持Android和iOS两大主流平台。

开发者可以方便地通过嵌入SDK，通过API调用或者Web端可视化操作，实现对特定用户推送，大幅提升用户活跃度，有效唤醒沉睡用户，并实时查看推送效果。

##推送场景定义

### 推送通知
<hr>

在信鸽产品中，通知定义为Android和iOS开发者指南中的Notification。服务器定向将信息实时送达手机，通过建立一条手机与服务器的连接链路，当有消息需要发送到手机时，通过此链路发送即可。

通过推送一条用户可见的信息，引导用户进行有目的性的操作。通常用于产品信息知会、新闻推送和个性化消息等场景。

![](/assets/jichu02.png)

###本地通知
<hr>

本地通知定义为Android开发者指南中的Local Notification。

应用通过自定义的日期、时间和消息内容，无需通过服务器即可向用户推送一条可见的信息。通常用于应用的某些本地定时提醒场景，游戏应用中建筑物升级结束的提醒，以及一些有明确结束时间的场景等。

![](/assets/jichu03.png)

更多请参考XGPushManager提供信鸽服务的对外API列表

### 应用内消息
<hr>

在信鸽产品中，我们支持通过推送可执行代码指令，让应用在后台进行一系列操作行为，通过此功能，可以用最小成本实现对应用的远程操控，推送的应用内消息内容由各个应用开发者自定义。消息不弹出通知栏。

应用内消息可以支持的场景非常广泛，可以任由开发人员扩展。

例如给部分标签用户进行消息命令推送，让应用在WIFI情况下自动下载安装包并静默升级至最新；快速增量更新应用，或让应用根据自身情况下载并静默增量更新，对于不需要更新的用户不造成干扰。

另外，应用内消息既可以展示在通知栏里，也可以直接做成app的消息中心，所以自由度比推送通知栏消息高出百倍。

![](/assets/jichu04.png)![](/assets/jichu05.png)

### 标签
<hr>

在信鸽产品中，标签通常是指给某个一群用户打上标签，例如在北京的喜爱美食的使用iOS的用户；超过30天未启动应用的沉睡用户；高消费潜力用户；团队测试用户等。

一个应用最多有10000个 标签（tag）， 每个token在一个应用下最多100个 标签（tag）， 标签（tag）中不准包含空格。

地理标签、应用版本、流失用户这三个标签，是信鸽默认提供的，可以直接使用。
![](/assets/jichu06.png)

### 账号
<hr>

在信鸽产品中，别名/帐号通常是指给某特定用户推送消息。别名/帐号可以是终端在注册时上报的QQ号、openid、邮箱帐号、手机号等。

这里强调，若希望推送帐号，必须首先将账号与token进行绑定，否则将无法推送成功。绑定方式见Android、iOS接入指南——根据帐号推送。

![](/assets/jichu07.png)


# Summary

* [Android接入](android_access.md)
  * [Android SDK API](android_access/api.md)
  * [Android SDK 3.X升级指南](android_access/upgrade_guide.md)
  * [Android SDK 集成指南](android_access/jcenter.md)
  * [华为推送通道集成指南](android_access/huawei_push.md)
  * [魅族推送通道集成指南](android_access/meizu_push.md)
  * [小米推送通道集成指南](android_access/mi_push.md)
  * [Android测试Demo用法介绍](android_access/testdemo.md)
* [iOS接入](ios_access.md)
  * [iOS 证书设置指南](ios_access/certificate_config.md)
  * [iOS SDK v2.5.0 完整接入](ios_access/api_2.5.0.md)
  * [iOS SDK v3.0 完整接入](ios_access/api_3.0.md)
  * [iOS 常见问题自查](ios_access/ios-chang-jian-wen-ti-zi-cha.md)
* [服务端API接入](server_api.md)
  * [Rest API 使用指南](server_api/rest.md)
  * [服务端其他语言](server_api/other.md)
* [信鸽返回码一览](push_ret_code.md)
* [热门问题与解答](push_faq.md)
  * [推送流程图](push_faq/flow_chart.md)
  * [推送失败原因](push_faq/failure_reason.md)
  * [热门技术问题](push_faq/technical_issues.md)
* [管理台功能介绍](console.md)
  * [权限管理](console/auth.md)
  * [推送详情](console/pushdetail.md)
  * [名词解释](noun_explanation/noun_explanation.md)
* [APICloud模块接入\(new\)](apicloud-tencentpush.md)

