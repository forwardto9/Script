#FCM通道集成指南

信鸽集成的谷歌FCM推送通道，在外国可用谷歌service框架的手机上能够实现不打开应用收到推送消息。在没有fcm的手机rom下依旧走信鸽的推送通道。此功能必须先集成信鸽推送 3.2beta版本。

##获取FCM推送秘钥
[FireBase官网](https://firebase.google.com/?hl=zh-cn)注册应用信息。并将获取到的FCM应用推送服务器密钥和您信鸽的access id 通过邮件dtsupport@tencent.com 发送给我们，或者添加QQor微信2631775454。目前需要信鸽的后台手动将信鸽的access id和FCM的服务器密钥进行绑定。并下载google-services.json 文件。如图所示：

获取json文件：
![](/assets/获取fcmjson.jpeg )

获取服务器密钥：
![](/assets/获取服务器密钥.jpeg)


##AS开发集成方法

1.配置google-services.json文件。如图所示：

![](/assets/配置json.png )


2. 配置gradle,集成谷歌service.

a)在项目级的build.gradle文件中的dependencies节点中添加下面代码：
```xml
classpath 'com.google.gms:google-services:3.1.0'
```
在应用级的build.gradle文件中添加依赖
```xml

compile 'com.tencent.xinge:fcm:3.1.2-1-release'

compile 'com.google.firebase:firebase-messaging:9.0.0'

注：云消息传递

compile 'com.google.android.gms:play-services-base:9.0.0'

注：Google配置google-play-services网（信鸽只用到了检测设备是否支持google service功能，要求版本大于9.0.0）：https://developers.google.com/android/guides/setup#add_google_play_services_to_your_project

//并在应用级的gradle文件的最后一行代码中新增

apply plugin: 'com.google.gms.google-services'

```
##Eclipse开发集成方法

在集成好信鸽的基础下增加以下的配置：

1.配置google-services.json 文件，放在assets的目录下

2.把Xg4FCM-v3.xxx.jar，firebase-common-9.0.0.jar，firebase-iid-9.0.0.jar，firebase-messaging-9.0.0.jar，play-services-base-9.0.0.jar，play-services-basement-9.0.0.jar放到libs目录下

3.在AndroidManifest.xml中添加以下配置：

```xml
<application>
<!-- [START fcm_receiver] -->
<receiver
android:name="com.google.firebase.iid.FirebaseInstanceIdReceiver"
android:exported="true"
android:permission="com.google.android.c2dm.permission.SEND" >
<intent-filter>
<action android:name="com.google.android.c2dm.intent.RECEIVE" />
<action android:name="com.google.android.c2dm.intent.REGISTRATION" />
<!-- 下面修改为应用的包名 -->
<category android:name="com.qq.xgdemo" />
</intent-filter>
</receiver>
<!-- [END fcm_receiver] -->
<receiver
android:name="com.google.firebase.iid.FirebaseInstanceIdInternalReceiver"
android:exported="false" />
<!-- [START fcm_listener] -->
<service
android:name="com.tencent.android.fcm.XGFcmListenerService"
android:exported="true" >
<intent-filter android:priority="-500" >
<action android:name="com.google.firebase.MESSAGING_EVENT" />
</intent-filter>
</service>
<!-- [END fcm_listener] -->
<!-- [START instanceId_listener] -->
<service
android:name="com.tencent.android.fcm.XGFcmInstanceIDListenerService"
android:exported="true" >
<intent-filter android:priority="-500" >
<action android:name="com.google.firebase.INSTANCE_ID_EVENT" />
</intent-filter>
</service>
<!-- 9080000是google-play-services.jar的版本，要求手机上的google play service版本大于此值 -->
<meta-data android:name="com.google.android.gms.version" android:value="9080000" />
<!-- [END instanceId_listener] -->

</application>

<!-- [START gcm_permission] -->
<uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />
<!-- 声明并使用一个自定义的权限以此来确保只有这个程序可以接收你的GCM消息, 如果是4.1或更高版本的系统就不需要这个权限，com.qq.xgdemo改成应用包名 -->
<permission android:name="应用包名.permission.C2D_MESSAGE" android:protectionLevel="signature" />
<uses-permission android:name="应用包名.permission.C2D_MESSAGE" />
<!-- [END gcm_permission] -->
```