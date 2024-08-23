import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/map_vision.dart';

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

  /// map
  // map.vision
  // 設定 map.vision
  static Future<void> setMapVision(MapVision vision) async {
    // 轉換成 json string
    String jsonString = jsonEncode(vision.toMap());
    await saveData<String>('map.vision', jsonString);
    return;
  }

  // 取得 map.vision
  static Future<MapVision> getMapVision() async {
    String? jsonString = await getData<String>('map.vision');
    // 如果沒有設定過，則給一個預設值並儲存
    if (jsonString == null) {
      // 預設值
      // 先取得 API 地區
      String apiRegion = await getApiRegion();
      // 根據 API 地區設定預設中心點
      MapVision vision;
      switch (apiRegion) {
        case "tw":
          vision = MapVision(
            center: const LatLng(23.46999, 120.95726), // 預設中心點為玉山
            zoom: 7.5,
          );
          break;
        case "global":
        default:
          vision = MapVision(
            center: const LatLng(0, 0), // 預設中心點為 0, 0
            zoom: 1,
          );
          break;
      }
      await setMapVision(vision);
      jsonString = jsonEncode(vision.toMap());
    }
    // 轉換成 Map<String, dynamic>
    Map<String, dynamic> map = jsonDecode(jsonString);
    MapVision result = MapVision.fromMap(map)!;
    return result;
  }

  // 刪除 map.vision
  static Future<void> removeMapVision() async {
    await removeData('map.vision');
    return;
  }

  // map.nodeLineVisibility
  // 設定 map.nodeLineVisibility
  static Future<void> setMapNodeLineVisibility(bool nodeLineVisibility) async {
    await saveData<bool>('map.nodeLineVisibility', nodeLineVisibility);
    return;
  }

  // 取得 map.nodeLineVisibility
  static Future<bool> getMapNodeLineVisibility() async {
    bool? result = await getData<bool>('map.nodeLineVisibility');
    // 如果沒有設定過，則給一個預設值並儲存
    if (result == null) {
      result = false; // 預設值
      await setMapNodeLineVisibility(result);
    }
    return result;
  }

  // 刪除 map.nodeLineVisibility
  static Future<void> removeMapNodeLineVisibility() async {
    await removeData('map.nodeLineVisibility');
    return;
  }

  // map.nodeCoverVisibility
  // 設定 map.nodeCoverVisibility
  static Future<void> setMapNodeCoverVisibility(
      bool nodeCoverVisibility) async {
    await saveData<bool>('map.nodeCoverVisibility', nodeCoverVisibility);
    return;
  }

  // 取得 map.nodeCoverVisibility
  static Future<bool> getMapNodeCoverVisibility() async {
    bool? result = await getData<bool>('map.nodeCoverVisibility');
    // 如果沒有設定過，則給一個預設值並儲存
    if (result == null) {
      result = false; // 預設值
      await setMapNodeCoverVisibility(result);
    }
    return result;
  }

  // 刪除 map.nodeCoverVisibility
  static Future<void> removeMapNodeCoverVisibility() async {
    await removeData('map.nodeCoverVisibility');
    return;
  }

  // map.scalebarVisibility
  // 設定 map.scalebarVisibility
  static Future<void> setMapScalebarVisibility(bool scalebarVisibility) async {
    await saveData<bool>('map.scalebarVisibility', scalebarVisibility);
    return;
  }

  // 取得 map.scalebarVisibility
  static Future<bool> getMapScalebarVisibility() async {
    bool? result = await getData<bool>('map.scalebarVisibility');
    // 如果沒有設定過，則給一個預設值並儲存
    if (result == null) {
      result = true; // 預設值
      await setMapScalebarVisibility(result);
    }
    return result;
  }

  // 刪除 map.scalebarVisibility
  static Future<void> removeMapScalebarVisibility() async {
    await removeData('map.scalebarVisibility');
    return;
  }

  // map.darkMode
  // 設定 map.darkMode
  static Future<void> setMapDarkMode(bool darkMode) async {
    await saveData<bool>('map.darkMode', darkMode);
    return;
  }

  // 取得 map.darkMode
  static Future<bool> getMapDarkMode() async {
    bool? result = await getData<bool>('map.darkMode');
    // 如果沒有設定過，則給一個預設值並儲存
    if (result == null) {
      result = false; // 預設值
      await setMapDarkMode(result);
    }
    return result;
  }

  // 刪除 map.darkMode
  static Future<void> removeMapDarkMode() async {
    await removeData('map.darkMode');
    return;
  }

  // map.nodeMaxAgeInHours
  // 設定 map.nodeMaxAgeInHours
  static Future<void> setMapNodeMaxAgeInHours(int nodeMaxAgeInHours) async {
    await saveData<int>('map.nodeMaxAgeInHours', nodeMaxAgeInHours);
    return;
  }

  // 取得 map.nodeMaxAgeInHours
  static Future<int> getMapNodeMaxAgeInHours() async {
    int? result = await getData<int>('map.nodeMaxAgeInHours');
    // 如果沒有設定過，則給一個預設值並儲存
    if (result == null) {
      result = 24; // 預設值
      await setMapNodeMaxAgeInHours(result);
    }
    return result;
  }

  // 刪除 map.nodeMaxAgeInHours
  static Future<void> removeMapNodeMaxAgeInHours() async {
    await removeData('map.nodeMaxAgeInHours');
    return;
  }

  // map.nodeNeighborMaxAgeInHours
  // 設定 map.nodeNeighborMaxAgeInHours
  static Future<void> setMapNodeNeighborMaxAgeInHours(
      int nodeNeighborMaxAgeInHours) async {
    await saveData<int>(
        'map.nodeNeighborMaxAgeInHours', nodeNeighborMaxAgeInHours);
    return;
  }

  // 取得 map.nodeNeighborMaxAgeInHours
  static Future<int> getMapNodeNeighborMaxAgeInHours() async {
    int? result = await getData<int>('map.nodeNeighborMaxAgeInHours');
    // 如果沒有設定過，則給一個預設值並儲存
    if (result == null) {
      result = 1; // 預設值
      await setMapNodeNeighborMaxAgeInHours(result);
    }
    return result;
  }

  // 刪除 map.nodeNeighborMaxAgeInHours
  static Future<void> removeMapNodeNeighborMaxAgeInHours() async {
    await removeData('map.nodeNeighborMaxAgeInHours');
    return;
  }

  // map.nodeMarkSize
  // 設定 map.nodeMarkSize
  static Future<void> setMapNodeMarkSize(int nodeMarkSize) async {
    await saveData<int>('map.nodeMarkSize', nodeMarkSize);
    return;
  }

  // 取得 map.nodeMarkSize
  static Future<int> getMapNodeMarkSize() async {
    int? result = await getData<int>('map.nodeMarkSize');
    // 如果沒有設定過，則給一個預設值並儲存
    if (result == null) {
      result = 64; // 預設值
      await setMapNodeMarkSize(result);
    }
    return result;
  }

  // 刪除 map.nodeMarkSize
  static Future<void> removeMapNodeMarkSize() async {
    await removeData('map.nodeMarkSize');
    return;
  }

  // map.nodeMarkNameVisibility
  // 設定 map.nodeMarkNameVisibility
  static Future<void> setMapNodeMarkNameVisibility(
      bool nodeMarkNameVisibility) async {
    await saveData<bool>('map.nodeMarkNameVisibility', nodeMarkNameVisibility);
    return;
  }

  // 取得 map.nodeMarkNameVisibility
  static Future<bool> getMapNodeMarkNameVisibility() async {
    bool? result = await getData<bool>('map.nodeMarkNameVisibility');
    // 如果沒有設定過，則給一個預設值並儲存
    if (result == null) {
      result = true; // 預設值
      await setMapNodeMarkNameVisibility(result);
    }
    return result;
  }

  // 刪除 map.nodeMarkNameVisibility
  static Future<void> removeMapNodeMarkNameVisibility() async {
    await removeData('map.nodeMarkNameVisibility');
    return;
  }

  // map.functionButtonMiniVisibility
  // 設定 map.functionButtonMiniVisibility
  static Future<void> setMapFunctionButtonMiniVisibility(
      bool functionButtonMiniVisibility) async {
    await saveData<bool>(
        'map.functionButtonMiniVisibility', functionButtonMiniVisibility);
    return;
  }

  // 取得 map.functionButtonMiniVisibility
  static Future<bool> getMapFunctionButtonMiniVisibility() async {
    bool? result = await getData<bool>('map.functionButtonMiniVisibility');
    // 如果沒有設定過，則給一個預設值並儲存
    if (result == null) {
      result = false; // 預設值
      await setMapFunctionButtonMiniVisibility(result);
    }
    return result;
  }

  // 刪除 map.functionButtonMiniVisibility
  static Future<void> removeMapFunctionButtonMiniVisibility() async {
    await removeData('map.functionButtonMiniVisibility');
    return;
  }

  // map.tile
  // 設定 map.tile
  static Future<void> setMapTile(String tileName) async {
    await saveData<String>('map.tile', tileName);
    return;
  }

  // 取得 map.tile
  static Future<String> getMapTile() async {
    String? result = await getData<String>('map.tile');
    // 如果沒有設定過，則給一個預設值並儲存
    if (result == null) {
      result = "default"; // 預設值
      await setMapTile(result);
    }
    return result;
  }

  // 刪除 map.tile
  static Future<void> removeMapTile() async {
    await removeData('map.tile');
    return;
  }

  // app.apiRegion
  // 設定 app.apiRegion
  static Future<void> setApiRegion(String apiRegion) async {
    await saveData<String>('app.apiRegion', apiRegion);
    return;
  }

  // 取得 app.apiRegion
  static Future<String> getApiRegion() async {
    String? result = await getData<String>('app.apiRegion');
    // 如果沒有設定過，則給一個預設值並儲存
    if (result == null) {
      // 預設值為 "tw"
      await setApiRegion("tw");
      result = "tw";
    }
    return result;
  }

  // 刪除 app.apiRegion
  static Future<void> removeApiRegion() async {
    await removeData('app.apiRegion');
    return;
  }
}
