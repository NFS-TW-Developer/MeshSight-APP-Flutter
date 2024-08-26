import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';

import '../../../core/app_core.dart';
import '../../../core/models/app_setting_api.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/utils/shared_preferences_util.dart';
import '../../../localization/generated/l10n.dart';
import '../base_view_model.dart';

class WelcomeViewModel extends BaseViewModel {
  AppSettingApi _appSettingApi = AppSettingApi();
  AppSettingApi get appSettingApi => _appSettingApi;

  final TextEditingController _textController = TextEditingController();
  TextEditingController get textController => _textController;

  Locale? _currentLocale; // 目前語言
  Locale? get currentLocale => _currentLocale;

  String? _errorMessage = '';
  String? get errorMessage => _errorMessage;

  @override
  initViewModel(BuildContext context) async {
    setBusy(true);
    _appSettingApi = await SharedPreferencesUtil.getAppSettingApi();
    _textController.text = _appSettingApi.apiUrl ?? '';
    setBusy(false);
    await setCurrentLocale(appLocator<LocalizationService>().appLocale);
  }

  bool validateApiUrl(String value) {
    setBusy(true);
    Uri uri = Uri.parse(value);
    if (uri.isAbsolute && uri.hasScheme && uri.hasAuthority) {
      _errorMessage = null;
      return true;
    } else {
      _errorMessage = S.current.STFormatErr(S.current.ApiUrl);
    }
    setBusy(false);
    return false;
  }

  Future<void> setCurrentLocale(Locale? locale) async {
    if (locale == null) return;
    setBusy(true);
    _currentLocale = locale;
    await appLocator<LocalizationService>().setAppLocale(locale: locale);
    setBusy(false);
  }

  void showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> apiDemoList =
            GlobalConfiguration().getDeepValue('api:demo').keys.toList();
        return AlertDialog(
          title: Text(S.current.SelectOurDemoApi),
          content: SingleChildScrollView(
            child: ListBody(
              children: apiDemoList.map((String option) {
                return GestureDetector(
                  onTap: () {
                    setBusy(true);
                    _textController.text = GlobalConfiguration()
                        .getDeepValue('api:demo:$option:url');
                    setBusy(false);
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(GlobalConfiguration()
                        .getDeepValue('api:demo:$option:name')),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> setAppSettingApi(AppSettingApi appSettingApi) async {
    await SharedPreferencesUtil.setAppSettingApi(appSettingApi);
  }
}
