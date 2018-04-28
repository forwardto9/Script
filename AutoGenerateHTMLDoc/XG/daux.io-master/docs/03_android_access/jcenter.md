

#Android SDK 集成指南

<hr>

##AndroidStudio自动集成

###一导入依赖
    AndroidStudio上可以使用jcenter远程仓库自动接入，不需要在项目中导入jar包和so文件；
    在AndroidManifest.xml中不需要配置信鸽相关的内容，jcenter 会自动导入。
    导入依赖过后修改应用配置，书写注册代码就能够实现信鸽快速接入。 
    对应的依赖版本号均是，官网上最新的版本。
    用户自定义的recevier.依然需要在Androidmanifest.xml配置相关节点。

    在app build.gradle文件下配置 以下内容
    
    android {
        ......
        defaultConfig {

            //信鸽官网上注册的包名.注意application ID 和当前的应用包名以及 信鸽官网上注册应用的包名必须一致。
            applicationId "你的包名" 
            ......

            ndk {
                //根据需要 自行选择添加的对应cpu类型的.so库。 
                abiFilters 'armeabi', 'armeabi-v7a', 'arm64-v8a' 
                // 还可以添加 'x86', 'x86_64', 'mips', 'mips64'
            }

            manifestPlaceholders = [

                XG_ACCESS_ID:"注册应用的accessid",
                XG_ACCESS_KEY : "注册应用的accesskey",
            ]
            ......
        }
        ......
    }

    dependencies {
        ......
        
    //完整的信鸽依赖三个都必须有，如果发生依赖冲突请根据对应的依赖版本号选择高版本的依赖。（使用jcenter自动接入请确认libs 中没有信鸽的相关jar包）
    
    //信鸽3.2.2 release版本
    //完整的信鸽依赖三个都必须有，如果发生依赖冲突请根据对应的依赖版本号选择高版本的依赖。（使用jcenter自动接入请                    确认libs 中没有信鸽的相关jar包） 
    
    //信鸽3.2.3 beta版本
    //compile 'com.tencent.xinge:xinge:3.2.3_1-beta'
    
    //信鸽jar
    compile 'com.tencent.xinge:xinge:3.2.2-release'
    //wup包
    compile 'com.tencent.wup:wup:1.0.0.E-release'
    //mid包
    compile 'com.tencent.mid:mid:4.0.6-release'
        
    }
  

    ***注意*** 

    如果在添加以上 abiFilter 配置之后android Studio出现以下提示：

        NDK integration is deprecated in the current plugin. Consider trying the new experimental plugin.

    则在 Project 根目录的gradle.properties文件中添加：

        android.useDeprecatedNdk=true


注 如需监听消息请参考XGBaseReceiver接口或者是demo的MessageReceiver类。自行继承XGBaseReceiver并且在配置文件中配置如下内容：

```xml
  <receiver android:name="完整的类名如:com.qq.xgdemo.receiver.MessageReceiver"
      android:exported="true" >
      <intent-filter>
          <!-- 接收消息透传 -->
          <action android:name="com.tencent.android.tpush.action.PUSH_MESSAGE" />
          <!-- 监听注册、反注册、设置/删除标签、通知被点击等处理结果 -->
          <action android:name="com.tencent.android.tpush.action.FEEDBACK" />
      </intent-filter>
  </receiver>
  ```
  
  ##手动集成
  
  ###注册并下载SDK

<hr>

前往信鸽管理台xg.qq.com，使用QQ号码登陆，进入应用注册页，填写“应用名称”和“应用包名”（必须要跟APP一致），选择“操作系统”和“分类”，最后点击“创建应用”。

应用创建成功后，点击“应用配置”即可看到APP专属的AccessId和AccessKey等信息。

注册完成后，请下载最新版本的Android SDK到本地，并解压。

###工程配置

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
       夹将所有的架构文件复制进去也就是SDK文档中的Other-Platform-SO下的所有文件夹。如图：
       
       
   ![](/assets/SO配置.jpg)
       
       



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
              <action android:name="当前应用的包名.PUSH_ACTION" />
      </intent-filter>
   </service>


<!-- 【必须】 【注意】authorities修改为 包名.AUTH_XGPUSH, 如demo的包名为：com.qq.xgdemo-->
  <provider
       android:name="com.tencent.android.tpush.XGPushProvider"
       android:authorities="当前应用的包名.AUTH_XGPUSH"
       android:exported="true"/>

  <!-- 【必须】 【注意】authorities修改为 包名.TPUSH_PROVIDER, 如demo的包名为：com.qq.xgdemo-->
  <provider
       android:name="com.tencent.android.tpush.SettingsContentProvider"
       android:authorities="当前应用的包名.TPUSH_PROVIDER"
       android:exported="false" />

  <!-- 【必须】 【注意】authorities修改为 包名.TENCENT.MID.V3, 如demo的包名为：com.qq.xgdemo-->
  <provider
       android:name="com.tencent.mid.api.MidProvider"
       android:authorities="当前应用的包名.TENCENT.MID.V3"
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
##注册以及部分日志输出。

<hr>

1.根据<a href="http://docs.developer.qq.com/xg/android_access/manual.html" target="_blank" >手动接入</a>或者<a href="http://docs.developer.qq.com/xg/android_access/jcenter.html" target="_blank" >自动接入</a>，配置好信鸽过后，获取信鸽注册日志（接入过程中建议调用有回调的注册接口，开启信鸽的debug日志输出。AndroidStudio 建议采用jcenter自动接入，无需在配置文件中配置信鸽各个节点，全部由依赖导入）。

***开启debug日志数据***

```java
 XGPushConfig.enableDebug(this,true);
```

***token注册***

```java
XGPushManager.registerPush(this, new XGIOperateCallback() {
@Override
public void onSuccess(Object data, int flag) {
//token在设备卸载重装的时候有可能会变
Log.d("TPush", "注册成功，设备token为：" + data);
}
@Override
public void onFail(Object data, int errCode, String msg) {
Log.d("TPush", "注册失败，错误码：" + errCode + ",错误信息：" + msg);
}
})
```
过滤"TPush"注册成功的日志如下：

```xml
10-09 20:08:46.922 24290-24303/com.qq.xgdemo I/XINGE: [TPush] get RegisterEntity:RegisterEntity [accessId=2100250470, accessKey=null, token=5874b7465d9eead746bd9374559e010b0d1c0bc4, packageName=com.qq.xgdemo, state=0, timestamp=1507550766, xgSDKVersion=3.11, appVersion=1.0]
10-09 20:08:47.232 24290-24360/com.qq.xgdemo D/TPush: 注册成功，设备token为：5874b7465d9eead746bd9374559e010b0d1c0bc4
```

***设置账号***

```java
//注意在3.2.2 版本信鸽对账号绑定和解绑接口进行了升级具体详情请参考API文档。
XGPushManager.bindAccount(getApplicationContext(), "XINGE");
```
过滤“TPush”账号注册成功的日志如下：

```xml
//如推送返回48账号无效，请确认账号接口调用成功
10-11 15:55:57.810 29299-29299/com.qq.xgdemo D/TPushReceiver: TPushRegisterMessage [accessId=2100250470, deviceId=853861b6bba92fb1b63a8296a54f439e, account=XINGE, ticket=0, ticketType=0, token=3f13f775079df2d54e1f82475a28bccd3bfef8c1]注册成功
```

***设置标签***

```java
XGPushManager.setTag(this,"XINGE");
```

设置标签成功的日志：

```xml
10-09 20:11:42.558 27348-27348/com.qq.xgdemo I/XINGE: [XGPushManager] Action -> setTag with tag = XINGE
```

***收到消息日志***

```xml
10-16 19:50:01.065 5969-6098/com.qq.xgdemo D/XINGE: [i] Action -> handleRemotePushMessage
10-16 19:50:01.065 5969-6098/com.qq.xgdemo I/XINGE: [i] >> msg from service,  @msgId=1 @accId=2100250470 @timeUs=1508154601660412 @recTime=1508154601076 @msg.date= @msg.busiMsgId=0 @msg.timestamp=1508154601 @msg.type=1 @msg.multiPkg=0 @msg.serverTime=1508154601000 @msg.ttl=259200 @expire_time=1508154860200076 @currentTimeMillis=1508154601076
10-16 19:50:01.095 5969-6098/com.qq.xgdemo D/XINGE: [m] Action -> handlerPushMessage
10-16 19:50:01.105 5969-6098/com.qq.xgdemo I/XINGE: [m] Receiver msg from server :PushMessageManager [msgId=1, accessId=2100250470, busiMsgId=0, content={"n_id":0,"title":"XGDemo","style_id":1,"icon_type":0,"builder_id":1,"vibrate":0,"ring_raw":"","content":"token 推送","lights":1,"clearable":1,"action":{"aty_attr":{"pf":0,"if":0},"action_type":1,"activity":""},"small_icon":"","ring":1,"icon_res":"","custom_content":{}}, timestamps=1508154601, type=1, intent=Intent { act=com.tencent.android.tpush.action.INTERNAL_PUSH_MESSAGE cat=[android.intent.category.BROWSABLE] pkg=com.qq.xgdemo (has extras) }, messageHolder=BaseMessageHolder [msgJson={"n_id":0,"title":"XGDemo","style_id":1,"icon_type":0,"builder_id":1,"vibrate":0,"ring_raw":"","content":"token 推送","lights":1,"clearable":1,"action":{"aty_attr":{"pf":0,"if":0},"action_type":1,"activity":""},"small_icon":"","ring":1,"icon_res":"","custom_content":{}}, msgJsonStr={"n_id":0,"title":"XGDemo","style_id":1,"icon_type":0,"builder_id":1,"vibrate":0,"ring_raw":"","content":"token 推送","lights":1,"clearable":1,"action":{"aty_attr":{"pf":0,"if":0},"action_type":1,"activity":""},"small_icon":"","ring":1,"icon_res":"","custom_content":{}}, title=XGDemo, content=token 推送, customContent=null, acceptTime=null]]
10-16 19:50:01.105 5969-6098/com.qq.xgdemo V/XINGE: [XGPushManager] Action -> msgAck(com.qq.xgdemo,1)
10-16 19:50:01.115 5969-6098/com.qq.xgdemo I/XINGE: [TPush] title encry obj:{"cipher":"YZXM+CuPhqaBn4eK0SE9ApWieHznugNT2uKo0OaXtlDDHLJiY7NlvSL2ZnlSb8E7yd7E7i9JU3g0PlFyYNLjokNp1buJuPoMYEHaJ0s6vmUMY+cq0Sv782XHxNzekV4a9mRcJ5xsOccIjH1VoskUmikfZJo3XLhZveWNYGPaoto="}
10-16 19:50:01.125 5969-6098/com.qq.xgdemo E/XINGE: [MessageInfoManager] delOldShowedCacheMessage Error! toDelTime: 1507981801138
10-16 19:50:01.145 5969-6098/com.qq.xgdemo I/XINGE: [MessageHelper] Action -> showNotification {"n_id":0,"title":"XGDemo","style_id":1,"icon_type":0,"builder_id":1,"vibrate":0,"ring_raw":"","content":"token 推送","lights":1,"clearable":1,"action":{"aty_attr":{"pf":0,"if":0},"action_type":1,"activity":""},"small_icon":"","ring":1,"icon_res":"","custom_content":{}}

```

##推送问题

<hr>

###推送时效性问题

全量推送接口，批量推送接口（批量账号，批量token，tag），会有一个30秒左右的任务调度时间。单推接口基本上秒达。（单推账号，单推token）秒达。注：在中午12点。晚6点到8点为推送高峰期，部分消息可能会延时到达。

***本地通知延时***

需要保证应用在前台，信鸽service存活，正常运行。本地通知才能展示，关闭应用无法展示本地通知，本地通知是根据网络心跳来判断弹出通知 大约5分钟一次心跳，不能保证准时弹出推送前后可能会有一定的时间差




###收不到推送的问题

用获取到的token，在<a href="http://xg.qq.com/xg" target="_blank" >信鸽web</a>推送。如无法收到推送请根据以下情况进行排查（请确保SDK版本是最新的版本，如果是旧版本出现问题，在新版本可能已经修复，如遇到web端推送报错，请刷新页面重试）。


####注册成功无法收到推送：

a.请查看当前的应用包名是否和注册信鸽应用时填写的应用包名是否一致。如果不一致，推送的时候 建议开启多包名推送。

b.查看设备是否开启通知栏权限，oppo,vivo.等手机，需要手动开启通知栏权限。

c.信鸽推送分为<a href="http://docs.developer.qq.com/xg/#推送通知" target="_blank" >通知栏消息</a>，和<a href="http://docs.developer.qq.com/xg/#应用内消息" target="_blank" >应用内消息</a>（透传消息），通知栏消息可以展示到通知栏，应用内消息不能展示到通知栏。

d.确认手机当前模式是正常模式，部分手机在低电量，勿扰模式，省电模式下，会对后台信鸽进程进行一系列网络和活动的限制。

####注册不成功无法收到推送：

***A.注册返回错误:***

如10004，20.等请参考<a href="http://docs.developer.qq.com/xg/push_ret_code.html" target="_blank" >信鸽错误码表</a>。

***错误10004***

原因：so文件导入不全，so是用来适配各种设备的不同型号的CPU，如出现10004的错误，应该查看 当前导入的so库文件是否支持当前设备的CPU。如果不支持需要添加对应的so文件（完整的SO库 在SDK文件夹下Other-Platform-SO目录内）。

***eclipse开发工具解决办法***：

将需要的对应设备CPU的SO文件复制到lib目前中。

***Androidstudio的开发工具的解决办法***：

Androidstudio可在main文件目录下 添加jniLibs命名的文件夹将SDK文档中的Other-Platform-SO下的7个so库文件夹添加至该目录 ，或者采用<a href="http://docs.developer.qq.com/xg/android_access/jcenter.html" target="_blank" >自动接入</a>，无须手动导入so文件。




***B.如注册无回调:***

确认当前***网络情况***是否良好（建议使用4G网络测试，wifi由于使用人数过多可能造成 网络带宽不足），是否添加***wup包***，以及***努比亚手机***(部分机型不支持第三方推送)在 2015年下半年和2016年出的机器都无法注册，具体机型包括nubia Z11系列，nubiaZ11S系列，nubiaZ9S系列。可以的机器都是之前的机器，包括Z7系列，my布拉格系列（在信鸽2.47和信鸽3.X上都有这个现象）。


####关闭应用无法收到推送

目前第三方推送都无法保证关闭应用过后还可以收到推送消息，这个是手机定制ROM对信鸽service的限制问题，信鸽的一切活动都需要建立在信鸽的service能够正常联网运行。

QQ，微信是系统级别的应用白名单，相关的service不会应用关闭应用而退出所以用户感知推出应用过后还可以收到消息其实相关的service 还是能够在后台存活的。

Android端在应用退出，信鸽service和信鸽的服务器断开连接后，这个时候给这个设备下发的消息，会变成离线消息，离线消息最多保存72消息，每个设备最多保存两条，如果有多条离线消息。在关闭应用期间推送的消息，如开启应用无法收到，请检查是否调用了反注册接口：XGPushManager.unregisterPush(this);。

####账号推送收不到

每个账号最多可以绑定15个设备，超过15个设备，会自动顶掉最先绑定的一个账号。每个设备注册的有效账号为最后一次绑定的账号，如果多个设备同时绑定多个账号，则全部能收到推送。

####tag推送收不到

请确认tag标签是否绑定成功，一个应用最多有10000个 标签（tag）， 每个token在一个应用下最多100个 标签（tag）， 标签（tag）中不准包含空格。

###信鸽推送是否支持海外

只要能ping通信鸽服务器域名 openapi.xg.qq.com  就能够收到推送消息，信鸽海外服务器部署在香港，由于在海外地区网络延时较高，信鸽在海外的推送效果会略低于在国内的推送效果。

测试方法：
在想测试的网络环境，打开命令行，输入 ping openapi.xg.qq.com  再回车 终端输出如下日志 表示能够成功连上信鸽服务器：

```xml
admin$ ping openapi.xg.qq.com
PING openapi.xg.qq.com (******* ip地址): 56 data bytes
64 bytes from 14.215.138.42: icmp_seq=0 ttl=54 time=4.364 ms
64 bytes from 14.215.138.42: icmp_seq=1 ttl=54 time=5.352 ms
64 bytes from 14.215.138.42: icmp_seq=2 ttl=54 time=4.514 ms
64 bytes from 14.215.138.42: icmp_seq=3 ttl=54 time=4.924 ms
64 bytes from 14.215.138.42: icmp_seq=4 ttl=54 time=4.447 ms
64 bytes from 14.215.138.42: icmp_seq=5 ttl=54 time=4.843 ms
64 bytes from 14.215.138.42: icmp_seq=6 ttl=54 time=5.946 ms
```

##推送数据问题

####推送暂停

a.相同的内容的全量推送每小时只能推送一次，超过一次推送会被暂停。

b.每小时最多推送30条全量推送，超过三十次会被暂停。

####效果统计

【次日】：推送完第二天才能看到推送数据；

【实时】：推送完马上可以看到推送数据。目前每周仅支持14次的实时数据统计。

####实发

在消息离线保存时间内，有成功连接到信鸽服务器，并且有正常下发的量。（如：消息离线保存时间为3天，实发数据会在第四天稳定，数据会随着设备不断开启连接到信鸽服务器的数量而增加）。

####历史明细

历史明细 只展示全量推送，tag推送，和官网的号码包推送。（其他推送接口不展示推送详情）

####数据概览

展示的是当天的数据，某天的数据是在那一天中各种推送行为的推送总量。（分为单推，广播也就是批量和全量推送，通知栏消息和应用内消息四类）

##消息点击事件，以及跳转页面方法。

<hr>

由于目前sdk点击 消息默认会有点击事件，默认的点击事件是打开主界面。所以在终端点击消息回调onNotifactionClickedResult方法内，设置跳转操作，自定义的跳转和默认的点击事件造成冲突。反应情况是会跳转到指定界面过后再回到主界面。所以不能再onNotifactionClickedResult内设置跳转。

解决办法如下(推荐使用第一种方式)：

一.在下发消息的时候设置点击消息要跳转的页面。

a.可以直接在web端高级功能内设置deeplink包名+类名） ;

b.后台设置Messege 类中的 Action字段的 的SetActivity方法（包名+类名），通过XGPushClickedResult 可以获取到消息的相关内容。标题 ，内容，和附加参数。

后台设置跳转页面的方法如下（以javaSDK为例）：

```java
		......
		
		XingeApp android= new XingeApp(access ID, secret key);
		  Message message_android = new Message();
		  message_android.setExpireTime(86400);
		  message_android.setTitle("信鸽推送");
		  message_android.setType(1);
		  message_android.setContent("android test2");      
		  ClickAction action = new ClickAction();
		  action.setActivity("com.qq.xgdemo.activity.SettingActivity");
		  message_android.setAction(action);
		  JSONObject ret1= android.pushSingleDevice("token",message_android);
 		......
```

 终端获取Message 个参数的方法如下:
 
```java
		//this必须为点击消息要跳转到页面的上下文。
		XGPushClickedResult clickedResult = XGPushManager.onActivityStarted(this);
		//获取消息附近参数
		String  ster= clickedResult.getCustomContent();
		//获取消息标题
		String  set = clickedResult.getTitle(); 
		//获取消息内容
		String  s= clickedResult.getContent();
```

二.发应用内消息到终端，用户自定义通知栏，采用<a href="http://docs.developer.qq.com/xg/android_access/api.html#本地通知" target="_blank" >本地通知</a>弹出通知，设置要跳转的页面。

三.使用Intent来跳转指定页面（Android 3.2.3版本使用此方式）

1.需要在客户端app的manifest上配置要跳转的页面，如要跳转AboutActivity指定页面：

```java
<activity
android:name="com.qq.xg.AboutActivity"
android:theme="@android:style/Theme.NoTitleBar.Fullscreen" >
<intent-filter >
   <action android:name="android.intent.action.VIEW" />
   <category android:name="android.intent.category.DEFAULT"/>
    <data android:scheme="xgscheme"
          android:host="com.xg.push"
          android:path="/notify_detail" />
</intent-filter>
</activity>

```

2.若使用服务端SDK设置intent进行跳转，可设置intent为（以Java SDK为例）：

```java
action.setIntent("xgscheme://com.xg.push/notify_detail");
```



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
-keep class com.qq.taf.jce.** {*;} 
```
##多行显示
<hr>


Android多行显示特性，在2.38及以上版本已经实现并默认开启，但此功能部分机型生效。

##多包名推送
<hr>


目前市场上部分app针对不同渠道有不同的包名，同一款app可能会有上百个包名，这时就可以利用access id向该app的所有包名进行推送。在多包名推送模式下，设备上所有使用这个access id注册推送的app都会收到这条消息。具体实现方法:在进行推送前，

a:在服务端推送时可将推送参数 multi_pkg 设置为1；

b:在web端推送时可在高级功能中开启多包名推送。



