#信鸽Android 3.版本升级指南

<hr>

1.	【必须】提取SDK文档中的最新jar包替换当前信鸽SDK版本。                         
2.	【必须】根据所需平台，提取libtpnsSecurity.so和libxguardian.so替换老版本

3.	【必须】设置XGPushActivity和用户自定义的MessageReceiver的android:exported建议设 
置为"false"
            
```xml 
<activity android:name="com.tencent.android.tpush.XGPushActivity" android:exported="false" > </activity> 

<receiver android:name="您的自定义MessageReceiver，继承于XGPushBaseReceiver" android:exported="true"> 
      <intent-filter> 
            <!-- 接收消息透传 --> 
            <action android:name="com.tencent.android.tpush.action.PUSH_MESSAGE" /> 
            <!-- 监听注册、反注册、设置/删除标签、通知被点击等处理结果 --> 
            <action android:name="com.tencent.android.tpush.action.FEEDBACK" />
      </intent-filter> 
</receiver> ```

4.【必须】检查是否配置com.tencent.android.tpush.service.XGPushServiceV3和com.tencent.android.tpush.rpc.XGRemoteService，若无配置则功能不可使用

```xml
<!-- 【必须】 信鸽service -->
       <service
           android:name="com.tencent.android.tpush.service.XGPushServiceV3"
           android:exported="true"
           android:persistent="true"
           android:process=":xg_service_v3" />

<!-- 【必须】 通知service，此选项有助于提高抵达率 -->
       <service
           android:name="com.tencent.android.tpush.rpc.XGRemoteService"
           android:exported="true" >
           <intent-filter>
               <!-- 【必须】 请修改为当前APP包名.PUSH_ACTION-->
               <action android:name="com.qq.xgdemo.PUSH_ACTION" />
           </intent-filter>
       </service>```

5.【必须】检查是否配置com.tencent.android.tpush.XGPushProvider、com.tencent.android.tpush.SettingsContentProvider和com.tencent.mid.api.MidProvider，若无配置则功能不可使用

```xml
<!-- 【必须】 【注意】authorities修改为 包名.AUTH_XGPUSH, 如demo的包名为：com.qq.xgdemo-->
       <provider
           android:name="com.tencent.android.tpush.XGPushProvider"
           android:authorities="com.qq.xgdemo.AUTH_XGPUSH"
           android:exported="true"
           />       
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
```

6.	【可选】整理权限

```xml
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

   <!-- 【可选】 信鸽SDK所需权限 -->
   <uses-permission android:name="android.permission.WRITE_SETTINGS" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.RESTART_PACKAGES" />
   <uses-permission android:name="android.permission.BROADCAST_STICKY" />
   <uses-permission android:name="android.permission.KILL_BACKGROUND_PROCESSES" />
   <uses-permission android:name="android.permission.GET_TASKS" />
   <uses-permission android:name="android.permission.READ_LOGS" />
   <uses-permission android:name="android.permission.BLUETOOTH" />
   <uses-permission android:name="android.permission.BATTERY_STATS" /> ```
