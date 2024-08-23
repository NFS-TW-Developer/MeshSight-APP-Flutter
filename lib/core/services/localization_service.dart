import 'package:flutter/material.dart';
import 'package:logging_flutter/logging_flutter.dart';

import '../../localization/generated/l10n.dart';
import '../utils/shared_preferences_util.dart';

class LocalizationService {
  // app 端語言
  static Locale _appLocale = WidgetsBinding.instance.platformDispatcher.locale;

  Locale get appLocale => _appLocale;

  Future<void> initialize() async {
    Flogger.d('正在進行初始化...');
    await setAppLocale(); // 初始化 app 端語言

    Flogger.d('初始化完成');
  }

  // 取得 app 端語言
  Locale getAppLocale() {
    return _appLocale;
  }

  // 取得語言名稱
  String getLanguageName(Locale locale) {
    if (locale.toLanguageTag() == 'en') {
      return 'English';
    } else if (locale.toLanguageTag() == 'ja') {
      return '日本語';
    } else if (locale.toLanguageTag() == 'ko') {
      return '한국어';
    } else if (locale.toLanguageTag() == 'zh-Hant-TW') {
      return '繁體中文(台灣)';
    } else {
      // 對於其他語言，你可以繼續添加更多的條件，或者只是返回語言代碼
      return locale.languageCode;
    }
  }

  // 設定 app 端語言
  Future<void> setAppLocale({Locale? locale}) async {
    // 判斷是否有傳入 locale
    if (locale != null) {
      // 若有傳入 locale，則先檢查是否是支援的語言，如果不是，則嘗試設定語言為 Locale('en')
      if (isSupportedLocale(locale) == false) {
        Flogger.d("目前 ${locale.toString()} 為 APP 不支援的語言，將嘗試設定語言為 Locale('en')");
        locale = const Locale('en');
      }

      // 清除 shared_preferences 中的 locale 資料
      await SharedPreferencesUtil.removeLocaleLanguageCode();
      await SharedPreferencesUtil.removeLocaleScriptCode();
      await SharedPreferencesUtil.removeLocaleCountryCode();

      // languageCode 儲存到 shared_preferences
      await SharedPreferencesUtil.setLocaleLanguageCode(locale.languageCode);
      // 若有 scriptCode，儲存到 shared_preferences
      if (locale.scriptCode != null) {
        await SharedPreferencesUtil.setLocaleScriptCode(locale.scriptCode!);
      }
      // 若有 countryCode，儲存到 shared_preferences
      if (locale.countryCode != null) {
        await SharedPreferencesUtil.setLocaleCountryCode(locale.countryCode!);
      }
      // 完成後，存入 _appLocale，並載入
      _appLocale = locale;
      await loadAppLocale(locale: locale);
      Flogger.d('完成 APP 端 Locale 設定: $locale');
      return;
    }

    // 若無傳入 locale，則先使用 shared_preferences 取得已儲存語言資料，存入 _appLocale
    String? languageCode = await SharedPreferencesUtil.getLocaleLanguageCode();
    String? scriptCode = await SharedPreferencesUtil.getLocaleScriptCode();
    String? countryCode = await SharedPreferencesUtil.getLocaleCountryCode();
    // 判斷是否已設定過 app 端的 languageCode
    if (languageCode != null) {
      // 完成後，存入 _appLocale，並載入
      locale = Locale.fromSubtags(
          languageCode: languageCode,
          scriptCode: scriptCode,
          countryCode: countryCode);
      _appLocale = locale;
      await loadAppLocale(locale: locale);
      Flogger.d('已有 APP 端 Locale 設定: $locale');
      return;
    }

    // 沒有傳入 locale、沒有設定過 app 端的 languageCode，則取得系統語言，遞迴 setAppLocale
    // 從系統取得語言
    Locale systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    Flogger.d('無 APP 端 Locale 設定，將使用系統語言: $systemLocale');
    // 遞迴 setAppLocale
    await setAppLocale(locale: systemLocale);
    return;
  }

  // 載入 app 端語言
  Future<void> loadAppLocale({Locale? locale}) async {
    locale ??= _appLocale;
    await S.load(locale);
    Flogger.d('已載入語言: ${locale.toString()}');
    return;
  }

  // 獲取支援的 APP 端語言
  List<Locale> getSupportedLocales() {
    return S.delegate.supportedLocales;
  }

  // 檢查是否為 APP 端支援的語言
  bool isSupportedLocale(Locale locale) {
    return S.delegate.isSupported(locale);
  }
}
