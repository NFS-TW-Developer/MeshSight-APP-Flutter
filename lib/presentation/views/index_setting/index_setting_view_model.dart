import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:meshsightapp/core/models/app_setting_map.dart';

import '../../../core/app_core.dart';
import '../../../core/models/app_setting_api.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/utils/shared_preferences_util.dart';
import '../base_view_model.dart';

class IndexSettingViewModel extends BaseViewModel {
  AppSettingApi _appSettingApi = AppSettingApi();
  AppSettingApi get appSettingApi => _appSettingApi;

  AppSettingMap _appSettingMap = AppSettingMap();
  AppSettingMap get appSettingMap => _appSettingMap;

  Locale? _currentLocale; // 目前語言
  Locale? get currentLocale => _currentLocale;

  List<String> _mapTileRegionList = ['global'];
  List<String> get mapTileRegionList => _mapTileRegionList;

  List<String> _mapTileProviderList = ['default'];
  List<String> get mapTileProviderList => _mapTileProviderList;

  // 初始化參數
  @override
  void initViewModel(BuildContext context) async {
    super.initViewModel(context);
    await initData();
  }

  Future<void> initData() async {
    await setAppSettingApi(await SharedPreferencesUtil.getAppSettingApi());
    await setAppSettingMap(await SharedPreferencesUtil.getAppSettingMap());
    await setCurrentLocale(appLocator<LocalizationService>().appLocale);
  }

  Future<void> setAppSettingApi(AppSettingApi appSettingApi) async {
    setBusy(true);
    _appSettingApi =
        await SharedPreferencesUtil.setAppSettingApi(appSettingApi);
    setBusy(false);
  }

  Future<void> resetAppSettingApi() async {
    await SharedPreferencesUtil.removeAppSettingApi();
  }

  Future<void> setAppSettingMap(AppSettingMap appSettingMap) async {
    setBusy(true);
    _appSettingMap =
        await SharedPreferencesUtil.setAppSettingMap(appSettingMap);
    _mapTileRegionList =
        GlobalConfiguration().getDeepValue('map:tile').keys.toList();
    _mapTileProviderList = GlobalConfiguration()
        .getDeepValue('map:tile:${_appSettingMap.tileRegion}')
        .keys
        .toList();
    setBusy(false);
  }

  Future<void> setCurrentLocale(Locale? locale) async {
    if (locale == null) return;
    setBusy(true);
    _currentLocale = locale;
    await appLocator<LocalizationService>().setAppLocale(locale: locale);
    setBusy(false);
  }
}
