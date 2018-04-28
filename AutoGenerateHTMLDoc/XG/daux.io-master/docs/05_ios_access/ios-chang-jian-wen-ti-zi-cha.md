#iOS常见问题自查

问：iOS是否支持离线保存
答：苹果默认支持离线保存1条消息。关于离线保存的时长苹果官方文档没有明确的说明。

问：为何每天看到的全量推送的实发量会有波动，有时高有时低
答：信鸽后台会根据每天推送时，apns返回的错误来清理已经过期的无效token。这个清理每天都会执行一次，因此第二天的全量推送实发量是已经除去了前一天的过期token的数量，可能会比前一天的实发量少。这是属于正常现象。

问：初始化信鸽接口，出现如下日志
2017-10-26 15:13:38.888951+0800 XG-Demo[2295:1737660] [xgpush] 服务器返回码: 20
答：在初始化信鸽的方法中 appid和appkey不要使用宏定义

问：什么情况会出现推送暂停
答：每小时最多可创建30条全量推送，超过30条的推送将被推送暂停
一小时内创建推送内容完全一样的推送，将被推送暂停
推送暂停的任务将不会下发，请视情况重新创建推送

问：上传证书到管理台失败
答：	
a）验证失败，请刷新后重试	>> 用编辑器打开证书文件，找到friendlyname字段如果同行有？‘，将其修改成别的，保存后重新上传。	
b）不包含push参数	>> 制作新的推送证书	
c）文件大小为0kb，不能上传	>> 重新转换pem格式	
信鸽证书制作教程：https://v.qq.com/x/page/u0302fjna1h.html

问：终端出现"Error Domain=NSCocoaErrorDomain Code=3000 "未找到应用程序的“aps-environment”的授权字符串" UserInfo=0x16545fc0 {NSLocalizedDescription=未找到应用程序的“aps-environment”的授权字符串}"错误 
答：这是由于app证书没有推送权限引起的.请重新配置证书

问：设备收到消息没有进入回调
答：iOS10会进静默通知的回调方法中

问：设置/删除标签的时候出现如下错误exception.name= WupSerializableExceptionexception.reason= -[XGJceOutputStream writeAnything:tag:required:], 349: assert(0) fail!
答：请在registerDevice之后再setTag/delTag.在registerDevice之前进行tag操作会出现这个错误

问：token和别名（account）的对应关系
答：一个设备一个token，token在注册推送时由苹果下发，一个token最多绑定一个account，一个account最多绑定15个token，超出数量时会顶替之前绑定的token。iOS的token是会变化的，卸载，重装，刷机，重置都会导致token发生变化。问：创建推送成功了，但推送列表没有该条推送的记录答：推送列表只展示针对所有设备和批量设备的推送记录问：如何播放自定义通知音？答：把音频文件放到bundle目录下，创建推送时，给sound字段传入音频文件名称。

问：使用信鸽服务端sdk，怎么创建静默推送
答：给参数content-available赋值1，同时不使用setalert

