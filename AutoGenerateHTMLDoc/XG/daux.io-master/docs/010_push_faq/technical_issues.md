# 热门技术问题
##Android平台
<hr> 

- **（1）多行显示**

Android多行显示特性，在2.38及以上版本已经实现并默认开启。
主要的代码如下所示,请在你的工程内搜索并确认：
NotificationCompat.BigTextStyle bigText = new NotificationCompat.BigTextStyle();

bigText.bigText(this.tickerText);
build.setStyle(bigText);

- **（2）多包名推送**

目前市场上部分app针对不同渠道有不同的包名，同一款app可能会有上百个包名，这时就可以利用access id向该app的所有包名进行推送。在多包名推送模式下，设备上所有使用这个access id注册推送的app都会收到这条消息。
单应用多包名推送分为简单的三个步骤：

a）在信鸽前台注册应用，无需填写包名；若已经填好包名，也不会影响推送效果；

b）集成最新SDK在应用内；

c）在进行推送前，将推送参数 multi_pkg 设置为1；

- **(3)出现下列情况？**

```java
android.app.IntentReceiverLeaked: Activity com.xxxx has leaked IntentReceiver com.tencent.android.tpush.f@422a4dc8 that was originally registered here. Are you missing a call to unregisterReceiver()?
```

原因：acitvity在信鸽注册返回前就finish了，导致信鸽注册的receiver没有被取消

处理方法：registerPush传递的context改为context.getApplicationContext()

- **（4）如何删除注册成功的Toast提示?**

原因：demo里面的CustomPushReceiver自带Toast提示

处理方法：删除CustomPushReceiver里面的Toast相关内容

- **（5）libs目录下有很多平台的.so文件，如armabi、x86**

原因：信鸽针对android所有的平台开发了.so库

处理方法：可以将不需要的平台目录删除掉，如游戏一般只有armabi，可以删除其它目录。

- **（6）指定打开某个activity页面，但经常不能正常跳转**

原因：在部分手机，通知栏跳转到某个页面可能会出现权限问题

处理方法：在androidManifest.xml中，需要打开的activity加上android:exported="true"。

- **（7）没有sd卡就不能用信鸽了么?**

解答：不会，只是日志写的地方不同。

- **（8）注册方法能不能放到线程里创建，能不能在APPLICATON onCreate里就创建?**

解答：注册方法可以在任何地方调用，但注意要传递applicationContext 。

##iOS平台
<hr>

- **（1）为什么要传pem证书?**

答案: pem证书是和苹果建立连接时需要的文件，在用户上传时，信鸽后台会尝试连接苹果服务器验证其合法性。

- **（2）如果出现以下错误：**

![](/assets/14.png)

请在自己的项目里这样设置：

![](/assets/15.png)

- **（3）如果出现以下错误：**

![](/assets/18.png)

请在自己的项目里这样设置：

provisioning profile文件需要包含正在调试的设备，并且provisioning profile文件要在app开启APNS之后生成。

- **（4）iOS为什么没有抵达数据？**

由于苹果系统的问题，信鸽无法统计到消息推送之后的抵达动作。但是，若用户对消息进行了点击，信鸽可以统计其点击动作并且上报。

受APNS和iOS的限制，效果统计功能可能会有一定的统计误差。

- **（5）无法上传iOS证书？**

请核对证书格式是否正确。

- **（6）证书验证失败？**

请仔细参考iOS证书设置指南进行证书制作。

- **（7）点击推送时，提示：failed to load certificate,check your APNS certificate**

a.对应环境的apns证书没提交

b.证书做得不对，请参照官方指南进行制作

c.推送环境是否选择正确，测试预览请选择开发环境

- **（8）开发证书和生产证书区别？**

开发证书用于开发推送服务时使用，设备获取到的deviceToken是苹果下发的开发环境的deviceToken。

生产证书用于正式的提送，苹果下发的是生产环境的deviceToken。AppStore审核通过后，可以给所有安装App的设备进行推送。

为什么我的项目接入信鸽在iphone5s上不能通过编译？

XCode进行以下设置即可,把相应Target的Valid Architectures里的arm64删除。

IOS 通过编译.jpg

iOS SDK在注册xgpush时，出现下列情况是什么意思？

[xgpush seccess]rspCode is 0

[xgpush]Disconnected.

解答：第一个是指成功，第二个是指收到服务器返回或者超时，就会断开和服务器的连接。

- **（9）重新注册同一个别名收到推送消息？**

解答：setAccount之后要重新registerDevice一次，详细见注册设备

- **（10）创建标签推送失败，Debug日志中出现报错“有错误发生，服务器返回码：2**

解答：这个是由于标签名称中包含空格导致的，标签名称中不能有空格。

- **（11）信鸽Android SDK关于集成厂商通道在开发调试过程中可能遇到的消息回调的问题**

小米通道：
消息接收支持回调，消息点击支持回调(必须要自定义通知)，如果在信鸽前端推送消息时在【高级设置】中指定点击打开任一【应用】【自定义页面】【URL】【客户端自定义】之后，点击依然可以打开指定的页面，但是消息点击将不再支持回调，支持透传

华为通道：
消息接收暂不支持回调，消息点击支持回调(但必须添加自定义参数)，支持透传(但忽略自定义参数)

魅族通道：
消息接收支持回调，消息点击支持回调，不支持透传

_以上涉及到暂不支持的特性是对应厂商的策略，信鸽会持续跟进厂商的变化_


- **（12）信鸽Android SDK关于集成厂商通道在开发调试过程中可能遇到的otherpushToken = null的问题**

**小米通道排查路径：**
1）根据开发文档检查manifest文件配置，尤其需要修改包名的地方有没修改：


```
<permission android:name="com.example.mipushtest.permission.MIPUSH_RECEIVE" android:protectionLevel="signature" />
<!-- 这里com.example.mipushtest改成app的包名 -->
<uses-permission android:name="com.example.mipushtest.permission.MIPUSH_RECEIVE" />
<!-- 这里com.example.mipushtest改成app的包名 -->
```



2）在信鸽注册前有没有设置小米的appid和appkey，以及有没有启动第三方推送
// 启动第三方推送


```
XGPushConfig.enableOtherPush(this, true);
// 设置小米的Appid和Appkey
XGPushConfig.setMiPushAppId(this, MIPUSH_APPID);
XGPushConfig.setMiPushAppKey(this, MIPUSH_APPKEY);
```



3）app的包名是否和小米推送官网上注册的包名一致
4）通过实现自定义的继承PushMessageReceiver的广播来监听小米注册的结果，查看注册返回码
5）启动logcat，观察tag为PushService的异常信息日志

**华为通道排查路径：**
1）检查【设置】->【应用管理】->【华为移动服务】的版本信息是否大于2.5.3
2）根据开发文档检查manifest文件配置是否正确
3）在信鸽注册之前，有没有启动第三方服务，以及华为APPID是否正确设置

##常见问题
<hr>

**Q1:iOS SDK中有没有使用热更新或者私有接口？**

A:信鸽SDK没有使用过热更新或私有接口，不会影响苹果审核。

**Q2:推送数量/推送频率限制？**

A:推送数量无限制。推送频率上，仅全量广播限频为每3秒一次，其他推送行为不限频。

**Q3:对单个设备，保存多少条离线信息？保存时间？**

A:离线消息Android最多保存2条，iOS最多保存1条；保存时间最多72小时。

**Q4:标签方面限制？**

A:单个设备最多设置100个标签，单个app全局最多可以有10000个不同的标签。

**Q5:信鸽与腾讯开放平台的APPID数据是否相通？**

A:当你在开放平台注册应用并使用信鸽后，应用的信息会自动从开放平台同步至信鸽平台，单独使用信鸽时不用重新接入应用。但是，在信鸽接入的应用不会同步至开放平台。

**Q6:当第一次注册成功后，没有反注册，以后使用还需要注册吗？**

A:不需要，只要没反注册，就不需要再次注册

**Q7:应用关闭或结束进程后，还能收到推送消息吗？**

A:信鸽推送主要依赖信鸽的service进行消息的收发，杀死进程之后信鸽service也被杀死，只能等待service被拉活或重启app才可以收到推送。若手机中有其他接入信鸽的app被打开，则可以利用其他app的service接收消息，但共享service通道也受手机ROM限制，无法保证百分之百的成功率。

**Q8:设备注册为什么收不到回调信息？**

A:注册操作中，后台只可能有三种出错行为：

(1)不响应；

(2)返回错误格式的数据包；

(3)返回错误码。这三种行为终端应该都可以检测到并给出回调。

**Q9:为什么我推送成功了，有了抵达量，点击量却等于0？**

iOS点击量统计需要调用特殊代码，具体请参考iOS开发文档。

**Q10:为什么会出现推送通知时，只有声音却没有文字信息的情况？**

A:该问题与系统有很大关系，需要拿设备的logcat来进行特定分析。

**Q11:token与Account区别？**

A:token是一台设备（device）的标识，账号是一个用户（users）的标识。一个token只能绑定一个账号，多次绑定时，以最后一次为准。

**Q12:账号在设备A上登录过，又在设备B上登录？给这个账号发信息会怎么样？**

A:设备B上能够收到推送。设备A无法收到推送。

**Q13:标签与账号的区别？**

A:标签是用于标识一个token或用户的一些属性，如广东省、男性、游戏玩家等。帐号是用户的账号，请勿用标签作为别名使用。

**Q14:在应用列表中看到“覆盖设备数”，具体指的是什么？**

A:是指该应用下处于注册状态的设备数/终端数，同时也是该应用在推送时可以覆盖到的最大设备数。终端若调用了unregister的接口，覆盖设备数会减少。

**Q15:为什么在web端推送出现服务器繁忙？**

A: 请先检查token以及所选推送环境是否正确，然后检查证书是否正确提交，若还出现相同错误可重新制作一份不带密码的证书提交再试。

**Q16:推送过程中，非定时推送（立即推送）能否撤销？**

A:不能，只有返回push_id的任务才可以做撤销操作。

**Q17:推送后查看推送列表，已经推送完成了，状态却显示推送中，怎么办？**

A:刷新再试试。

**Q18:在推送时，如何向单个用户推送消息？**

A:请参考开发手册，有关于“推送消息给单个设备”和“推送消息给单个账户或别名”的使用指南。

**Q19:用户重连上线后收到多条push的顺序是怎样？**

A:按照消息ID递增。客户端也是按照此规则收取消息，因此，收消息的顺序就是发消息的顺序。

**Q20:我现在有安卓的用户和iOS的用户，那我php后台要写两个不同的接口分别推给安卓用户和ios用户吗？**

A:需要调用两次推送接口 也可以把两个封装为一个。

**Q21:如果定时push选择的是过去的时间，是不是不会push出去？**

A:不是，选择过去的时间系统则会立刻发送。

**Q22:在信鸽管理台中创建token单推之后，历史明细中为什么没有推送记录？**

A:信鸽管理台中的推送历史明细只展示全量推送、标签推送和官网的号码包推送，不能展示单个token或者账号推送。

