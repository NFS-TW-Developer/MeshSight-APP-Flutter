import 'dart:developer';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logging_flutter/logging_flutter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_info_data.dart';
import '../models/app_logging.dart';
import '../utils/app_utils.dart';

class AppLoggingService {
  // 初始化 AppLoggingService
  Future<void> initialize() async {
    Flogger.d('正在進行初始化...');

    // 刪除7天前的紀錄
    if (!kIsWeb) {
      deleteAppLoggingsBefore(
          DateTime.now().subtract(const Duration(days: 7)).toString());
    }
    // 初始化 Flogger
    Flogger.init(
      config: const FloggerConfig(
        printClassName: true,
        // Print the class name where the log was triggered
        printMethodName: true,
        // Print the method name where the log was triggered
        showDateTime: true,
        // Print the date and time when the log occurred
        showDebugLogs: true, // Print logs with Debug severity
      ),
    );

    // You can also use "registerListener" to log to Crashlytics or any other services
    Flogger.registerListener((record) async {
      // Filter logs that may contain sensitive data
      if (record.loggerName != "App") return;
      if (record.message.contains("apiKey")) return;
      if (record.message.contains("password")) return;

      // 將收到的 log 儲存起來
      if (!kIsWeb) {
        final newAppLogging = AppLogging(
            id: record.hashCode.toString(),
            loggerName: record.loggerName,
            level: record.level.toString(),
            time: record.time.toString(),
            className: record.className.toString(),
            methodName: record.methodName.toString(),
            message: record.message,
            stackTrace: record.stackTrace.toString(),
            printable: record.printable());
        await addAppLogging(newAppLogging);
      }

      // 將 log 列印到開發者控制台。
      log(record.printable(), stackTrace: record.stackTrace);
    });

    // 監聽 Non-async exceptions
    FlutterError.onError = (errorDetails) {
      Flogger.e("[Non-async exceptions]${errorDetails.toString()}",
          stackTrace: null);
    };

    // 監聽 Async exceptions
    PlatformDispatcher.instance.onError = (error, stack) {
      Flogger.e("[Async exceptions]${error.toString()}", stackTrace: stack);
      return true;
    };

    Flogger.d('初始化完成');
  }

  /*
    取得資料庫連線
   */
  Future<Database> getDBConnect() async {
    // 這裡先呼叫 initDatabase 方法
    return await initDatabase();
  }

  /*
    初始化資料庫
   */
  Future<Database> initDatabase() async {
    // 設定資料庫路徑
    Database database = await openDatabase(
      join(await getDatabasesPath(), 'AppLogging.db'),
      onCreate: (db, version) {
        // 建立資料表
        return db.execute(
          "CREATE TABLE AppLoggings(id TEXT PRIMARY KEY, loggerName TEXT, level TEXT, time TEXT, className TEXT, methodName TEXT, message VARCHAR(5000), stackTrace TEXT, printable VARCHAR(5000))",
        );
      },
      version: 1,
    );
    // 回傳資料庫連線
    return database;
  }

  /*
    取得 AppLogging，可以根據條件進行篩選
    */
  Future<List<AppLogging>> getAppLoggings(
      {loggerName,
      List<dynamic>? level,
      timeBefore,
      timeAfter,
      className,
      methodName}) async {
    // 取得資料庫連線
    final Database db = await getDBConnect();

    // 根據條件查詢資料表，如果沒有的話就不查詢
    String query = "";
    if (loggerName != null ||
        level != null ||
        timeBefore != null ||
        timeAfter != null ||
        className != null ||
        methodName != null) {
      if (loggerName != null) {
        query += "loggerName = '$loggerName' AND ";
      }
      if (level != null) {
        query += "(";
        for (var i = 0; i < level.length; i++) {
          query += "level = '${level[i]}' OR ";
        }
        query = query.substring(0, query.length - 4);
        query += ") AND ";
      }
      if (timeBefore != null) {
        query += "time < '$timeBefore' AND ";
      }
      if (timeAfter != null) {
        query += "time > '$timeAfter' AND ";
      }
      if (className != null) {
        query += "className = '$className' AND ";
      }
      if (methodName != null) {
        query += "methodName = '$methodName' AND ";
      }
      query = query.substring(0, query.length - 5);
    }

    // 查詢資料表

    final List<Map<String, dynamic>> maps =
        await db.query('AppLoggings', where: query, orderBy: "time ASC");

    // 將查詢結果轉成 AppLogging 類型
    return List.generate(maps.length, (i) {
      return AppLogging(
        id: maps[i]['id'],
        loggerName: maps[i]['loggerName'],
        level: maps[i]['level'],
        time: maps[i]['time'],
        className: maps[i]['className'],
        methodName: maps[i]['methodName'],
        message: maps[i]['message'],
        stackTrace:
            maps[i]['stackTrace'] == "null" ? null : maps[i]['stackTrace'],
        printable: maps[i]['printable'],
      );
    });
  }

  /*
    新增一筆 AppLogging
    */
  Future<void> addAppLogging(AppLogging appLogging) async {
    // 取得資料庫連線
    final Database db = await getDBConnect();
    // 新增一筆資料
    await db.insert(
      'AppLoggings',
      appLogging.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // log("成功新增一筆 AppLogging 記錄:\n${appLogging.toMap()}");
  }

  /*
    清除所有 AppLogging
    */
  Future<void> clearAppLoggings() async {
    // 取得資料庫連線
    final Database db = await getDBConnect();
    // 刪除所有資料
    await db.delete('AppLoggings');
    Flogger.d("成功清除所有 AppLogging 記錄");
  }

  /*
    刪除某個時間以前的 AppLogging
    */
  Future<void> deleteAppLoggingsBefore(String time) async {
    // 取得資料庫連線
    final Database db = await getDBConnect();
    // 刪除所有資料
    await db.delete('AppLoggings', where: "time < '$time'");
    Flogger.d("成功刪除 $time 以前的 AppLogging 記錄");
  }

  /*
  取得現有的 className
   */
  Future<List<String>> getClassNameList() async {
    // 取得資料庫連線
    final Database db = await getDBConnect();
    // 查詢資料表
    final List<Map<String, dynamic>> maps = await db.query('AppLoggings',
        columns: ['className'], distinct: true, orderBy: "className ASC");
    // 將查詢結果轉成 String 類型
    return List.generate(maps.length, (i) {
      return maps[i]['className'];
    });
  }

  /*
  將 AppLogging.db 打包成 zip 檔並放置於下載路徑
   */
  Future<Map<bool, String?>> exportAppLoggingDB() async {
    // 取得裝置資訊
    final allDeviceInfo = (await DeviceInfoPlugin().deviceInfo).data;

    // 取得 App 名稱、版本、包名、建置編號
    AppInfoData appInfo = await AppUtils.getAppInfo();

    // 初始化路徑
    String outputPath = (await getApplicationCacheDirectory()).path;
    outputPath +=
        "/[${appInfo.appName}(${appInfo.packageName})]_${appInfo.version}+${appInfo.buildNumber}_${DateFormat('yyyyMMdd-HHmmss-MS').format(DateTime.now())}.log.zip";

    Flogger.d("正在將 log 打包至 $outputPath");
    // 壓縮各項所需檔案、資料夾
    var encoder =
        ZipFileEncoder(password: appInfo.packageName); // 密碼先設為 packageName
    encoder.create(outputPath);
    // 加入裝置資訊並轉為檔案
    encoder.addFile(File(
        join((await getApplicationCacheDirectory()).path, 'device_info.json'))
      ..writeAsStringSync(allDeviceInfo.toString()));
    encoder.addDirectory(Directory(await getDatabasesPath())); // 加入資料庫目錄
    //encoder.addFile(File((await getDBConnect()).path)); // 加入資料庫檔案
    encoder.close();
    Flogger.d("成功將 log 打包至 $outputPath");

    // 將打包後的檔案儲存至手機下載路徑
    final Directory? downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      Flogger.d("無法取得裝置下載路徑");
      return {false: "無法取得裝置下載路徑"};
    }
    final String downloadPath = join(downloadsDir.path, basename(outputPath));
    File(outputPath).copy(downloadPath);
    Flogger.d("成功將 log 打包至 $downloadPath");
    return {true: null};
  }
}
