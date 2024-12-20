//
//  IOSOpenInstallDelegate.h
//  hello_world-mobile
//
//  Created by cooper on 2018/6/26.
//

#import <Foundation/Foundation.h>
#import "OpenInstallSDK.h"
#import "Openinstall.h"
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>//苹果新隐私政策
#import <AdServices/AAAttribution.h>//ASA


#include "application/ApplicationManager.h"
#include "cocos/bindings/jswrapper/SeApi.h"

@interface IOSOpenInstallDelegate : NSObject<OpenInstallDelegate>

@property (nonatomic, copy)NSString *wakeUpJson;
@property (nonatomic, assign)BOOL isRegister;

@property (assign, nonatomic) BOOL adEnable;//必要，是否开启广告平台统计功能
@property (assign, nonatomic) BOOL ASAEnable;//必要，是否开启苹果ASA功能
@property (assign, nonatomic) BOOL ASADebug;//可选，ASA测试debug模式，注意：正式环境中请务必关闭
@property (copy, nonatomic) NSString *idfaStr;//可选，通过其它插件获取的idfa字符串一般格式为xxxx-xxxx-xxxx-xxxx


+(IOSOpenInstallDelegate *)defaultManager;
+(void)sendWakeUpJsonBack:(NSString *)json;
+(NSString *)jsonStringWithObject:(id)jsonObject;
+(id)jsonStringToObject:(NSString*)jsonString;
@end
