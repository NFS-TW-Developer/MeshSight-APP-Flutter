import 'package:auto_route/auto_route.dart';
import 'package:logging_flutter/logging_flutter.dart';
import 'package:meshsightapp/core/models/app_setting_api.dart';
import 'package:meshsightapp/core/utils/shared_preferences_util.dart';

import '../app_router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  Future<void> onNavigation(
      NavigationResolver resolver, StackRouter router) async {
    bool isSetApi = false;

    AppSettingApi appSettingApi =
        await SharedPreferencesUtil.getAppSettingApi();
    if (appSettingApi.apiUrl != null && appSettingApi.apiUrl != '') {
      isSetApi = true;
    }

    Flogger.d('appSettingApi.apiUrl: ${appSettingApi.apiUrl}');
    Flogger.d('isSetApi: $isSetApi');

    /// 以下為驗證邏輯處理區塊
    // 如果未設定 API URL，則導向設定頁面
    if (!isSetApi) {
      // 導向驗證頁面
      resolver.redirect(
        WelcomeRoute(onResult: (didSet) {
          if (didSet == null || !didSet) return;
          if (!router.canPop() && didSet) {
            Flogger.d('如果沒有上一層路由，則導向 IndexRoute');
            router.replace(const IndexRoute());
            return;
          }
          // 接收到設定的訊號後，繼續執行
          resolver.next(didSet);
          return;
        }),
      );
      return;
    }

    // 已驗證，繼續執行
    resolver.next(true);
    return;
  }
}
