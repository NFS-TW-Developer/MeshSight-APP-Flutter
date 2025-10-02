import 'package:auto_route/auto_route.dart';
import 'package:logging_flutter/logging_flutter.dart';
import 'package:meshsightapp/core/models/app_setting_api.dart';
import 'package:meshsightapp/core/utils/shared_preferences_util.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    bool isSetApi = false;

    AppSettingApi appSettingApi =
        await SharedPreferencesUtil.getAppSettingApi();
    if (appSettingApi.apiUrl != '') {
      isSetApi = true;
    }

    Flogger.d('appSettingApi.apiUrl: ${appSettingApi.apiUrl}');
    Flogger.d('isSetApi: $isSetApi');

    // 已驗證，繼續執行
    resolver.next(true);
    return;
  }
}
