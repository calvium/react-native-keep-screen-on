package com.gijoehosaphat.keepscreenon;

import android.app.Activity;
import android.app.Application;
import android.view.WindowManager;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

public class KeepScreenOnModule extends ReactContextBaseJavaModule {

  private ReactApplicationContext mContext = null;

  public KeepScreenOnModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.mContext = reactContext;
  }

  @Override
  public String getName() {
    return "KeepScreenOn";
  }

  @ReactMethod
  public void setKeepScreenOn(Boolean bKeepScreenOn) {
    final Activity activity = getCurrentActivity();
    if (bKeepScreenOn == true) {
      if (activity != null) {
        activity.runOnUiThread(new Runnable() {
          @Override
          public void run() {
            activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
          }
        });
      }
    } else if (bKeepScreenOn == false) {
      if (activity != null) {
        activity.runOnUiThread(new Runnable() {
          @Override
          public void run() {
            activity.getWindow().clearFlags(android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
          }
        });
      }
    }
  }

  @ReactMethod
  public void setCustomBrightness(float brightness) {
    // NO-OP on Android for now
  }

  @ReactMethod
  public void setOriginalBrightness(float brightness) {
    // NO-OP on Android for now
  }

    @ReactMethod
    public void getBrightness(Callback callback) {
        // NO-OP on Android for now
        callback.invoke(1);
    }
    
    @ReactMethod
    public void resetBrightness() {
        // NO-OP on Android for now
    }
    
}
