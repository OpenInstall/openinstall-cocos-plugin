//
//  IOSOpenInstallBridge.h
//  start_project-mobile
//
//  Created by cooper on 2018/6/22.
//

#import <Foundation/Foundation.h>

@interface IOSOpenInstallBridge : NSObject

+(void)getInstall;

//+(void)getInstall:(NSString *)s;

+(void)registerWakeup;

+(void)reportRegister;

+(void)reportEffectPoint:(NSString *)pointId Value:(NSNumber *)pointValue;

+(void)reportEffectPoint:(NSString *)pointId Value:(NSNumber *)pointValue effectDictionary:(NSString *)effectDictionary;

+(void)reportShare:(NSString*)shareCode sharePlatform:(NSString*)sharePlatform;
@end
