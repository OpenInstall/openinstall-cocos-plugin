# openinstall-cocos-plugin
Cocos Creator 3.x 集成 openinstall SDK  

## Android 集成

请参考 [Android 集成指南](Android/README.md)

## iOS 集成
正在开发中...

## 使用指南  

将 `Script` 文件夹中的 `OpenInstall.ts` 文件拷贝到项目的脚本文件夹 `Script` 中。  
在组件中使用时，需要先引入openinstall脚本
``` js
import { OpenInstallPlugin } from './OpenInstall';
```

### 1 初始化
App 启动时，请确保用户同意《隐私政策》之后，再调用初始化；如果用户不同意，则不进行openinstall SDK初始化。参考 [应用合规指南](https://www.openinstall.io/doc/rules.html)   

``` js
OpenInstallPlugin.init();
```
### 2 快速安装和一键拉起  

在应用启动时，注册拉起回调。当 App 被唤醒时，可以及时在回调中获取跳转携带的数据    
可在组件脚本的`OnLoad`方法中调用，请在初始化后调用。
``` js
    // 拉起回调方法
    _wakeupCallback(appData){
        console.info("拉起参数：channelCode=" + appData.channelCode 
            + ", bindData=" + appData.bindData);
    }
    // 可在 onLoad 中调用
    OpenInstallPlugin.registerWakeUpHandler(this._wakeupCallback);
```

### 3 携带参数安装（高级版功能）

在应用需要安装参数时，调用以下 api 获取由 SDK 保存的安装参数，可设置超时时长(一般为8～15秒)，单位秒
``` js
    //安装回调方法
    _installCallback(appData){
        console.info("安装参数：channelCode=" + appData.channelCode 
            + ", bindData=" + appData.bindData);
    }
    //在 App 业务需要时调用
    OpenInstallPlugin.getInstall(this._installCallback);
```
> **注意：**    
> 1. 安装参数尽量不要自己保存，在每次需要用到的时候调用该方法去获取，因为如果获取成功sdk会保存在本地  
> 2. 该方法可重复获取参数，如需只要在首次安装时获取，可设置标记，详细说明可参考openinstall官网的常见问题

### 4 渠道统计（高级版功能）
SDK 会自动完成访问量、点击量、安装量、活跃量、留存率等统计工作。其它业务相关统计由开发人员使用 api 上报

#### 4.1 注册上报
根据自身的业务规则，在确保用户完成 app 注册的情况下调用 api
``` js
OpenInstallPlugin.reportRegister();
```

#### 4.2 效果点上报
统计终端用户对某些特殊业务的使用效果，如充值金额，分享次数等等。  
请在 [openinstall 控制台](https://developer.openinstall.io/) 的 “效果点管理” 中添加对应的效果点  
![创建效果点](https://res.cdn.openinstall.io/doc/effect_point.png)  
调用接口进行效果点的上报，第一个参数对应控制台中的 **效果点ID**  
```js
OpenInstallPlugin.reportEffectPoint("effect_test", 1);
```

#### 4.3 效果点明细上报
在 openinstall 控制台 的 “效果点管理” 中添加对应的效果点，并启用“记录明细”，添加自定义参数
``` js
    var extra = {
        x : "123",
        y : "abc"
    }
    OpenInstallPlugin.reportEffectPoint("effect_detail", 1, extra);
```

### 5 分享统计
分享上报主要是统计某个具体用户在某次分享中，分享给了哪个平台，再通过JS端绑定被分享的用户信息，进一步统计到被分享用户的激活回流等情况。
``` lua
    _shareCallback(result){
        console.info("reportShare：shouldRetry=" + result.shouldRetry);
    }
    OpenInstallPlugin.reportShare("cc0011", "QQ", _shareCallback)
```
第一个参数是分享ID，第二个参数是分享平台。分享平台请参考 openinstall 官网文档


## 导出apk/ipa包并上传
代码集成完毕后，需要导出安装包上传openinstall后台，openinstall会自动完成所有的应用配置工作。  
![上传安装包](https://res.cdn.openinstall.io/doc/upload-ipa-jump.png)

上传完成后即可开始在线模拟测试，体验完整的App安装/拉起流程；待测试无误后，再完善下载配置信息。  
![在线测试](https://res.cdn.openinstall.io/doc/js-test.png)

## 如有疑问

若您在集成或使用中有任何疑问或者困难，请 [联系openinstall客服](https://www.openinstall.io/)。 

