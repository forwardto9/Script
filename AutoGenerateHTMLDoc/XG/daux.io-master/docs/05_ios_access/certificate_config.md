#iOS 证书设置指南

##iOS证书命令
<hr>

__证书有效期__

```shell
openssl x509 -in xxx.pem -noout -dates
```

__连接APNS测试证书是否合法__

1、开发环境

```shell
openssl s_client -connect gateway.sandbox.push.apple.com:2195 -cert xxx.pem -key xxx.pem
```

2、生产环境

```shell
openssl s_client -connect gateway.push.apple.com:2195 -cert xxx.pem -key xxx.pem
```

##指南介绍
<hr>

本指南用于介绍iOS证书如何设置

配置好证书后请前往[iOS SDK 完整接入]

<br>
### 设置步骤

首先，登录苹果开发者中心网站。然后点击Certificates,Identifiers & Profiles

![](http://developer.qq.com/wiki/xg/imgs/20151118164839_43490.jpg)

然后点击Certificates

![](http://developer.qq.com/wiki/xg/imgs/20151118164854_57803.jpg)

选中需要制作Push证书的应用，勾选Push服务

![](http://developer.qq.com/wiki/xg/imgs/20151118165407_29483.jpg)

下面以制作开发证书为例演示。点击Create Certificate…

![](http://developer.qq.com/wiki/xg/imgs/20151110192434_69196.png)
![](http://developer.qq.com/wiki/xg/imgs/20151118170034_31723.jpg)

然后打开Keychain Access工具

![](http://developer.qq.com/wiki/xg/imgs/20151118170223_56259.jpg)
选择Request a Certificate From a Certificate Authority…
![](http://developer.qq.com/wiki/xg/imgs/20151118170327_87514.jpg)

填写邮件地址，其它留空, 继续。会将证书保存到本地

![](http://developer.qq.com/wiki/xg/imgs/20151110193013_44930.png)

返回网站，选择刚才创建的文件上传

![](http://developer.qq.com/wiki/xg/imgs/20151118170443_25583.jpg)

成功后，下载到本地
![](http://developer.qq.com/wiki/xg/imgs/20151118170536_85822.jpg)

再次打开Keychain Access。选中Push证书导出，选中一行。导出的格式为p12

![](http://developer.qq.com/wiki/xg/imgs/20151118170642_42628.jpg)

### 生成pem格式的证书

完成上述操作后，打开终端，进入到p12文件所在执行以下命令:

```shell
openssl pkcs12 -in CertificateName.p12 -out CertificateName.pem -nodes
```

则生成了CertificateName.pem证书，上传到信鸽则可以进行消息推送。
