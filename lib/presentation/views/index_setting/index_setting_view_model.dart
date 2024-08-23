import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';

import '../../../core/app_core.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/utils/shared_preferences_util.dart';
import '../base_view_model.dart';

class IndexSettingViewModel extends BaseViewModel {
  bool _mapDarkMode = false; // 地圖暗黑模式
  bool get mapDarkMode => _mapDarkMode;

  bool _mapNodeLineVisibility = true; // 地圖節點線
  bool get mapNodeLineVisibility => _mapNodeLineVisibility;

  bool _mapNodeCoverVisibility = true; // 地圖節點覆蓋
  bool get mapNodeCoverVisibility => _mapNodeCoverVisibility;

  int _mapNodeMaxAgeInHours = 24; // 地圖節點最大年齡
  int get mapNodeMaxAgeInHours => _mapNodeMaxAgeInHours;

  int _mapNodeNeighborMaxAgeInHours = 1; // 地圖節點鄰居最大年齡
  int get mapNodeNeighborMaxAgeInHours => _mapNodeNeighborMaxAgeInHours;

  bool _mapScalebarVisibility = true; // 地圖比例尺
  bool get mapScalebarVisibility => _mapScalebarVisibility;

  int _mapNodeMarkSize = 64; // 地圖節點標記大小
  int get mapNodeMarkSize => _mapNodeMarkSize;

  bool _mapNodeMarkNameVisibility = true; // 地圖節點標記名稱
  bool get mapNodeMarkNameVisibility => _mapNodeMarkNameVisibility;

  Locale? _currentLocale; // 目前語言
  Locale? get currentLocale => _currentLocale;

  bool _mapFunctionButtonMiniVisibility = true; // 地圖功能按鈕小型化
  bool get mapFunctionButtonMiniVisibility => _mapFunctionButtonMiniVisibility;

  String _apiRegion = 'global'; // API區域
  String get apiRegion => _apiRegion;

  List<String> _mapTileList = ['default'];
  List<String> get mapTileList => _mapTileList;

  String _mapTile = 'default'; // 地圖瓦片
  String get mapTile => _mapTile;

  // 初始化參數
  @override
  void initViewModel(BuildContext context) async {
    super.initViewModel(context);
    await initData();
  }

  Future<void> initData() async {
    setBusy(true);
    _mapDarkMode = await SharedPreferencesUtil.getMapDarkMode();
    _mapNodeLineVisibility =
        await SharedPreferencesUtil.getMapNodeLineVisibility();
    _mapNodeCoverVisibility =
        await SharedPreferencesUtil.getMapNodeCoverVisibility();
    _mapScalebarVisibility =
        await SharedPreferencesUtil.getMapScalebarVisibility();
    _mapNodeMaxAgeInHours =
        await SharedPreferencesUtil.getMapNodeMaxAgeInHours();
    _mapNodeNeighborMaxAgeInHours =
        await SharedPreferencesUtil.getMapNodeNeighborMaxAgeInHours();
    _mapNodeMarkSize = await SharedPreferencesUtil.getMapNodeMarkSize();
    _mapNodeMarkNameVisibility =
        await SharedPreferencesUtil.getMapNodeMarkNameVisibility();
    _currentLocale = appLocator<LocalizationService>().appLocale;
    _mapFunctionButtonMiniVisibility =
        await SharedPreferencesUtil.getMapFunctionButtonMiniVisibility();
    _apiRegion = await SharedPreferencesUtil.getApiRegion();
    _mapTileList = GlobalConfiguration()
        .getDeepValue('map:tile:$_apiRegion')
        .keys
        .toList();
    _mapTile = await SharedPreferencesUtil.getMapTile();
    setBusy(false);
  }

  Future<void> mapDarkModeSwitchOnChanged(bool state) async {
    setBusy(true);
    _mapDarkMode = state;
    await SharedPreferencesUtil.setMapDarkMode(state);
    setBusy(false);
  }

  Future<void> mapNodeLineVisibilitySwitchOnChanged(bool state) async {
    setBusy(true);
    _mapNodeLineVisibility = state;
    await SharedPreferencesUtil.setMapNodeLineVisibility(state);
    setBusy(false);
  }

  Future<void> mapNodeCoverVisibilitySwitchOnChanged(bool state) async {
    setBusy(true);
    _mapNodeCoverVisibility = state;
    await SharedPreferencesUtil.setMapNodeCoverVisibility(state);
    setBusy(false);
  }

  Future<void> mapScalebarVisibilitySwitchOnChanged(bool state) async {
    setBusy(true);
    _mapScalebarVisibility = state;
    await SharedPreferencesUtil.setMapScalebarVisibility(state);
    setBusy(false);
  }

  Future<void> mapNodeMaxAgeInHoursRadioOnChanged(int? value) async {
    if (value == null) return;
    setBusy(true);
    _mapNodeMaxAgeInHours = value;
    await SharedPreferencesUtil.setMapNodeMaxAgeInHours(value);
    setBusy(false);
  }

  Future<void> mapNodeNeighborMaxAgeInHoursSliderOnChanged(int? value) async {
    if (value == null) return;
    setBusy(true);
    _mapNodeNeighborMaxAgeInHours = value;
    await SharedPreferencesUtil.setMapNodeNeighborMaxAgeInHours(value);
    setBusy(false);
  }

  Future<void> mapNodeMarkSizeSliderOnChanged(int? value) async {
    if (value == null) return;
    setBusy(true);
    _mapNodeMarkSize = value;
    await SharedPreferencesUtil.setMapNodeMarkSize(value);
    setBusy(false);
  }

  Future<void> mapNodeMarkNameVisibilitySwitchOnChanged(bool state) async {
    setBusy(true);
    _mapNodeMarkNameVisibility = state;
    await SharedPreferencesUtil.setMapNodeMarkNameVisibility(state);
    setBusy(false);
  }

  Future<void> currentLocaleRadioOnChanged(Locale? locale) async {
    if (locale == null) return;
    setBusy(true);
    _currentLocale = locale;
    await appLocator<LocalizationService>().setAppLocale(locale: locale);
    setBusy(false);
  }

  Future<void> mapFunctionButtonMiniVisibilitySwitchOnChanged(
      bool state) async {
    setBusy(true);
    _mapFunctionButtonMiniVisibility = state;
    await SharedPreferencesUtil.setMapFunctionButtonMiniVisibility(state);
    setBusy(false);
  }

  Future<void> apiRegionRadioOnChanged(String? value) async {
    if (value == null) return;
    setBusy(true);
    _apiRegion = value;
    await SharedPreferencesUtil.setApiRegion(value);
    setBusy(false);
    await initData();
  }

  Future<void> mapTileRadioOnChanged(String? value) async {
    if (value == null) return;
    setBusy(true);
    _mapTile = value;
    await SharedPreferencesUtil.setMapTile(value);
    setBusy(false);
  }
}
