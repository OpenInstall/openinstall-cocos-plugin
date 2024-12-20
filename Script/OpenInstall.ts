
import { native, sys } from 'cc';

const java_class_name = "io/openinstall/cocos/OpenInstallPlugin";
const iOS_class_bridge = "IOSOpenInstallBridge";
const iOS_class_init = "Openinstall";

export class OpenInstallPlugin {

    private static installCallback;
    private static wakeupCallback;
    private static shareCallback;

    public static preInit() {
        if (sys.OS.ANDROID == sys.os) {
            native.reflection.callStaticMethod(java_class_name, "preInit", "()V");
        } else {
            console.info("此方法仅适用于Android平台");
        }
    }

    public static configAndroid(options: Object) {
        if (sys.OS.ANDROID == sys.os) {
            var jsonStr = JSON.stringify(options);
            native.reflection.callStaticMethod(java_class_name, "config", "(Ljava/lang/String;)V", jsonStr);
        } else {
            console.info("此方法仅适用于Android平台");
        }
    }

    public static configIOS(options: Object) {
        if (sys.OS.IOS == sys.os) {
            var jsonStr = JSON.stringify(options);
            native.reflection.callStaticMethod(iOS_class_init, "config:", jsonStr);
        } else {
            console.info("此方法仅适用于iOS平台");
        }
    }

    public static init() {
        if (sys.OS.ANDROID == sys.os) {
            native.reflection.callStaticMethod(java_class_name, "init", "()V");
        } else {
            native.reflection.callStaticMethod(iOS_class_init,"init");
        }
    }

    public static getInstall(s: number, callback: Function) {
        this.installCallback = callback;
        if (sys.OS.ANDROID == sys.os) {
            native.reflection.callStaticMethod(java_class_name, "getInstall", "(I)V", s);
        } else {
            native.reflection.callStaticMethod(iOS_class_bridge, "getInstall");
        }
    }

    public static getInstallCanRetry(s: number, callback: Function) {
        this.installCallback = callback;
        if (sys.OS.ANDROID == sys.os) {
            native.reflection.callStaticMethod(java_class_name, "getInstallCanRetry", "(I)V", s);
        } else {
            console.info("此方法仅适用于Android平台");
        }
    }

    public static registerWakeUpHandler(callback: Function) {
        this.wakeupCallback = callback;
        if (sys.OS.ANDROID == sys.os) {
            native.reflection.callStaticMethod(java_class_name, "registerWakeup", "()V");
        } else {
            native.reflection.callStaticMethod(iOS_class_bridge, "registerWakeup");
        }
    }

    public static reportRegister() {
        if (sys.OS.ANDROID == sys.os) {
            native.reflection.callStaticMethod(java_class_name, "reportRegister", "()V");
        } else {
            native.reflection.callStaticMethod(iOS_class_bridge, "reportRegister");
        }
    }

    public static reportEffectPoint(pointId: string, pointValue: number, extraParam: Object) {
        if (sys.OS.ANDROID == sys.os) {
            var jsonStr = "{}";
            if (extraParam) {
                jsonStr = JSON.stringify(extraParam);
            }
            native.reflection.callStaticMethod(java_class_name, "reportEffectPoint", "(Ljava/lang/String;ILjava/lang/String;)V", pointId, pointValue, jsonStr);
        } else {
            var jsonStr = "{}";
            if (extraParam) {
                jsonStr = JSON.stringify(extraParam);
            }
            native.reflection.callStaticMethod(iOS_class_bridge, "reportEffectPoint:Value:effectDictionary:", pointId, pointValue, jsonStr);
        }
    }

    public static reportShare(shareCode: string, sharePlatform: string, callback: Function) {
        this.shareCallback = callback
        if (sys.OS.ANDROID == sys.os) {
            native.reflection.callStaticMethod(java_class_name, "reportShare", "(Ljava/lang/String;Ljava/lang/String;)V", shareCode, sharePlatform);
        } else {
            native.reflection.callStaticMethod(iOS_class_bridge, "reportShare:sharePlatform:", shareCode, sharePlatform);
        }
    }

    private static _installCallback(result: string) {
        let appData = JSON.parse(result);
        //console.info("安装参数：channelCode=" + appData.channelCode + ", bindData=" + appData.bindData);
        this.installCallback(appData);
    }

    private static _wakeupCallback(result: string) {
        let appData = JSON.parse(result);
        //console.info("拉起参数：channelCode=" + appData.channelCode + ", bindData=" + appData.bindData);
        this.wakeupCallback(appData);
    }

    private static _shareCallback(result: string) {
        //console.info("分享统计回调：" + result)
        this.shareCallback(JSON.parse(result));
    }

}

window.OpenInstall = OpenInstallPlugin;
