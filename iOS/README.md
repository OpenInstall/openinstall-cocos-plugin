# iOS 集成指南

## 导出工程
- 在菜单 `项目` -> `构建发布` 弹框中，发布平台选择 `iOS`，填写其他配置，最后点击 `构建`
- 构建完成后，使用 `Xcode` 打开位于 `${projectDir}/build/ios/proj` 的 iOS 工程。

## 拷贝文件
- 将 `iOS` 目录下的 `src` 文件夹下的内容拷贝到项目的 `app/src` 目录下
- 将 `iOS` 目录下的 `libs` 文件下的.a静态库文件拷贝到项目的 `app/libs` 目录下

## 初始化AppKey配置

在项目的 `Info.plist` 文件中配置appKey键值对，如下：

``` xml
  	<key>com.openinstall.APP_KEY</key>
	<string>从openinstall官网后台获取应用的appKey</string>
```


## 以下为 `一键拉起` 功能的相关配置和代码

## universal links配置（iOS9以后推荐使用）

对于iOS，为确保能正常跳转，AppID必须开启Associated Domains功能，请到[苹果开发者网站](https://developer.apple.com)，选择Certificate, Identifiers & Profiles，选择相应的AppID，开启Associated Domains。注意：当AppID重新编辑过之后，需要更新相应的mobileprovision证书。

![开启Associated Domains](https://res.cdn.openinstall.io/doc/ios-ulink-1.png)

如果已经开启过Associated Domains功能，进行下面操作：  

- 在左侧导航器中点击您的项目
- 选择 `Capabilities` 标签
- 打开 `Associated Domains` 开关
- 添加 openinstall 官网后台中应用对应的关联域名（openinstall应用控制台->iOS集成->iOS应用配置->关联域名(Associated Domains)）

![添加associatedDomains](https://res.cdn.openinstall.io/doc/ios-associated-domains.png)

### universal links相关代码：

在 `AppController.mm` 中，增加头文件的引用:

``` objc
#import "app/src/Openinstall.h"
```

在 `AppController.mm` 中添加通用链接(Universal Link)回调方法：

``` objc
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler{
    //判断是否通过OpenInstall Universal Link 唤起App
    [Openinstall setUserActivity:userActivity];

    //其他第三方回调:
    return YES;
}
```

## scheme配置

（scheme的值详细获取位置：openinstall应用控制台->iOS集成->iOS应用配置）

添加应用对应的 scheme，可在工程“TARGETS -> Info -> URL Types” 里快速添加，图文请看

![scheme配置](https://res.cdn.openinstall.io/doc/ios-scheme.png)

### scheme相关代码：

在 `AppController.mm` 中添加 `scheme` 回调的方法

``` objc
//支持目前所有版本的iOS
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    //判断是否通过OpenInstall URL Scheme 唤起App
    [Openinstall setLinkURL:url];

    //其他第三方回调:
    return YES;
    
}

//注意：在iOS9.0以上的设备中，下面这个系统方法会覆盖上面的系统方法（主要考虑到微信登录等业务），请结合自身业务来调用
//一般情况下，只要本地有下面的方法存在，则在下面方法中必须调用openinstall的相关api，没有下面方法的情况下可以只在上面的方法中调用openinstall的相关api

//支持iOS9以上
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary *)options{
    //判断是否通过OpenInstall URL Scheme 唤起App
    [Openinstall setLinkURL:url];
    
    //其他第三方回调:
    return YES;
}
```

## 广告接入补充文档

### 广告平台渠道和ASA渠道配置

广告idfa权限配置：

1）、需要在Info.plist文件中配置权限  
``` xml
<key>NSUserTrackingUsageDescription</key>
<string>为了您可以精准获取到优质推荐内容，需要您允许使用该权限</string>
```

2）、添加获取idfa和ASA的的代码
``` xml
    let configIosOptions = {
            adEnable: true,//必要，是否开启广告平台统计功能
            ASAEnable: true,//必要，是否开启苹果ASA功能
            idfaStr: "DSSFE2EE-FW3EFWW-WEF1WEFW-SDDFF4F",//可选，传入获取的idfa字符串一般格式为xxxx-xxxx-xxxx-xxxx
            ASADebug : true//可选，ASA测试debug模式，注意：正式环境中请务必关闭
        }
    OpenInstallPlugin.configIOS(configIosOptions);
```
