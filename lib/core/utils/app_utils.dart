import 'package:package_info_plus/package_info_plus.dart';

import '../../localization/generated/l10n.dart';
import '../models/app_info_data.dart';

class AppUtils {
  /*
   獲取 APP 資訊
   */
  static Future<AppInfoData> getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return AppInfoData(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      buildSignature: packageInfo.buildSignature,
      installerStore: packageInfo.installerStore ?? 'not available',
    );
  }

  /*
   將時間轉換為 XX ago 格式
   */
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 8) {
      return S.current.TimeAgoWeek((difference.inDays / 7).floor());
    } else if (difference.inDays >= 1) {
      return S.current.TimeAgoDay(difference.inDays);
    } else if (difference.inHours >= 1) {
      return S.current.TimeAgoHour(difference.inHours);
    } else {
      return S.current.TimeAgoMinute(difference.inMinutes);
    }
  }

  /*
    驗證是否為有效的 URL
   */
  static bool isValidUrl(String value) {
    Uri uri = Uri.parse(value);
    return uri.isAbsolute && uri.hasScheme && uri.hasAuthority;
  }
}
