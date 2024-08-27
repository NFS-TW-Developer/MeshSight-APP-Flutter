import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:meshsightapp/core/models/app_setting_map.dart';

import '../../../core/app_core.dart';
import '../../../core/models/app_setting_api.dart';
import '../../../core/models/app_status_message.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/services/meshsight_gateway_api_service.dart';
import '../../../core/utils/shared_preferences_util.dart';
import '../../../localization/generated/l10n.dart';
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

  Map<String, dynamic> _apiAppSettingData = {}; // API data
  Map<String, dynamic> get apiAppSettingData => _apiAppSettingData;

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
    await getApiData();
  }

  Future<void> getApiData() async {
    try {
      setBusy(true);
      Map<String, dynamic>? data =
          await appLocator<MeshsightGatewayApiService>().appSettingData();
      if (data == null || data["status"] == "error") {
        throw (data != null
            ? "${S.current.ApiErrorMsg1}\n${data['message']}"
            : S.current.ApiErrorMsg1);
      }
      _apiAppSettingData = data['data'];
      // 檢查 setAppSettingMap 內是否合理

      if (_appSettingMap.nodeMaxAgeInHours >
          _apiAppSettingData['meshtasticPositionMaxQueryPeriod']) {
        await setAppSettingMap(AppSettingMap(
            nodeMaxAgeInHours:
                _apiAppSettingData['meshtasticPositionMaxQueryPeriod']));
      }
      if (_appSettingMap.nodeMaxAgeInHours >
          _apiAppSettingData['meshtasticNeighborinfoMaxQueryPeriod']) {
        await setAppSettingMap(AppSettingMap(
            nodeMaxAgeInHours:
                _apiAppSettingData['meshtasticNeighborinfoMaxQueryPeriod']));
      }
      setBusy(false);
    } catch (e) {
      globalViewModel.showStatusSnackBar(context,
          AppStatusMessage(status: false, message: S.current.ApiErrorMsg1));
    }
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
