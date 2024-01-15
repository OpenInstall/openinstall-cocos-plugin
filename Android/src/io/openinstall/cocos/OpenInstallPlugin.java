package io.openinstall.cocos;

import android.content.Intent;
import android.util.Log;

import com.cocos.lib.CocosHelper;
import com.cocos.lib.CocosJavascriptJavaBridge;
import com.cocos.lib.GlobalObject;
import com.fm.openinstall.Configuration;
import com.fm.openinstall.OpenInstall;
import com.fm.openinstall.listener.AppInstallListener;
import com.fm.openinstall.listener.AppInstallRetryAdapter;
import com.fm.openinstall.listener.AppWakeUpListener;
import com.fm.openinstall.listener.ResultCallback;
import com.fm.openinstall.model.AppData;
import com.fm.openinstall.model.Error;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class OpenInstallPlugin {

    private static final String TAG = "OpenInstallPlugin";
    private static volatile boolean initialized = false;
    private static boolean registerWakeup = false;
    private static AppData wakeupDataHolder = null;
    private static Intent wakeupIntent = null;
    private static Configuration configuration = null;

    private final static String CALLBACK_PATTERN = "OpenInstall.%s(%s);";
    private final static String CALLBACK_INSTALL = "_installCallback";
    private final static String CALLBACK_WAKEUP = "_wakeupCallback";
    private final static String CALLBACK_SHARE = "_shareCallback";

    private static boolean hasTrue(JSONObject jsonObject, String key) {
        if (jsonObject.has(key)) {
            return jsonObject.optBoolean(key, false);
        }
        return false;
    }

    public static void preInit() {
        Log.d(TAG, "preInit");
        GlobalObject.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                OpenInstall.preInit(GlobalObject.getContext());
            }
        });
    }

    public static void config(final String jsonStr) {
        Log.d(TAG, "config jsonStr=" + jsonStr);
        GlobalObject.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject jsonObject = new JSONObject(jsonStr);
                    Configuration.Builder builder = new Configuration.Builder();
                    if (hasTrue(jsonObject, "adEnabled")) {
                        builder.adEnabled(true);
                    }
                    if (jsonObject.has("oaid")) {
                        builder.oaid(jsonObject.optString("oaid"));
                    }
                    if (jsonObject.has("gaid")) {
                        builder.gaid(jsonObject.optString("gaid"));
                    }
                    if (hasTrue(jsonObject, "imeiDisabled")) {
                        builder.imeiDisabled();
                    }
                    if (jsonObject.has("imei")) {
                        builder.imei(jsonObject.optString("imei"));
                    }
                    if (hasTrue(jsonObject, "macDisabled")) {
                        builder.macDisabled();
                    }
                    if (jsonObject.has("macAddress")) {
                        builder.macAddress(jsonObject.optString("macAddress"));
                    }
                    if (jsonObject.has("androidId")) {
                        builder.androidId(jsonObject.optString("androidId"));
                    }
                    if (jsonObject.has("serialNumber")) {
                        builder.serialNumber(jsonObject.optString("serialNumber"));
                    }
                    if (hasTrue(jsonObject, "simulatorDisabled")) {
                        builder.simulatorDisabled();
                    }
                    if (hasTrue(jsonObject, "storageDisabled")) {
                        builder.storageDisabled();
                    }
                    configuration = builder.build();
                } catch (JSONException e) {
//                throw new RuntimeException(e);
                    Log.e(TAG, "config parse error");
                }
            }

        });

    }

    public static void init() {
        GlobalObject.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                OpenInstall.init(GlobalObject.getActivity(), configuration);
                initialized();
            }
        });
    }

    private static void initialized() {
        initialized = true;
        if (wakeupIntent != null) {
            getWakeup(wakeupIntent);
            wakeupIntent = null;
        }
    }

    public static void getInstall(final int s) {
        GlobalObject.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                OpenInstall.getInstall(new AppInstallListener() {
                    @Override
                    public void onInstallFinish(AppData appData, Error error) {
                        boolean shouldRetry = error != null && error.shouldRetry();
                        final JSONObject jsonObject = toJson(appData);
                        putRetry(jsonObject, error != null && error.shouldRetry());
                        sendToScript(CALLBACK_INSTALL, jsonObject);
                    }
                }, s);
            }
        });
    }

    @Deprecated
    public static void getInstallCanRetry(final int s) {
        GlobalObject.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                OpenInstall.getInstallCanRetry(new AppInstallRetryAdapter() {
                    @Override
                    public void onInstall(AppData appData, boolean shouldRetry) {
                        final JSONObject jsonObject = toJson(appData);
                        putRetry(jsonObject, shouldRetry);
                        // 废弃 retry
                        try {
                            jsonObject.put("retry", shouldRetry);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        sendToScript(CALLBACK_INSTALL, jsonObject);
                    }
                }, s);
            }
        });
    }

    public static void registerWakeup() {
        GlobalObject.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.d(TAG, "registerWakeup");
                registerWakeup = true;
                if (wakeupDataHolder != null) {
                    sendWakeup(wakeupDataHolder);
                    wakeupDataHolder = null;
                }
            }
        });
    }

    public static void getWakeup(Intent intent) {
        if (initialized) {
            OpenInstall.getWakeUpAlwaysCallback(intent, new AppWakeUpListener() {
                @Override
                public void onWakeUpFinish(AppData appData, Error error) {
                    if (error != null) {
                        Log.d(TAG, "getWakeUpAlwaysCallback " + error.toString());
                    }
                    if (registerWakeup) {
                        sendWakeup(appData);
                    } else {
                        if (appData == null) {
                            wakeupDataHolder = new AppData();
                        } else {
                            wakeupDataHolder = appData;
                        }
                    }

                }
            });
        } else {
            wakeupIntent = intent;
        }
    }

    private static void sendWakeup(AppData appData) {
        if (appData == null) {
            appData = new AppData();
        }
        final JSONObject jsonObject = toJson(appData);
        sendToScript(CALLBACK_WAKEUP, jsonObject);
    }

    public static void reportRegister() {
        GlobalObject.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                OpenInstall.reportRegister();
            }
        });
    }

    // js 那边函数签名不能设置为 J -> long ，所以修改为 I -> int
    public static void reportEffectPoint(final String pointId, final int pointValue, final String extraJson) {
        Log.d(TAG, "reportEffectPoint " + extraJson);
        GlobalObject.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Map<String, String> extraMap = new HashMap<>();
                // extraJson to Map
                try {
                    JSONObject jsonObject = new JSONObject(extraJson);
                    Iterator<String> keys = jsonObject.keys();
                    while (keys.hasNext()) {
                        String key = keys.next();
                        String value = jsonObject.optString(key);
                        extraMap.put(key, value);
                    }
                } catch (JSONException e) {
                    // throw new RuntimeException(e);
                    Log.e(TAG, "reportEffectPoint parse error");
                }

                OpenInstall.reportEffectPoint(pointId, pointValue, extraMap);
            }
        });
    }

    public static void reportShare(final String shareCode, final String sharePlatform) {
        GlobalObject.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                OpenInstall.reportShare(shareCode, sharePlatform, new ResultCallback<Void>() {
                    @Override
                    public void onResult(Void ignore, Error error) {
                        final JSONObject jsonObject = new JSONObject();
                        putRetry(jsonObject, error != null && error.shouldRetry());
                        sendToScript(CALLBACK_SHARE, jsonObject);
                    }
                });
            }
        });
    }

    private static JSONObject toJson(AppData appData) {
        JSONObject jsonObject = new JSONObject();
        if (appData == null) return jsonObject;
        try {
            jsonObject.put("channelCode", appData.getChannel());
            jsonObject.put("bindData", appData.getData());
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return jsonObject;
    }

    private static void putRetry(JSONObject jsonObject, boolean shouldRetry) {
        try {
            jsonObject.put("shouldRetry", shouldRetry);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private static void sendToScript(String method, JSONObject data) {
        final String evalStr = String.format(CALLBACK_PATTERN, method, JSONObject.quote(data.toString()));
        Log.d(TAG, evalStr);
        CocosHelper.runOnGameThread(new Runnable() {
            @Override
            public void run() {
                CocosJavascriptJavaBridge.evalString(evalStr);
            }
        });
    }
}
