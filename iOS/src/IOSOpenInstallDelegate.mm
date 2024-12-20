//
//  IOSOpenInstallDelegate.m
//  hello_world-mobile
//
//  Created by cooper on 2018/6/26.
//

#import "IOSOpenInstallDelegate.h"

@implementation IOSOpenInstallDelegate

static IOSOpenInstallDelegate *obj = nil;
+(IOSOpenInstallDelegate *)defaultManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (obj == nil)
        {
            obj = [[IOSOpenInstallDelegate alloc] init];
        }
    });
    
    return obj;
}

-(void)getWakeUpParams:(OpeninstallData *)appData{
    
    NSString *channelID = @"";
    NSString *datas = @"";
    if (appData.data) {
        datas = [IOSOpenInstallDelegate jsonStringWithObject:appData.data];
    }
    if (appData.channelCode) {
        channelID = appData.channelCode;
    }
    NSDictionary *wakeupDic = @{@"channelCode":channelID,@"bindData":datas};
    NSString *json = [IOSOpenInstallDelegate jsonStringWithObject:wakeupDic];
    
    if (self.isRegister) {
        [IOSOpenInstallDelegate sendWakeUpJsonBack:json];
        self.wakeUpJson = nil;
    }else{
        self.wakeUpJson = json;
    }
}

+(void)sendWakeUpJsonBack:(NSString *)json{

    std::string jsonStr = [json UTF8String];
    std::string funcName = [[NSString stringWithFormat:@"OpenInstall._wakeupCallback"] UTF8String];
    std::string resultStr = [[NSString stringWithFormat:@"%s(%s);",funcName.c_str(),jsonStr.c_str()] UTF8String];
    
    CC_CURRENT_ENGINE()->getScheduler()->performFunctionInCocosThread([=](){
        se::ScriptEngine::getInstance()->evalString(funcName.c_str());
    });
}

+ (NSString *)jsonStringWithObject:(id)jsonObject{
    
    id arguments = (jsonObject == nil ? [NSNull null] : jsonObject);
    
    NSArray* argumentsWrappedInArr = [NSArray arrayWithObject:arguments];
    
    NSString* argumentsJSON = [self cp_JSONString:argumentsWrappedInArr];
    
    argumentsJSON = [argumentsJSON substringWithRange:NSMakeRange(1, [argumentsJSON length] - 2)];
    
    return argumentsJSON;
}
+ (NSString *)cp_JSONString:(NSArray *)array{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array
                                                       options:0
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    if ([jsonString length] > 0 && error == nil){
        return jsonString;
    }else{
        return @"";
    }
}
+(id)jsonStringToObject:(NSString*)jsonString{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        NSLog(@"OpenInstall: 'configIOS' Error parsing JSON: %@", error);
        return nil;
    }else{
        return result;
    }
}

@end
