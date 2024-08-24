class AppSettingApi {
  final String? apiUrl;

  AppSettingApi({
    this.apiUrl,
  });

  AppSettingApi copyWith({
    String? apiUrl,
  }) {
    return AppSettingApi(
      apiUrl: apiUrl ?? this.apiUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'apiUrl': apiUrl,
    };
  }

  static AppSettingApi? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }

    return AppSettingApi(
      apiUrl: map['apiUrl'],
    );
  }
}
