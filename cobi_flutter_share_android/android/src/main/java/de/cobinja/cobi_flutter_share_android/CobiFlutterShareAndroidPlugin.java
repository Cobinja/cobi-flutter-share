package de.cobinja.cobi_flutter_share_android;

import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.Person;
import androidx.core.content.pm.ShortcutInfoCompat;
import androidx.core.content.pm.ShortcutManagerCompat;
import androidx.core.graphics.drawable.IconCompat;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/** CobiFlutterShareAndroidPlugin */
public class CobiFlutterShareAndroidPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler, PluginRegistry.NewIntentListener, EventChannel.StreamHandler {
  
  private static final String TAG = "CobiFlutterShareAndroid";
  
  private static final String DIRECT_SHARING_INTENT_ACTION = "de.cobinja.DIRECT_SHARING_INTENT";
  
  private MethodChannel methodChannel;
  private EventChannel eventChannel;
  private Context context;
  
  private EventChannel.EventSink eventSink = null;
  
  PluginRegistry.Registrar registrar;
  private ActivityPluginBinding activityBinding;
  private FlutterAssets flutterAssets = null;
  
  private Map<String, Object> initialShareData = null;
  
  public static void registerWith(PluginRegistry.Registrar registrar) {
    final CobiFlutterShareAndroidPlugin plugin = new CobiFlutterShareAndroidPlugin();
    plugin.registrar = registrar;
    plugin.setupChannels(registrar.messenger());
  } 
  
  void setupChannels(BinaryMessenger binaryMessenger) {
    methodChannel = new MethodChannel(binaryMessenger, "de.cobinja/ShareMethods", JSONMethodCodec.INSTANCE);
    methodChannel.setMethodCallHandler(this);
    
    eventChannel = new EventChannel(binaryMessenger, "de.cobinja/ShareEvents", JSONMethodCodec.INSTANCE);
    eventChannel.setStreamHandler(this);
  }
  
  void teardownChannels() {
    methodChannel.setMethodCallHandler(null);
    methodChannel = null;
    
    eventChannel.setStreamHandler(null);
    eventChannel = null;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    flutterAssets = flutterPluginBinding.getFlutterAssets();
    setupChannels(flutterPluginBinding.getBinaryMessenger());
  }
  
  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    teardownChannels();
  }
  
  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    Log.d(TAG, "onAttachedToActivity: invoked");
    activityBinding = binding;
    activityBinding.addOnNewIntentListener(this);
    handleIntent(binding.getActivity().getIntent());
  }
  
  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activityBinding.removeOnNewIntentListener(this);
  }
  
  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    activityBinding = binding;
    activityBinding.addOnNewIntentListener(this);
  }
  
  @Override
  public void onDetachedFromActivity() {
    activityBinding.removeOnNewIntentListener(this);
  }
  
  private Map<String, String> getShareItemFromUri(Uri uri) {
    if (uri == null) {
      return null;
    }
    ContentResolver cr = context.getContentResolver();
    Map<String, String> result = new HashMap<>();
    result.put("data", uri.toString());
    result.put("mimeType", cr.getType(uri));
    result.put("type", ShareItemTypes.FILE.toString());
    return result;
  }
  
  private boolean handleIntent(Intent intent) {
    Log.d(TAG, "onNewIntent: action: " + intent.getAction());
    String action = intent.getAction();
    if (!action.equals(Intent.ACTION_SEND) && !action.equals(Intent.ACTION_SEND_MULTIPLE)) {
      return false;
    }
    
    Map<String, Object> result = new HashMap<>();
  
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
      if (intent.hasExtra(Intent.EXTRA_SHORTCUT_ID)) {
        result.put("id", intent.getStringExtra(ShortcutManagerCompat.EXTRA_SHORTCUT_ID));
      }
    }
    
    List<Map<String, String>> shareItems = new ArrayList<>();
    
    if (intent.hasExtra(Intent.EXTRA_TEXT)) {
      // just plain text
      String text = intent.getStringExtra(Intent.EXTRA_TEXT);
      Map<String, String> item = new HashMap<>();
      item.put("mimeType", intent.getType());
      item.put("type", ShareItemTypes.TEXT.toString());
      item.put("data", text);
      shareItems.add(item);
    }
    else if (intent.hasExtra(Intent.EXTRA_STREAM)) {
      // single file
      if (action.equals(Intent.ACTION_SEND)) {
        Uri uri = intent.getParcelableExtra(Intent.EXTRA_STREAM);
        Map<String, String> item = getShareItemFromUri(uri);
        shareItems.add(item);
      }
      if (action.equals(Intent.ACTION_SEND_MULTIPLE)) {
        // multiple files
        List<Uri> uris = intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM);
        for (Uri uri : uris) {
          Map<String, String> item = getShareItemFromUri(uri);
          shareItems.add(item);
        }
      }
    }
    result.put("items", shareItems);
    Log.d(TAG, "handleIntent: result: " + result);
    if (eventSink == null) {
      initialShareData = result;
    }
    else {
      eventSink.success(result);
    }
    return true;
  }
  
  @Override
  public boolean onNewIntent(Intent intent) {
    return handleIntent(intent);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("addShareTargets")) {
      JSONArray targets = call.argument("targets");
      result.success(addMultipleShareTargets(targets));
    }
    if (call.method.equals("removeShareTargets")) {
      JSONArray ids = call.arguments();
      if (ids != null) {
        try {
          boolean success = removeShareTargets(ids);
          result.success(success);
        }
        catch (Exception e) {
          Log.e(TAG, "onMethodCall: Failed to remove share targets '" + ids + "'", e);
          result.success(false);
        }
        return;
      }
      result.success(false);
    }
    if (call.method.equals("removeAllShareTargets")) {
      try {
        removeAllShareTargets();
        result.success(true);
      }
      catch (Exception e) {
        Log.e(TAG, "onMethodCall: Failed to remove all share targets", e);
        result.success(false);
      }
    }
  }
  
  boolean addMultipleShareTargets(JSONArray targets) {
    boolean result = true;
    for (int i = 0; i < targets.length(); i++) {
      try {
        JSONObject target = targets.getJSONObject(i);
        result = result && addShareTarget(target);
      }
      catch (JSONException e) {
        Log.e(TAG, "addMultipleShareTargets: Could not read array item", e);
      }
    }
    return result;
  }
  
  boolean addShareTarget(JSONObject target) {
    Intent intent = new Intent(DIRECT_SHARING_INTENT_ACTION);
  
    Set<String> categories = new HashSet<>();
    
    String id;
    JSONArray cats;
  
    try {
      id = target.getString("id");
      cats = target.getJSONArray("categories");
      for (int i = 0; i < cats.length(); i++) {
        Log.d(TAG, "addShareTarget: adding category " + cats.get(i));
        categories.add((String) cats.get(i));
      }
    }
    catch (JSONException e) {
      Log.e(TAG, "addShareTarget: invalid shortcut json", e);
      return false;
    }
    
    // build the labels
    String shortLabel = null;
    try {
      shortLabel = target.getString("shortLabel");
    }
    catch (JSONException ignored) { }
  
    String longLabel = null;
    try {
      longLabel = target.getString("longLabel");
    }
    catch (JSONException ignored) { }
  
    ShortcutInfoCompat.Builder builder = new ShortcutInfoCompat.Builder(context, id)
      .setCategories(categories)
      .setLongLived(false)
      .setIntent(intent);
    
    if (shortLabel != null) {
     builder.setShortLabel(shortLabel); 
    }
    if (longLabel != null) {
      builder.setLongLabel(longLabel);
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
        builder.setPerson(new Person.Builder()
          .setName(longLabel)
          .build()
        );
      }
    }
    
    // build image to be shown with the shortcut
    Bitmap bitmap = null;
    String imageAssetByName = null;
    String imageByFilename = null;
  
    try {
      imageAssetByName = target.getString("imageByAssetName");
    }
    catch (JSONException ignored) { }
    try {
      imageByFilename = target.getString("imageByFilename");
    }
    catch (JSONException ignored) { }
  
    if (imageAssetByName != null) {
      bitmap = loadAssetIcon(imageAssetByName);
    }
    else if (imageByFilename != null) {
      bitmap = BitmapFactory.decodeFile(imageByFilename);
    }
    else if (target.has("imageBytes")) {
      try {
        JSONArray byteArray = target.getJSONArray("imageBytes");
        
        byte[] imageBytes = new byte[byteArray.length()];
        for (int i = 0; i < byteArray.length(); i++) {
          imageBytes[i] = (byte) byteArray.getInt(i);
        }
        
        bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.length);
      }
      catch (JSONException ignored) { }
    }
    
    if (bitmap != null) {
      builder.setIcon(IconCompat.createWithBitmap(bitmap));
    }
    else {
      Log.w(TAG, "addShareTarget: bitmap is null");
      return false;
    }
    
    // build the shortcut
    ShortcutInfoCompat info = builder.build();
  
    Log.d(TAG, "addShareTarget: Pushing dynamic shortcut for '" + id + "'");
    boolean result = ShortcutManagerCompat.pushDynamicShortcut(context, info);
    Log.d(TAG, "addShareTarget: successfully added target: " + result);
    return result;
  }
  
  private boolean removeShareTargets(JSONArray ids) {
    List<String> list = new ArrayList<>();
    boolean result = true;
    for (int i = 0; i < ids.length(); i++) {
      try {
        String id = ids.getString(i);
        list.add(id);
      }
      catch (JSONException e)  {
        Log.e(TAG, "removeShareTargets: Failed to parse id", e);
        result = false;
      }
    }
    Log.d(TAG, "removeShareTargets: ids " + list);
    ShortcutManagerCompat.removeDynamicShortcuts(context, list);
    return result;
  }
  
  private void removeAllShareTargets() {
    Log.d(TAG, "removeAllShareTargets");
    ShortcutManagerCompat.removeAllDynamicShortcuts(context);
  }
  
  private String loadAssetKey(@NonNull String key) {
    if (flutterAssets != null) {
      return flutterAssets.getAssetFilePathByName(key);
    }
    else if (registrar != null) {
      return registrar.lookupKeyForAsset(key);
    }
    return null;
  }
  
  private Bitmap loadAssetIcon(String name) {
    String key = loadAssetKey(name);
    if (key == null) {
      return null;
    }
    
    AssetManager assetManager = context.getAssets();
    try {
      String[] assets = assetManager.list("flutter_assets/images");
      StringBuilder buf = new StringBuilder();
      for (String str : assets) {
        buf.append(str).append(", ");
      }
      InputStream stream = assetManager.open(key);
      Bitmap bitmap = BitmapFactory.decodeStream(stream);
      stream.close();
      return bitmap;
    }
    catch (IOException e) {
      Log.e(TAG, "loadAsset: " + e.getMessage(), e);
    }
    return null;
  }
  
  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    eventSink = events;
    if (initialShareData != null) {
      eventSink.success(initialShareData);
      initialShareData = null;
    }
  }
  
  @Override
  public void onCancel(Object arguments) {
    eventSink.endOfStream();
    eventSink = null;
  }
  
  private enum ShareItemTypes {
    FILE,
    TEXT
  }
}
