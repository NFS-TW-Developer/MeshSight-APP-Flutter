class AppInfoData {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String buildSignature;
  final String installerStore;

  AppInfoData({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.buildSignature,
    required this.installerStore,
  });

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'packageName': packageName,
      'version': version,
      'buildNumber': buildNumber,
      'buildSignature': buildSignature,
      'installerStore': installerStore,
    };
  }
}
