import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meshsightapp/core/models/app_setting_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_setting_api.dart';

class SharedPreferencesUtil {
  /*
  基礎 function 儲存資料
   */
  static Future<void> saveData<type>(String key, type value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (type) {
      case const (int):
        await prefs.setInt(key, value as int);
        break;
      case const (bool):
        await prefs.setBool(key, value as bool);
        break;
      case const (double):
        await prefs.setDouble(key, value as double);
        break;
      case const (String):
        await prefs.setString(key, value as String);
        break;
      case const (List<String>):
        await prefs.setStringList(key, value as List<String>);
        break;
    }
    return;
  }

  /*
  基礎 function 讀取資料
   */
  static Future<dynamic> getData<type>(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (type) {
      case const (int):
        final int? res = prefs.getInt(key);
        return res;
      case const (bool):
        final bool? res = prefs.getBool(key);
        return res;
      case const (double):
        final double? res = prefs.getDouble(key);
        return res;
      case const (String):
        final String? res = prefs.getString(key);
        return res;
      case const (List<String>):
        final List<String>? res = prefs.getStringList(key);
        return res;
    }
    return null;
  }

  /*
  基礎 function 刪除資料
   */
  static Future<void> removeData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    return;
  }

  /*
  清除全部 shared preference 資料
   */
  static Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    return;
  }

  /// 以下開始為自訂 function
  /// locale.languageCode
  // 設定 locale.languageCode
  static Future<void> setLocaleLanguageCode(String languageCode) async {
    await saveData<String>('locale.languageCode', languageCode);
    return;
  }

  // 取得 locale.languageCode
  static Future<String?> getLocaleLanguageCode() async {
    String? result = await getData<String>('locale.languageCode');
    // 如果沒有設定過，則給一個預設值並儲存
    if (result == null) {
      // 預設值為 null
    }
    return result;
  }

  // 刪除 locale.languageCode
  static Future<void> removeLocaleLanguageCode() async {
    await removeData('locale.languageCode');
    return;
  }

  /// locale.scriptCode
  // 設定 locale.scriptCode
  static Future<void> setLocaleScriptCode(String scriptCode) async {
    await saveData<String>('locale.scriptCode', scriptCode);
    return;
  }

  // 取得 locale.scriptCode
  static Future<String?> getLocaleScriptCode() async {
    String? result = await getData<String>('locale.scriptCode');
    // 如果沒有設定過，則給一個預設值並儲存
    if (result == null) {
      // 預設值為 null
    }
    return result;
  }

  // 刪除 locale.scriptCode
  static Future<void> removeLocaleScriptCode() async {
    await removeData('locale.scriptCode');
    return;
  }

  /// locale.countryCode
  // 設定 locale.countryCode
  static Future<void> setLocaleCountryCode(String countryCode) async {
    await saveData<String>('locale.countryCode', countryCode);
    return;
  }

  // 取得 locale.countryCode
  static Future<String?> getLocaleCountryCode() async {
    String? result = await getData<String>('locale.countryCode');
    // 如果沒有設定過，則給一個預設值並儲存
    if (result == null) {
      // 預設值為 null
    }
    return result;
  }

  // 刪除 locale.countryCode
  static Future<void> removeLocaleCountryCode() async {
    await removeData('locale.countryCode');
    return;
  }

  // app.setting.api
  // 設定 app.setting.api
  static Future<AppSettingApi> setAppSettingApi(
      AppSettingApi appSettingApi) async {
    // 轉換成 json string
    String jsonString = jsonEncode(appSettingApi.toMap());
    await saveData<String>('app.setting.api', jsonString);
    return appSettingApi;
  }

  // 取得 app.setting.api
  static Future<AppSettingApi> getAppSettingApi() async {
    Locale systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    String? region =
        systemLocale.countryCode?.toLowerCase() == "tw" ? "tw" : null;
    String jsonString = await getData<String>('app.setting.api') ??
        jsonEncode(
            (await setAppSettingApi(AppSettingApi(apiServer: region))).toMap());
    return AppSettingApi.fromMap(jsonDecode(jsonString))!;
  }

  // 刪除 app.setting.api
  static Future<void> removeAppSettingApi() async {
    await removeData('app.setting.api');
    return;
  }

  // app.setting.map
  // 設定 app.setting.map
  static Future<AppSettingMap> setAppSettingMap(
      AppSettingMap appSettingMap) async {
    // 轉換成 json string
    String jsonString = jsonEncode(appSettingMap.toMap());
    await saveData<String>('app.setting.map', jsonString);
    return appSettingMap;
  }

  // 取得 app.setting.map
  static Future<AppSettingMap> getAppSettingMap() async {
    String jsonString = await getData<String>('app.setting.map') ??
        jsonEncode((await setAppSettingMap(AppSettingMap())).toMap());
    return AppSettingMap.fromMap(jsonDecode(jsonString))!;
  }

  // 刪除 app.setting.map
  static Future<void> removeAppSettingMap() async {
    await removeData('app.setting.map');
    return;
  }
}
