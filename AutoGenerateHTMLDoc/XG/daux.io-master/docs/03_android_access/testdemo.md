#信鸽测试Demo的用法介绍

##下载Demo

信鸽的demo工程在SDK文件内，需要先行[下载SDK](http://xg.qq.com/ctr_index/download)。

##注册测试应用

注册测试应用的名称不限，但是包名必须为com.qq.xgdemo。（如果包名不一致推送的时候需要勾选多包名推送）。并获取注册完整过后应用对应的ACCESSID和ACCESSKEY。

![](/assets/注册信鸽demo.png)

##配置工程

###AndroidStudio工程


需要将获取到的测试应用的ACCESSID和ACCESSKEY配置到demo工程app模块下的build.gradle文件下的ManifestPlaceholders节点。如图所示：

![](/assets/AndroidStudioDemo.png)

###Eclipse工程

需要将获取到的测试应用的ACCESSID和ACCESSKEY配置到demo工程中的AndroidManifest.xml文件下的<mata-data>节点下!

![](/assets/eclipseDemo.png)


##运行代码

出现如下日志说明信鸽注册成功。（日志tag:"TPush"）:

```xml
10-09 20:08:46.922 24290-24303/com.qq.xgdemo I/XINGE: [TPush] get RegisterEntity:RegisterEntity [accessId=2100250470, accessKey=null, token=5874b7465d9eead746bd9374559e010b0d1c0bc4, packageName=com.qq.xgdemo, state=0, timestamp=1507550766, xgSDKVersion=3.11, appVersion=1.0]
10-09 20:08:47.232 24290-24360/com.qq.xgdemo D/TPush: 注册成功，设备token为：5874b7465d9eead746bd9374559e010b0d1c0bc4
```

##推送测试

获取日志输出的设备token。通过信鸽web端的应用管理中创建推送。如图所示

![](/assets/推送测试.png)


