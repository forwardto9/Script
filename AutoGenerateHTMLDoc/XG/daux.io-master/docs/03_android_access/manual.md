#Android SDK快速接入

<hr>

##注册并下载SDK

<hr>

前往信鸽管理台xg.qq.com，使用QQ号码登陆，进入应用注册页，填写“应用名称”和“应用包名”（必须要跟APP一致），选择“操作系统”和“分类”，最后点击“创建应用”。

应用创建成功后，点击“应用配置”即可看到APP专属的AccessId和AccessKey等信息。

注册完成后，请下载最新版本的Android SDK到本地，并解压。

##工程配置

<hr>

将SDK导入到工程的步骤为：

（1）创建或打开Android工程（关于如何创建Android工程，请参照开发环境的章节）。

（2）将信鸽 SDK目录下的libs目录所有文件拷贝到工程的libs（或lib）目录下。

（3）选中libs（或lib）目录下的信鸽jar包，右键菜单中选择Build Path， 选择Add to Build Path将SDK添加到工程的引用目录中。
 
（4）.so文件是信鸽必须的组件，支持armeabi、armeabi-v7a、misp和x86平台，请根据自己当前.so支持的平台添加

     a）如果你的项目中没有使用其它.so，建议复制四个平台目录到自己工程中；

     b）如果已有.so文件，只需要复制信鸽对应目录下的文件；

     c）若是MSDK接入的游戏，通常只需要armeabi目录下的.so；

     d）若当前工程已经有armeabi，那么只需要添加信鸽的armeabi下的.so，其它目录无需添加。其它情况类似，只添 
        加当前 平台存在的平台即可。

    e）若在Androidstudio中导入so文件出错（错误10004.SOERROR），在main文件目录下 添加jniLibs命名的文件 
       夹将所有的架构文件复制进去也就是SDK文档中的Other-Platform-SO下的所有文件夹。



（5）打开Androidmanifest.xml，添加以下配置（建议参考下载包的Demo修改），其中YOUR_ACCESS_ID和YOUR_ACCESS_KEY替换为APP对应的accessId和accessKey,请确保按照要求配置，否则可能导致服务不能正常使用。

```xml
<application
  <!-- 【必须】 信鸽receiver广播接收 -->
  <receiver android:name="com.tencent.android.tpush.XGPushReceiver"
   android:process=":xg_service_v3" >
  <intent-filter android:priority="0x7fffffff" >
        <!-- 【必须】 信鸽SDK的内部广播 -->
        <action android:name="com.tencent.android.tpush.action.SDK" />
        <action android:name="com.tencent.android.tpush.action.INTERNAL_PUSH_MESSAGE" />
        <!-- 【必须】 系统广播：开屏和网络切换 -->
       <action android:name="android.intent.action.USER_PRESENT" />
       <action android:name="android.net.conn.CONNECTIVITY_CHANGE" />
       <!-- 【可选】 一些常用的系统广播，增强信鸽service的复活机会，请根据需要选择。当然，你也可以添加APP自定义的一些广播让启动service -->
       <action android:name="android.bluetooth.adapter.action.STATE_CHANGED" />
       <action android:name="android.intent.action.ACTION_POWER_CONNECTED" />
       <action android:name="android.intent.action.ACTION_POWER_DISCONNECTED" />
       </intent-filter>
  </receiver>

<!-- 【可选】APP实现的Receiver，用于接收消息透传和操作结果的回调，请根据需要添加 -->
 <!-- YOUR_PACKAGE_PATH.CustomPushReceiver需要改为自己的Receiver： -->
  <receiver android:name="com.qq.xgdemo.receiver.MessageReceiver"
      android:exported="true" >
      <intent-filter>
          <!-- 接收消息透传 -->
          <action android:name="com.tencent.android.tpush.action.PUSH_MESSAGE" />
          <!-- 监听注册、反注册、设置/删除标签、通知被点击等处理结果 -->
          <action android:name="com.tencent.android.tpush.action.FEEDBACK" />
      </intent-filter>
  </receiver>

   <!-- 【注意】 如果被打开的activity是启动模式为SingleTop，SingleTask或SingleInstance，请根据通知的异常自查列表第8点处理-->
   <activity
        android:name="com.tencent.android.tpush.XGPushActivity"
        android:exported="false" >
        <intent-filter>
           <!-- 若使用AndroidStudio，请设置android:name="android.intent.action"-->
            <action android:name="" />
        </intent-filter>
   </activity>

   <!-- 【必须】 信鸽service -->
   <service
       android:name="com.tencent.android.tpush.service.XGPushServiceV3"
       android:exported="true"
       android:persistent="true"
       android:process=":xg_service_v3" />


  <!-- 【必须】 提高service的存活率 -->
  <service
      android:name="com.tencent.android.tpush.rpc.XGRemoteService"
      android:exported="true">
      <intent-filter>
 <!-- 【必须】 请修改为当前APP包名 .PUSH_ACTION, 如demo的包名为：com.qq.xgdemo -->
              <action android:name="您的包名.PUSH_ACTION" />
      </intent-filter>
   </service>


<!-- 【必须】 【注意】authorities修改为 包名.AUTH_XGPUSH, 如demo的包名为：com.qq.xgdemo-->
  <provider
       android:name="com.tencent.android.tpush.XGPushProvider"
       android:authorities="com.qq.xgdemo.AUTH_XGPUSH"
       android:exported="true"/>

  <!-- 【必须】 【注意】authorities修改为 包名.TPUSH_PROVIDER, 如demo的包名为：com.qq.xgdemo-->
  <provider
       android:name="com.tencent.android.tpush.SettingsContentProvider"
       android:authorities="com.qq.xgdemo.TPUSH_PROVIDER"
       android:exported="false" />

  <!-- 【必须】 【注意】authorities修改为 包名.TENCENT.MID.V3, 如demo的包名为：com.qq.xgdemo-->
  <provider
       android:name="com.tencent.mid.api.MidProvider"
       android:authorities="com.qq.xgdemo.TENCENT.MID.V3"
       android:exported="true" >
  </provider>



<!-- 【必须】 请将YOUR_ACCESS_ID修改为APP的AccessId，“21”开头的10位数字，中间没空格 -->
   <meta-data
       android:name="XG_V2_ACCESS_ID"
       android:value="YOUR_ACCESS_ID" />
   <!-- 【必须】 请将YOUR_ACCESS_KEY修改为APP的AccessKey，“A”开头的12位字符串，中间没空格 -->
   <meta-data
       android:name="XG_V2_ACCESS_KEY"
       android:value="YOUR_ACCESS_KEY" />
</application>
<!-- 【必须】 信鸽SDK所需权限   -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />
<!-- 【常用】 信鸽SDK所需权限 -->
<uses-permission android:name="android.permission.RECEIVE_USER_PRESENT" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_SETTINGS" />
<!-- 【可选】 信鸽SDK所需权限 -->
<uses-permission android:name="android.permission.RESTART_PACKAGES" />
<uses-permission android:name="android.permission.BROADCAST_STICKY" />
<uses-permission android:name="android.permission.KILL_BACKGROUND_PROCESSES" />
<uses-permission android:name="android.permission.GET_TASKS" />
<uses-permission android:name="android.permission.READ_LOGS" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BATTERY_STATS" />
```

##启动并注册APP

<hr>

完成工程配置后，打开工程的主Activity，在其onCreate(Bundle savedInstanceState)重载方法内，添加以下代码，完成信鸽服务的启动与APP注册过程。

// 开启logcat输出，方便debug，发布时请关闭

// XGPushConfig.enableDebug(this, true);

 // 如果需要知道注册是否成功，请使用registerPush(getApplicationContext(), XGIOperateCallback)带callback版本

// 如果需要绑定账号，请使用registerPush(getApplicationContext(),account)版本

// 具体可参考详细的开发指南

// 传递的参数为ApplicationContext
Context context = getApplicationContext();
XGPushManager.registerPush(context);

// 其它常用的API：

 // 绑定账号（别名）注册：registerPush(context,account)或registerPush(context,account, XGIOperateCallback)，其中account为APP账号，可以为任意字符串（qq、openid或任意第三方），业务方一定要注意终端与后台保持一致。

// 取消绑定账号（别名）：registerPush(context,"*")，即account="*"为取消绑定，解绑后，该针对该账号的推送将失效

// 反注册（不再接收消息，用户没有业务要求，尽量不要调用此接口）：unregisterPush(context)

// 设置标签：setTag(context, tagName)

// 删除标签：deleteTag(context, tagName)

代码嵌入完成后，启动APP，如果在logcat中的TPush标签看到以下类似的输出，说明已经注册成功，并返回token。
注意：

Android Token长度为40位

iOS Token长度为64位

##去管理台推送验证

<hr>

前往信鸽前台，选择“创建通知”，输入“标题”和“内容”，点击“确认推送”。稍等几秒后，如果顺利的话，终端设备应该能够收到这条通知。

此时，APP已经具备接收通知推送的能力。

如果还需要更高级的功能，请继续阅读或参数《SDK开发指南》

##异常自查列表

<hr>

信鸽的发布包都是经过严格测试的，遇到问题时，尤其是开发环境问题，建议先自行搜索网上解决方案。

常见的检查列表：

(1)设备是否正常联网？

(2)检查AndroidManifest.xml是否配置正确？建议直接参考demo的例子改

* accessId、accessKey设置是否与前台注册的一致？
* 相关权限是否齐全？
* receiver、service和activity相关组件是否配置好？

(3)设备是否注册成功？

(4)当前APP包名是否与前台注册的一致，如果不一致请在前台选中“使用多包名”选项？

(5)前台下发通知时，“时段控制”选项里的时间段是否符合终端设备当前时间？

(6)请根据“常见问题与解答”，看看是否有解决方案。

(7)2.30及以上版本请检查xml配置文件是否添加com.tencent.android.tpush.XGPushActivity相关的内容

(8)停留在后台的APP点击通知不能打开APP：被打开的activity（特别是LAUNCHER）启动模式为SingleTop，
SingleTask或SingleInstance，请在该activity重载onNewIntent方法：

```java
@Override protected void onNewIntent(Intent intent) {
 super.onNewIntent(intent);
 setIntent(intent);// 必须要调用这句
 }
```

(9)对于使用AndriodStudio的同学，若AndroidManifest.xml编译不通过，XGPushActivity配置改为：

<action android:name="android.intent.action" />


(10)请检查AndroidManifest.xml是否已正确配置-XGPushProvider、SettingsContentProvider和MidProvider，且provider中的authorities中是否正确设置：

android:authorities="com.qq.xgdemo.AUTH_XGPUSH"，应用包名为当前APP包名，如com.tencent.xgdemo

(11)是否已设置APP默认的icon？由于系统原因，若没有icon，通知将不能展示。

(12)（2.36之前的版本）已知MIUI V6上会禁用所有静态广播，若出现有类似的情况，请添加以下代码兼容该系统。

// 在XGPushManager.registerPush(context)或其它版本的注册接口之后调用以下代码

```java
// 使用ApplicationContext
Context context = getApplicationContext();
Intent service = new Intent(context, XGPushService.class);
 context.startService(service);
 ```

(13)点击通知，出现不能打开activity的情况，请在AndroidManifest.xml中将XGPushActivity的exported属性设置为true。

(14)点击通知，出现重复打开APP的情况，请将被打开的Activity启动模式改为SingleTop，SingleTask或SingleInstance。

(15)点击通知，不希望触发activity被打开的动作，可以：1.推送时，填写一个不存在的页面名称；2.使用消息透传（命令字）推送，收到消息后，自己弹出通知。

##包冲突

<hr>

(1)jar包冲突：

如果提示jar包冲突，请删除冲突的包，保留一份即可，建议保留版本高的。
常见的冲突有：

a）MSDK与信鸽冲突：删除wup.jar

b）MTA与信鸽冲突：删除低版本的mid.jar


##代码混淆

<hr>

如果你的项目中使用proguard等工具做了代码混淆，请保留以下选项，否则将导致信鸽服务不可用。

```xml
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep class com.tencent.android.tpush.** {* ;}
-keep class com.tencent.mid.** {* ;}
-keep public class * extends com.qq.taf.jce.JceStruct{*;}
```

##配置推送统计

<hr>

2.30及以上版本：使用信鸽SDK内置的activity展示页面，默认已经统计通知/消息的抵达量、通知的点击和清除动作。

XGPushManager.onActivityStarted(this)获取通知被点击及自定义key-value由原来的onStart()改为onResume()

```java
@Override protected void onResume() {
super.onResume();
XGPushClickedResult click = XGPushManager.onActivityStarted(this);
if (click != null) {
 // 判断是否来自信鸽的打开方式
  // 根据实际情况处理...
  // 如获取自定义key-value
  } }
  ```

同理，XGPushManager.onActivityStoped(this)由onStop()改为onPause()内调用，即：

```java
@Override protected void onPause() {
      super.onPause();
     XGPushManager.onActivityStoped(this);
}
```

**注意：**

1）需要将onActivityStarted和onActivityStoped嵌入到所有可能被打开的activity，建议所有activity都加上。

2）如果被打开的activity启动模式为SingleTop，SingleTask或SingleInstance，请根据以下在该activity重载onNewIntent方法：

```java
@Override protected void onNewIntent(Intent intent) {
super.onNewIntent(intent);
setIntent(intent);// 必须要调用这句
}
```

通知在通知栏被点击或清除时的回调，即自定义Receiver（需重载XGPushBaseReceiver）的
onNotifactionClickedResult重载方法中区分点击和清除动作，XGPushClickedResult添加getActionType()，其中

XGPushClickedResult.NOTIFACTION_CLICKED_TYPE表示点击操作，
XGPushClickedResult.NOTIFACTION_DELETED_TYPE表示清除操作。即：

```java
@Override
public void onNotifactionClickedResult(Context context,
XGPushClickedResult message) {
if (context == null || message == null) {
return;
}
if (message.getActionType() == XGPushClickedResult.NOTIFACTION_CLICKED_TYPE) {
 // 通知在通知栏被点击啦。。。。。
 // APP自己处理点击的相关动作
// 这个动作可以在activity的onResume也能监听，请看第3点相关内容
} else if (message.getActionType() == XGPushClickedResult.NOTIFACTION_DELETED_TYPE) {
// 通知被清除啦。。。。
// APP自己处理通知被清除后的相关动作
 }
 }
 ```



 ##多行显示

 <hr>

 Android多行显示特性，在2.38及以上版本已经实现并默认开启，但此功能部分机型生效。


 ##多包名推送

 <hr>

 目前市场上部分app针对不同渠道有不同的包名，同一款app可能会有上百个包名，这时就可以利用access id向该app的所有包名进行推送。在多包名推送模式下，设备上所有使用这个access id注册推送的app都会收到这条消息。
单应用多包名推送分为简单的三个步骤：

1）在信鸽前台注册应用，无需填写包名；若已经填好包名，也不会影响推送效果；

2）集成最新SDK在应用内；

3）在进行推送前，将推送参数 multi_pkg 设置为1；
