import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:meshsightapp/core/models/app_setting_api.dart';

import '../presentation/views/base_view_model.dart';
import '../presentation/views/global_view_model.dart';
import '../router/app_router.dart';
import 'services/app_logging_service.dart';
import 'services/meshsight_gateway_api_service.dart';
import 'services/localization_service.dart';
import 'utils/shared_preferences_util.dart';

final Map<String, dynamic> appConfig = GlobalConfiguration().appConfig;
final GetIt appLocator = GetIt.instance;

class AppCore {
  static Future<void> initialize() async {
    setupLocator();
    await setupConfig();
    await appSharedPreferenceChecker();

    appLocator<LocalizationService>().initialize();
    appLocator<AppLoggingService>().initialize();
  }

  static void setupLocator() {
    appLocator.registerLazySingleton(() => AppRouter());
    appLocator.registerLazySingleton(() => BaseViewModel());
    appLocator.registerLazySingleton(() => GlobalViewModel());

    appLocator.registerLazySingleton(() => AppLoggingService());
    appLocator.registerLazySingleton(() => MeshsightGatewayApiService());
    appLocator.registerLazySingleton(() => LocalizationService());
  }

  static Future<void> setupConfig() async {
    await GlobalConfiguration().loadFromAsset("app_settings");
  }

  static Future<void> appSharedPreferenceChecker() async {
    AppSettingApi appSettingApi =
        await SharedPreferencesUtil.getAppSettingApi();
    switch (appSettingApi.apiServer) {
      case 'custom':
        if (appSettingApi.apiUrl == '') {
          appSettingApi = AppSettingApi(
            apiServer: 'default',
            apiUrl:
                GlobalConfiguration().getDeepValue('api:server:default:url'),
          );
          await SharedPreferencesUtil.setAppSettingApi(appSettingApi);
        }
        break;
      default:
        appSettingApi = appSettingApi.copyWith(
          apiUrl: GlobalConfiguration()
              .getDeepValue('api:server:${appSettingApi.apiServer}:url'),
        );
        await SharedPreferencesUtil.setAppSettingApi(appSettingApi);
        break;
    }
  }
}
