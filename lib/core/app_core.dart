import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';

import '../presentation/views/base_view_model.dart';
import '../presentation/views/global_view_model.dart';
import '../router/app_router.dart';
import 'services/app_logging_service.dart';
import 'services/meshsight_gateway_api_service.dart';
import 'services/localization_service.dart';

final Map<String, dynamic> appConfig = GlobalConfiguration().appConfig;
final GetIt appLocator = GetIt.instance;

class AppCore {
  static Future<void> initialize() async {
    setupLocator();
    await setupConfig();
    await appSharedPreferenceChecker();
    appLocator<LocalizationService>().initialize();

    // appLocator<AppLoggingService>().initialize();
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
    // TODO: 等待完善
    /*
    // api region check
    String apiRegion = await SharedPreferencesUtil.getApiRegion();
    String? baseURL;
    do {
      baseURL = GlobalConfiguration().getDeepValue("api:url:$apiRegion");
      if (baseURL == null) {
        await SharedPreferencesUtil.removeApiRegion();
        apiRegion = await SharedPreferencesUtil.getApiRegion();
      }
    } while (baseURL == null);

    // map tile check
    String mapTile = await SharedPreferencesUtil.getMapTile();
    String? mapTileName;
    do {
      mapTileName = GlobalConfiguration()
          .getDeepValue("map:tile:$apiRegion:$mapTile:name");
      if (mapTileName == null) {
        await SharedPreferencesUtil.removeMapTile();
        mapTile = await SharedPreferencesUtil.getMapTile();
      }
    } while (mapTileName == null);
    */
  }
}
