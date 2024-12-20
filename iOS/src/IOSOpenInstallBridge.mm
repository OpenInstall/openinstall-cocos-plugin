//
//  IOSOpenInstallBridge.m
//  start_project-mobile
//
//  Created by cooper on 2018/6/22.
//

#import "IOSOpenInstallBridge.h"
#import "IOSOpenInstallDelegate.h"

//using namespace cocos2d;
@implementation IOSOpenInstallBridge

+(void)getInstall{
    
    [[OpenInstallSDK defaultManager] getInstallParmsWithTimeoutInterval:15 completed:^(OpeninstallData * _Nullable appData) {
        NSString *channelID = @"";
        NSString *datas = @"";
        if (appData.data) {
            datas = [IOSOpenInstallDelegate jsonStringWithObject:appData.data];
        }
        if (appData.channelCode) {
            channelID = appData.channelCode;
        }
        NSDictionary *installDic = @{@"channelCode":channelID,@"bindData":datas};
        NSString *json = [IOSOpenInstallDelegate jsonStringWithObject:installDic];

        std::string jsonStr = [json UTF8String];
        std::string funcName = [[NSString stringWithFormat:@"OpenInstall._installCallback"] UTF8String];
        std::string resultStr = [[NSString stringWithFormat:@"%s(%s);",funcName.c_str(),jsonStr.c_str()] UTF8String];

        CC_CURRENT_ENGINE()->getScheduler()->performFunctionInCocosThread([=](){
            se::ScriptEngine::getInstance()->evalString(resultStr.c_str());
        });
        
    }];
}
/*
+(void)getInstall:(NSNumber *)s
{
    int t = 15;
    if ([s intValue]>0) {
        t = [s intValue];
    }
    [[OpenInstallSDK defaultManager] getInstallParmsWithTimeoutInterval:t completed:^(OpeninstallData * _Nullable appData) {
        NSString *channelID = @"";
        NSString *datas = @"";
        if (appData.data) {
            datas = [IOSOpenInstallDelegate jsonStringWithObject:appData.data];
        }
        if (appData.channelCode) {
            channelID = appData.channelCode;
        }
        NSDictionary *installDic = @{@"channelCode":channelID,@"bindData":datas};
        NSString *json = [IOSOpenInstallDelegate jsonStringWithObject:installDic];

        std::string jsonStr = [json UTF8String];
        std::string funcName = [[NSString stringWithFormat:@"var openinstall = window.require(\"OpenInstallPlugin\");openinstall._installCallback"] UTF8String];
        std::string resultStr = [[NSString stringWithFormat:@"%s(%s)",funcName.c_str(),jsonStr.c_str()] UTF8String];

        CC_CURRENT_ENGINE()->getScheduler()->performFunctionInCocosThread([=](){
            se::ScriptEngine::getInstance()->evalString(resultStr.c_str());
        });
        
    }];
    
}
*/
+(void)registerWakeup{
    
    IOSOpenInstallDelegate *callBack = [IOSOpenInstallDelegate defaultManager];
    callBack.isRegister = YES;
    if (callBack.wakeUpJson.length != 0) {
        [IOSOpenInstallDelegate sendWakeUpJsonBack:callBack.wakeUpJson];
        callBack.wakeUpJson = nil;
    }
    
}

+(void)reportRegister{
    
    [OpenInstallSDK reportRegister];
}

+(void)reportEffectPoint:(NSString *)pointId Value:(NSNumber *)pointValue{
    
    [[OpenInstallSDK defaultManager] reportEffectPoint:pointId effectValue:[pointValue longValue]];
}

+(void)reportEffectPoint:(NSString *)pointId Value:(NSNumber *)pointValue effectDictionary:(NSString *)effectDictionary{
    
    id result = [IOSOpenInstallDelegate jsonStringToObject:effectDictionary];
    if (result) {
        NSDictionary *args = (NSDictionary*)result;
        [[OpenInstallSDK defaultManager] reportEffectPoint:pointId effectValue:[pointValue longValue] effectDictionary:args];
    }else{
        [[OpenInstallSDK defaultManager] reportEffectPoint:pointId effectValue:[pointValue longValue]];
    }
}


+(void)reportShare:(NSString*)shareCode sharePlatform:(NSString*)sharePlatform{
    
    [[OpenInstallSDK defaultManager] reportShareParametersWithShareCode:shareCode sharePlatform:sharePlatform completed:^(NSInteger code, NSString * _Nullable msg) {
        BOOL shouldRetry = NO;
        if (code==-1) {
            shouldRetry = YES;
        }
        NSDictionary * resultDic = @{@"shouldRetry":@(shouldRetry),@"message":msg};
        NSString *json = [IOSOpenInstallDelegate jsonStringWithObject:resultDic];
        std::string jsonStr = [json UTF8String];
        std::string funcName = [[NSString stringWithFormat:@"OpenInstall._shareCallback"] UTF8String];
        std::string resultStr = [[NSString stringWithFormat:@"%s(%s);",funcName.c_str(),jsonStr.c_str()] UTF8String];

        CC_CURRENT_ENGINE()->getScheduler()->performFunctionInCocosThread([=](){
            se::ScriptEngine::getInstance()->evalString(resultStr.c_str());
        });
    }];
}


@end
