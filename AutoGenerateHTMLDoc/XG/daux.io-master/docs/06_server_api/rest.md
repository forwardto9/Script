#Rest API 概述（V2）

信鸽推送提供遵从 REST 规范的 HTTP API，以供开发者远程调用信鸽提供的服务。

<!--V2版本仅支持HTTP协议，不支持HTTPs-->

## 请求方式

支持GET；

支持POST，但要求HTTP HEADER中"Content-type"字段要设置为"application/x-www-form-urlencoded"



## 协议描述

**请求URL**：
`http://openapi.xg.qq.com/v2/class_path/method?params`

| 字段名            | 用途                 | 备注                                                         |
| :---------------- | -------------------- | :----------------------------------------------------------- |
| openapi.xg.qq.com | 接口域名             | 无                                                           |
| v2                | 版本号               | 无                                                           |
| class_path        | 提供的接口类别       | 不同的接口有不同的路径名                                     |
| method            | 功能接口名称         | 不同的功能有不同的名称                                       |
| params            | 调用接口时传递的参数 | 1.包括两部分：通用基础参数、接口特定参数；<br>2.所有的参数都必须为utf8编码；<br>3.params字符串必须进行url encode |

## 通用基础参数

通用基础参数是指，在各个接口请求URL结构中的params字段都需要包含的参数

具体如下表：

| 参数名     | 类型   | 必需 | 参数描述                                                     |
| ---------- | :----- | ---- | ------------------------------------------------------------ |
| access_id  | uint   | 是   | 应用唯一标识，可在xg.qq.com管理台查看                        |
| cal_type   | int    | 否   | 0，表示后台进行离线统计数据<br>1，表示后台进行实时统计数据<br>(默认情况下为0) |
| timestamp  | uint   | 是   | 1.unix时间戳，用于确认请求的有效期<br>2.与服务器时间（北京时间）偏差大于600秒,请求会被拒绝 |
| valid_time | uint   | 否   | 1.配合timestamp确定请求的有效期<br>2.单位为秒<br>3.最大值为600<br>4.若不设置此参数或参数值非法，则按照600s处理 |
| sign       | string | 是   | 接口鉴权，具体生成规则见[鉴权方式](###鉴权方式)              |

## 鉴权方式

计算公式：Sign=MD5(http_methodURIK1=V1…Kn=Vnsecret_key);（注意：参数必须按照此顺序放置）

| 参数名      | 参数描述                                                     |
| :---------- | :----------------------------------------------------------- |
| http_method | 请求方法，GET或是POST                                        |
| URI         | 请求URL信息，包括IP或域名、URI的path部分<br>举例说明：<br>域名：openapi.xg.qq.com/v2/push/single_device<br>IP：10.198.18.239/v2/push/single_device<br>（注意不包括端口和请求串） |
| K1=V1…Kn=Vn | 1.将全部请求参数格式化成K=V<br>2.将格式化后的参数以K的字典序升序排列，拼接在一起<br>（注意：1.不包括sign参数， 2.参数不应进行urlencode） |
| secret_key  | 应用秘钥，可在【信鸽管理台】【应用配置】【应用信息】中查询   |

例如： 

POST请求 `http://openapi.xg.qq.com/v2/push/single_device`

参数列表：

access_id=123，timestamp=1386691200，Param1=Value1，Param2=Value2，secret_key=abcde，

根据上述公式得出：

Sign=MD5(POSTopenapi.xg.qq.com/v2/push/single_deviceaccess_id=123Param1=Value1Param2=Value2timestamp=1386691200abcde)



## 通用基础返回值

通用基础返回值，是所有请求的响应中都会包含的字段，JSON格式
```json
{ 
    "ret_code":0, 
    "erroeMsg":"",
    "result":{"":""} 
}
```

具体描述见下表：

| 参数名   | 类型   | 必需 | 参数描述                                     |
| -------- | :----- | ---- | -------------------------------------------- |
| ret_code | int    | 是   | 返回码                                       |
| err_msg  | string | 否   | 结果描述                                     |
| result   | JSON   | 否   | 请求正确时且有额外数据，则结果封装在该字段中 |

## API限制

1. 除去全量推送接口有调用频率的限制外，其他均无此限制
2. 推送的消息体大小限制为4K，此限制适用于Push API中的message字段



## Push API

### 消息体格式

Push API对iOS和Android两个平台的消息有不同处理，需要分开来实现对应平台的推送消息，推送的消息体是JSON格式，对应PushAPI接口中的message参数。

针对不同平台，消息类型稍有不同，具体参照下表：

| 消息类型 |   支持平台   |     特性说明     |
| :------: | :----------: | :--------------: |
| 普通消息 | Android，iOS |  通知栏展示消息  |
| 透传消息 |   Android    | 通知栏不展示消息 |
| 静默消息 |     iOS      | 通知栏不展示消息 |

#### Android普通消息

Android平台具体字段如下表：

| 字段名         |  类型  | 默认值 | 必需 | 参数描述                                                     |
| :------------- | :----: | :----: | :--: | ------------------------------------------------------------ |
| title          | string |   无   |  是  | 消息标题                                                     |
| content        | string |   无   |  是  | 消息内容                                                     |
| builder_id     |  int   |   无   |  是  | 本地通知样式标识                                             |
| n_id           |  int   |   0    |  否  | 通知消息对象的唯一标识<br><font size=0.5 color=#ff6a6a>1.大于0，会覆盖先前相同id的消息；<br>2.等于0，展示本条通知且不影响其他消息；<br>3.等于-1，将清除先前所有消息，仅展示本条消息</font> |
| ring           |  int   |   1    |  否  | 是否有铃声                                                   |
| ring_raw       | string |   无   |  否  | 指定应用包中自定义的铃声文件                                 |
| vibrate        |  int   |   1    |  否  | 是否使用震动                                                 |
| lights         |  int   |   1    |  否  | 是否使用呼吸灯                                               |
| clearable      |  int   |   1    |  否  | 通知栏是否可清除                                             |
| icon_type      |  int   |   0    |  否  | 通知栏图标是应用内图标还是上传图标<br>0，应用内图标<br>1，上传图标 |
| icon_res       | string |   无   |  否  | 应用内图标文件名或者下载图标的url地址                        |
| style_id       |  int   |   1    |  否  | Web端设置是否覆盖编号的通知样式                              |
| small_icon     | string |   无   |  否  | 消息在状态栏显示的小图片                                     |
| action         |  JSON  |   有   |  否  | 设置点击通知栏之后的行为，默认为打开app                      |
| custom_content |  JSON  |   无   |  否  | 用户自定义的键值对                                           |
| accept_time    | array  |   无   |  否  | 消息将在哪些时间段允许推送给用户                             |

完整的消息示例如下：

```json
{
    "title ":"xxx",
    "content ":"xxxxxxxxx",
    "n_id":0,
    "builder_id":0,
    "ring":1,
    "ring_raw":"ring",
    "vibrate":1,
    "lights":1,
    "clearable":1,
    "icon_type":0,
    "icon_res":"xg",
    "style_id":1,
    "small_icon":"xg",
    "custom_content":{
        "key1":"value1",
        "key2":"value2"
    },
    "action":{
        "action_type ":1,// 动作类型，1打开activity或app本身，2打开浏览器，3打开Intent
        "activity ":"xxx",
        "aty_attr":{ // activity属性，只针对action_type=1的情况
            "if":0,  // Intent的Flag属性
            "pf":0   // PendingIntent的Flag属性
        },
        "browser":{
            "url":"xxxx", // 打开的url
            "confirm":1   // 是否需要用户确认
        },
        "intent":"xxx"
    },
    "accept_time":[
        {
            "start":{
                "hour":"13",
                "min":"00"
            },
            "end":{
                "hour":"14",
                "min":"00"
            }
        },
        {
            "start":{
                "hour":"00",
                "min":"00"
            },
            "end":{
                "hour":"09",
                "min":"00"
            }
        }
    ]
}

```

#### iOS 普通消息

iOS平台具体字段如下表：

| 字段名      |    类型     | 默认值 | 必需 | 参数描述                                                     |
| :---------- | :---------: | :----: | :--: | ------------------------------------------------------------ |
| aps         |    JSON     |   无   |  是  | 苹果推送服务(APNs)特有的消息体字段<br>其中比较重要的键值对:<br>alert：包含标题和消息内容(必选)<br>badge：App显示的角标数(可选),<br>category：下拉消息时显示的操作标识(可选)<br>详细介绍可以参照：[Payload](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html#//apple_ref/doc/uid/TP40008194-CH17-SW1) |
| custom      | string/JSON |   无   |  否  | 自定义下发的参数                                             |
| xg          |   string    |   无   |  否  | 系统保留key，应避免使用                                      |
| accept_time |    array    |   无   |  否  | 消息将在哪些时间段允许推送给用户                             |

完整的消息示例如下：

```json
{
    "aps":{
        "alert":{
            "title":"this is a title",
            "body":"this is content"
        },
        "badge":1,
        "category":"CategoryID"
    },
    "accept_time":[
        {
            "start":{
                "hour":"13",
                "min":"00"
            },
            "end":{
                "hour":"14",
                "min":"00"
            }
        },
        {
            "start":{
                "hour":"00",
                "min":"00"
            },
            "end":{
                "hour":"09",
                "min":"00"
            }
        }
    ],
    "custom":{
        "key":"value"
    },
    "xg":"xxx"
}
```



#### Android透传消息

透传消息，Android平台特有，即不显示在手机通知栏中的消息，可以用来实现让用户无感知的向App下发带有控制性质的消息

Android平台具体字段如下表：

| 字段名      |  类型  | 默认值 | 是否必需 | 参数描述                         |
| ----------- | :----: | :----: | :------: | -------------------------------- |
| title       | string |   无   |    是    | 消息标题                         |
| content     | string |   无   |    是    | 消息内容                         |
| custom      |  JSON  |   无   |    否    | 用户自定义的键值对               |
| accept_time | array  |   无   |    否    | 消息将在哪些时间段允许推送给用户 |

具体完整示例：

```json
{
    "title ":"xxx",
    "content ":"xxxxxxxxx",
    "custom":{
        "key1":"value1",
        "key2":"value2"
    },
    "accept_time":[
        {
            "start":{
                "hour":"13",
                "min":"00"
            },
            "end":{
                "hour":"14",
                "min":"00"
            }
        },
        {
            "start":{
                "hour":"00",
                "min":"00"
            },
            "end":{
                "hour":"09",
                "min":"00"
            }
        }
    ]
}

```

#### iOS静默消息

静默消息，iOS平台特有，类似Android中的透传消息，消息不展示，当静默消息到达终端时，iOS会在后台唤醒App一段时间(小于30s)，让App来处理消息逻辑

具体字段如下表：

| 字段名 | 类型        | 默认值 | 是否必要 | 参数描述                                                     |
| ------ | ----------- | ------ | -------- | ------------------------------------------------------------ |
| aps    | JSON        | 无     | 是       | 苹果推送服务(APNs)特有的，<br>其中最重要的键值对:<br> content-available：标识消息类型(必须为1)<br>且不能包含alert、sound、badge字段<br>详细介绍可以参照：[Payload](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html#//apple_ref/doc/uid/TP40008194-CH17-SW1) |
| custom | string/JSON | 无     | 否       | 自定义下发的参数                                             |
| xg     | string      | 无     | 否       | 系统保留key，应避免使用                                      |

具体完整示例：

```json
{
    "aps":{
        "content-available":1
    },
    "custom":{
        "key1":"value1",
        "key2":"value2"
    },
    "xg":"xxx"
}
```

### Push API基础参数

推送接口的基础参数是指，所有推送消息的接口在的通用参数，切记接口调用参数中必须还要包含 [通用基础参数](###通用基础参数)

具体通用参数见下表：

| 参数名        | 类型   | 必需          | 默认值 | 描述                                                         |
| ------------- | :----- | ------------- | :----- | ------------------------------------------------------------ |
| message       | string | 是            | 无     | 参见[消息格式](#消息格式)                                    |
| message_type  | uint   | 是            | 无     | 0，表示iOS平台消息，不区分普通消息和静默消息<br>1，表示Android普通消息<br> 2，表示Android端透传消息 |
| expire_time   | uint   | 否            | 3天    | 消息离线存储时间（单位为秒），最长存储时间3天。若设置为0，则使用默认值（3天） |
| send_time     | string | 否            | 立即   | 指定推送时间,格式为yyyy-MM-DD HH:MM:SS，若小于服务器当前时间，则会立即推送 |
| multi_pkg     | uint   | 否            | 0      | 0，表示按注册时提供的包名分发消息；<br>1，表示按access id分发消息<br>(本字段对iOS平台无效) |
| environment   | uint   | 是<br>(仅iOS) | ？     | 此字段描述的是App的状态<br>1，表示发布环境，对应App已经发布到AppStore<br>2，表示开发环境，对应App仍处于调试环境<br>(对于iOS，消息推送有两种情况：开发环境、发布环境) |
| loop_times    | uint   | 否            | 1？    | 循环执行任务的次数，取值[1, 15]                              |
| loop_interval | uint   | 否            | ？     | 循环执行任务的间隔，以天为单位，取值[1, 14]。loop_times和loop_interval一起表示任务的生命周期，不可超过14天 |

### 全量推送

此接口是对全部的设备进行推送，后台对本接口的调用频率有限制，两次调用之间的时间间隔<font color=#E53333>不能小于3秒</font>。

**请求URL**:

`http://openapi.xg.qq.com/v2/push/all_device?params`

**请求参数**：

[Push API 基础参数](###Push API基础参数)

**响应结果**：

[通用基础返回值](##通用基础返回值)，result字段会包含给app下发的任务id，如果是循环任务，返回的是循环父任务id

具体示例如下：

```json
{
    "push_id":10000
}
```



### 群推送

群推送是指，开发者通过SDK接口或者是后台接口为特定的某些用户设置了属性，然后根据对应的属性进行群组推送，目前Push API支持三种群推：标签、账号、设备(Token)



#### 标签群推

可以针对设置过标签的设备进行推送。如：性别、身份，等任意类型

**请求URL**:

`http://openapi.xg.qq.com/v2/push/tags_device?params`

**请求参数**：

除了[Push API 基础参数](###Push API基础参数)，还包括如下特定参数：

| 参数名    | 类型   | 必需 | 默认值 | 描述                   |
| --------- | :----- | ---- | :----- | ---------------------- |
| tags_list | JSON   | 是   | 无     | [“tag1”,”tag2”,”tag3”] |
| tags_op   | string | 是   | 无     | 取值为AND或OR          |

**响应结果**：

[通用基础返回值](通用基础返回值)，result字段会包含给app下发的任务id，如果是循环任务，返回的是循环父任务id

具体示例如下：

```json
{
    "push_id":10000
}
```



#### 帐号群推

账号群推是指，对通过客户端SDK绑定接口绑定的账号的群组推送，iOS和Android的SDK都提供相应的接口。

**请求URL**：

`http://openapi.xg.qq.com/v2/push/account_list?params `

**请求参数**：

除了[通用基础参数](##通用基础参数) 和 [Push API基础参数](###Push API基础参数)，还包括如下特定参数：

| 参数名       | 类型  | 必需 | 默认值 | 描述                                                         |
| ------------ | :---- | ---- | :----- | ------------------------------------------------------------ |
| account_list | array | 是   | 无     | JSON数组格式<br>每个元素是一个account<br>单次发送account不超过100个<br>例：[“account1”,”account2”,”account3”] |

**响应结果**：

[通用基础返回值](通用基础返回值)，result字段的JSON为每个account发送返回码



### 超大批量账号群推

如果推送目标帐号数量很大（比如≥10000），推荐使用此方法，分为以下两步：

(1)首先，创建推送消息：

**请求URL**:

`http://openapi.xg.qq.com/v2/push/create_multipush?params`

**请求参数**：

[通用基础参数](##通用基础参数) 和 [Push API基础参数](###Push API基础参数)



(2)其次，使用超大批量推送接口进行消息推送

**请求URL**:

`http://openapi.xg.qq.com/v2/push/account_list_multiple?params`

**请求参数**：

除[通用基础参数](##通用基础参数)外，还包括如下参数：

| 参数名       | 类型  | 必需 | 默认值 | 描述                                                         |
| ------------ | :---- | ---- | :----- | ------------------------------------------------------------ |
| account_list | array | 是   | 无     | JSON数组格式<br>每个元素是一个account<br><font color=#E53333>单次发送account不超过1000个</font> |
| push_id      | uint  | 是   | 无     | 创建推送消息接口的返回的消息标识                             |

**响应结果**：

[通用基础返回值](通用基础返回值)



#### 设备群推

设备群推是指，使用设备标识(Device Token)进行消息的推送，关于设备标识的获取可以参照设备查询接口？,使用此接口需要2步：

1. 首先，创建推送消息，得到消息标识(push id)；

2. 然后，根据第一步得到的消息标识，调用推送接口

   

第一步，创建消息

**请求URL**:

`http://openapi.xg.qq.com/v2/push/create_multipush?params`

**请求参数**：

[通用基础参数](##通用基础参数) 和 [Push API基础参数](###Push API基础参数)

**响应结果**：

[通用基础返回值](通用基础返回值)，其中result字段的JSON包含消息标识，举例如下：

```json
{
"push_id":100000
}
```

第二步，调用推送接口

**请求URL**:

`http://openapi.xg.qq.com/v2/push/device_list_multiple?params`

**请求参数**：

除了[通用基础参数](##通用基础参数) ，还包括如下特定参数：

| 参数名      | 类型  | 必需 | 默认值 | 描述                                                         |
| ----------- | :---- | ---- | :----- | ------------------------------------------------------------ |
| device_list | array | 是   | 无     | JSON数组格式<br>每个元素是一个token<br>单次发送token不超过1000个<br>例：[“token1”,”token2”,”token3”] |
| push_id     | uint  | 是   | 无     | 创建推送消息接口的返回的消息标识                             |

**响应结果**：

[通用基础返回值](通用基础返回值)



### 单推

单推是指，开发者通过SDK接口或者是后台接口为特定的某一个用户设置了属性，然后根据对应的属性进行指定推送，目前Push API支持三种单推：标签、账号、设备(Token)



#### 标签单推

参照[标签群推](####标签群推)，将标签数组参数设置为包含一个指定的标签元素即可



#### 账号单推

账号单推是指，对通过客户端SDK绑定接口绑定的指定单个账号的推送，iOS和Android的SDK都提供相应的接口。

**请求URL**:

`http://openapi.xg.qq.com/v2/push/single_account?params`

**请求参数**：

除了[通用基础参数](##通用基础参数) 和 [Push API基础参数](###Push API基础参数)，还包括如下特定参数：

| 参数名  | 类型   | 必需 | 默认值 | 描述 |
| ------- | :----- | ---- | :----- | ---- |
| account | string | 是   | 无     | 无   |

**响应结果**：

[通用基础返回值](通用基础返回值)



#### 设备单推

设备单推是指，使用指定的一个设备标识(Device Token)进行消息的推送，关于设备标识的获取，客户端SDK有相应的接口

**请求URL**：

`http://openapi.xg.qq.com/v2/push/single_device?params`

**请求参数**：

除了[通用基础参数](##通用基础参数) 和 [Push API基础参数](###Push API基础参数)，还包括如下特定参数：

|参数名 |类型 |必需 |默认值 |描述 |
| ------------- |:-------------|: -----------|:-------------|: -----------|
|device_token |string |是 |无 |设备标识 |

**响应结果**：

[通用基础返回值](通用基础返回值)



### 查询消息状态

此接口目前支持群推消息的发送状态的查询，不支持单推消息的状态查询

**请求URL**：

`http://openapi.xg.qq.com/v2/push/get_msg_status?params`

除了[通用基础参数](##通用基础参数) ，还包括如下特定参数：

| 参数名  | 类型  | 必需 | 默认值 | 描述                                                         |
| ------- | :---- | ---- | :----- | ------------------------------------------------------------ |
| push_id | array | 是   | 无     | 消息唯一标识，可在管理台查看<br>JSON格式<br>举例：<br> [{"push_id": "10000"}] |

**响应结果**：

[通用基础返回值](通用基础返回值)，其中result字段的JSON形式为：

```json
{
    "list":[
        {
            "push_id":"10000",
            "status":0,//0（未处理）,1（推送中）,2（推送完成）,3（推送失败）
            "start_time":"1990-01-01 00:00:00",
            "finished":"",
            "total":10
        }
    ]
}
```



### 取消推送

目前V2版本支持根据消息ID来取消尚未触发的、定时的、群推消息

**请求URL**：

`http://openapi.xg.qq.com/v2/push/cancel_timing_task?params`

**请求参数**：

除了[通用基础参数](##通用基础参数) ，还包括如下特定参数：

| 参数名  | 类型   | 必需 | 默认值 | 描述                                           |
| ------- | :----- | ---- | :----- | ---------------------------------------------- |
| push_id | string | 是   | 无     | 已创建的群推消息的唯一标识，信鸽管理台可以查看 |

**响应结果**：

[通用基础返回值](通用基础返回值)，其中result字段的JSON形式为：

```json
{
"status": 0 //0为成功，其余为失败
}
```



##标签(Tag)接口

标签接口主要是用来对标签进行查询、设置、删除操作

V2版本支持的具体接口如下：

1. 批量设置标签
2. 批量删除标签
3. 查询全部标签
4. 查询单个设备(根据Device Token)的标签
5. 查询单个标签的设备(Device Token)总数



#### 批量设置标签

**请求URL**:

`http://openapi.xg.qq.com/v2/tags/batch_set`

**请求参数**：

除了[通用基础参数](##通用基础参数)，还包括如下特定参数：

|参数名 |类型 |必需 |默认值 |描述 |
| ------------- |:-------------|: -----------|:-------------|: -----------|
|tag_token_list |array |是 |无 |JSON字符串<br>每一个数组元素是一个tag-token对的数组<br>每次调用最多允许设置20对<br>每个对里面tag在前，token在后<br></font>示例： [[”tag1”,”token1”],[”tag2”,”token2”]]<br>(注意:<br>1，标签最长50字节，不可包含空格<br>2，要求token必须是设备的有效标识) |

**响应结果**：

[通用基础返回值](通用基础返回值)



#### 批量删除标签

**请求URL**:

`http://openapi.xg.qq.com/v2/tags/batch_del`

**请求参数**：

与[批量设置标签](###批量设置标签)中**请求参数**一致

**响应结果**：

[通用基础返回值](通用基础返回值)



#### 查询全部标签

此接口用来查询当前指定应用下被设置的全部标签数量和对应的标签字符串数组

**请求URL**:

`http://openapi.xg.qq.com/v2/tags/query_app_tags?params`

**请求参数**：

除了[通用基础参数](##通用基础参数)，还可以包括如下特定参数：

| 参数名 | 类型 | 必需 | 默认值 | 描述     |
| ------ | :--- | ---- | :----- | -------- |
| start  | uint | 否   | 0      | 开始值   |
| limit  | uint | 否   | 100    | 限制数量 |

**响应结果**：

[通用基础返回值](通用基础返回值)中，result字段的JSON格式如下：

```json
{
"total": 2, //指定应用的总tag数
"tags":["tag1","tag2"] //依据limit参数查询出的标签数组
}
```



#### 查询单个指定设备的标签

此接口根据设备标识(Device Token)来查询相应设备被设置的全部标签，请务必保证设备标识的合法性

**请求URL**:

`http://openapi.xg.qq.com/v2/tags/query_token_tags?params`

**请求参数**：

除了[通用基础参数](##通用基础参数)，还包括如下特定参数：

| 参数名       | 类型   | 必需 | 默认值 | 描述     |
| ------------ | :----- | ---- | :----- | -------- |
| device_token | string | 是   | 无     | 设备标识 |

**响应结果**：

在[通用基础返回值](通用基础返回值)参数中，result字段的JSON格式如下：

```json
{
"tags":["tag1","tag2"]
}
```



#### 查询单个标签的设备总数

**请求URL**:

`http://openapi.xg.qq.com/v2/tags/query_tag_token_num?params`

**请求参数**：

除了[通用基础参数](##通用基础参数)，还包括如下特定参数：

| 参数名 | 类型   | 必需 | 默认值 | 描述                 |
| ------ | :----- | ---- | :----- | -------------------- |
| tag    | string | 是   | 无     | 需要查询的标签字符串 |

**响应结果**：

[通用基础返回值](通用基础返回值)中，result字段的JSON格式如下：

```json
{
"device_num":100000
}
```



##账号(Account)接口

账号接口主要是用来查询、删除终端设备关联的账号

V2版本支持的具体接口如下：

1. 查询单个账号关联的设备(Device Token)
2. 删除单个账号关联的设备(Device Token)
3. 删除账号关联的全部设备(Device Token)



#### 查询单个账号关联的设备

**请求URL**:

`http://openapi.xg.qq.com/v2/application/get_app_account_tokens?params`

**请求参数**：

除了[通用基础参数](##通用基础参数)，还包括如下特定参数：

| 参数名  | 类型   | 必需 | 默认值 | 描述     |
| ------- | :----- | ---- | :----- | -------- |
| account | string | 是   | 无     | 帐号标识 |

**响应结果**：

[通用基础返回值](通用基础返回值)中，result字段的JSON格式如下：

```json
{
"tokens":["token1","token2"]
}
```



#### 删除单个账号关联的设备

**请求URL**:

`http://openapi.xg.qq.com/v2/application/del_app_account_tokens?params`

**请求参数**：

除了[通用基础参数](##通用基础参数)，还包括如下特定参数：

|参数名 |类型 |必需 |默认值 |描述 |
| ------------- |:-------------|: -----------|:-------------|: -----------|
|account |string |是 |无 |与设备标识关联的账号 |
|device_token |string |是 |无 |设备接收消息的标识 |

**响应结果**：

[通用基础返回值](通用基础返回值)中，result字段的JSON格式如下：

```json
{
"tokens":["token1"]
}
```

注意：tokens字段对应的值表示当前账号目前仍关联的设备标识



#### 删除账号关联的全部设备

**请求URL**:

`http://openapi.xg.qq.com/v2/application/del_app_account_all_tokens?params`

除了[通用基础参数](##通用基础参数)，还包括如下特定参数：

|参数名 |类型 |必需 |默认值 |描述 |
| ------------- |:-------------|: -----------|:-------------|: -----------|
|account |string |是 |无 |账号标识 |

**响应结果**：

[通用基础返回值](通用基础返回值)



## 工具类接口

### 查询应用覆盖的设备总数

此接口用来查询指定应用的全部已注册的设备标识(Device Token)的总数，包括历史设备

**请求URL**:

`http://openapi.xg.qq.com/v2/application/get_app_device_num?params`

**请求参数**：

[通用基础参数](##通用基础参数)

**响应结果**：

[通用基础返回值](通用基础返回值)，其中result字段的JSON形式为：

```json
{
"device_num": 34567
}
```
### 查询指定设备的注册状态

此接口是为了查询指定设备(Device Token)在信鸽服务器上注册的状态，设备能收到信鸽推送的消息的首要条件是设备(Device Token)已经被注册到信鸽的后台，否则信鸽无法给指定设备下发消息的

**请求URL**:

`http://openapi.xg.qq.com/v2/application/get_app_token_info?params`

**请求参数**：

除了[通用基础参数](##通用基础参数)，还包括如下特定参数：

|参数名 |类型 |必需 |默认值 |描述 |
| ------------- |:-------------|: -----------|:-------------|: -----------|
|device_token |string |是 | 无 |设备接收消息的标识 |

**响应结果**：

[通用基础返回值](通用基础返回值)，其中result字段的JSON形式为：

```json
{
"isReg":1,//（1为token已注册，0为未注册）
"connTimestamp":1426493097, //（最新活跃时间戳）
"msgsNum":2 //（该应用的离线消息数）
}
```



## 返回码一览

信鸽REST API接口较多，开发者使用过程中不可避难会遇到各种问题，这里提供了常见的错误码释义，对应着是[通用基础返回值](通用基础返回值)中的ret_code字段的可能值

详细参见下表：

| Code | 描述                                               | 可采取措施                                                   |
| :--- | :------------------------------------------------- | :----------------------------------------------------------- |
| 0    | 调用成功                                           |                                                              |
| -1   | 参数错误                                           | 检查参数配置                                                 |
| -2   | 请求时间戳不在有效期内                             | 检查设备当前时间                                             |
| -3   | sign校验无效                                       | 检查Access ID和Secret Key（注意不是Access Key）              |
| 2    | 参数错误                                           | 检查参数配置                                                 |
| 14   | 收到非法token                                      | Android Token长度为40位iOS Token长度为64位                   |
| 15   | 信鸽逻辑服务器繁忙                                 | 稍后重试                                                     |
| 19   | 操作时序错误。例如进行tag操作前未获取到deviceToken | 没有获取到deviceToken的原因：1.没有注册信鸽或者苹果推送2.provisioning profile制作不正确 |
| 20   | 鉴权错误，可能是由于Access ID和Access Key不匹配    | 检查Access ID和Access Key                                    |
| 40   | 推送的token没有在信鸽中注册                        | 检查token是否注册                                            |
| 48   | 推送的账号没有绑定token                            | 检查account和token是否有绑定关系见推送指南：绑定/设置账号见热门问题解答：账号和设备未绑定的解答 |
| 63   | 标签系统忙                                         | 检查标签是否设置成功见推送指南：设置标签                     |
| 71   | APNS服务器繁忙                                     | 苹果服务器繁忙，稍后重试                                     |
| 73   | 消息字符数超限                                     | iOS目前是1000字节左右，苹果的额外推送设置如角标，也会占用字节数 |
| 76   | 请求过于频繁，请稍后再试                           | 全量广播限频为每3秒一次                                      |
| 78   | 循环任务参数错误                                   |                                                              |
| 100  | APNs证书错误                                       | 证书格式是pem的，另外，注意区分生产证书、开发证书的区别      |
| 其他 | 其他错误                                           |                                                              |

