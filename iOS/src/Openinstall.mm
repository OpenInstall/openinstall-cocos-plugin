//
//  Openinstall.m
//  hello_world-mobile
//
//  Created by cooper on 2018/6/26.
//

#import "Openinstall.h"
#import "IOSOpenInstallDelegate.h"


@implementation Openinstall

+(void)config:(NSString*)configJson
{
    if (configJson && configJson.length != 0)
    {
        
        id result = [IOSOpenInstallDelegate jsonStringToObject:configJson];
        if (result) {
            NSDictionary *args = (NSDictionary*)result;
            IOSOpenInstallDelegate *delegate = [IOSOpenInstallDelegate defaultManager];
            
            delegate.adEnable = [args[@"adEnable"] boolValue];
            delegate.ASAEnable = [args[@"ASAEnable"] boolValue];
            delegate.idfaStr = args[@"idfaStr"];
            delegate.ASADebug = [args[@"ASADebug"] boolValue];
        }
    }
}

+ (void)initOpenInstall{
    //iOS14.5苹果隐私政策正式启用
    
    IOSOpenInstallDelegate *delegate = [IOSOpenInstallDelegate defaultManager];
    if (delegate.adEnable) {
        if (@available(iOS 14, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                [self OpInit];
            }];
        }else{
            [self OpInit];
        }
    }else{
        [self OpInit];
    }
    
}

+ (void)OpInit{
    //ASA广告归因
    NSMutableDictionary *config = [[NSMutableDictionary alloc]init];
    IOSOpenInstallDelegate *delegate = [IOSOpenInstallDelegate defaultManager];
    if (@available(iOS 14.3, *)) {
        NSError *error;
        NSString *token = [AAAttribution attributionTokenWithError:&error];
        if (delegate.ASAEnable) {
            [config setValue:token forKey:OP_ASA_Token];
        }
        if (delegate.ASADebug) {
            [config setValue:@(YES) forKey:OP_ASA_isDev];
        }
    }
    //第三方广告平台统计代码
    NSString *idfaStr;
    if (delegate.adEnable) {
        if (delegate.idfaStr.length > 0) {
            idfaStr = delegate.idfaStr;
        }else{
            idfaStr = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
        [config setValue:idfaStr forKey:OP_Idfa_Id];
    }
    
    if (!delegate.ASAEnable && !delegate.adEnable) {
        [OpenInstallSDK initWithDelegate:[IOSOpenInstallDelegate defaultManager]];
    }else if (!delegate.ASAEnable && delegate.adEnable){
        [OpenInstallSDK initWithDelegate:[IOSOpenInstallDelegate defaultManager] advertisingId:idfaStr];
    }else if (delegate.ASAEnable && !delegate.adEnable){
        [OpenInstallSDK initWithDelegate:[IOSOpenInstallDelegate defaultManager] adsAttribution:config];
    }else if (delegate.ASAEnable && delegate.adEnable){
        [OpenInstallSDK initWithDelegate:[IOSOpenInstallDelegate defaultManager] adsAttribution:config];
    }
    
}

+(void)init{
    
    [self initOpenInstall];
}

+(BOOL)setUserActivity:(NSUserActivity*_Nullable)userActivity{
    
    if ([OpenInstallSDK continueUserActivity:userActivity]) {
        
        return YES;
    }
    
    return NO;
}

+(BOOL)setLinkURL:(NSURL *_Nullable)URL{
    
    if ([OpenInstallSDK handLinkURL:URL]) {
        
        return YES;
    }
    
    return NO;
}

@end
