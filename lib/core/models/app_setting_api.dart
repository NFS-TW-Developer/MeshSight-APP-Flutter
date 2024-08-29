import 'package:global_configuration/global_configuration.dart';

class AppSettingApi {
  final String apiUrl;
  final String apiServer;

  AppSettingApi({
    String? apiUrl,
    String? apiServer,
  })  : apiUrl = apiUrl ??
            GlobalConfiguration().getDeepValue('api:server:default:url'),
        apiServer = apiServer ?? 'default';

  AppSettingApi copyWith({
    String? apiUrl,
    String? apiServer,
  }) {
    return AppSettingApi(
      apiUrl: apiUrl ?? this.apiUrl,
      apiServer: apiServer ?? this.apiServer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'apiUrl': apiUrl,
      'apiServer': apiServer,
    };
  }

  static AppSettingApi? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    return AppSettingApi(
      apiUrl: map['apiUrl'],
      apiServer: map['apiServer'],
    );
  }
}
