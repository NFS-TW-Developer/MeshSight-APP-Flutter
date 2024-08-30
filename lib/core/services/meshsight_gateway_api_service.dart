import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:logging_flutter/logging_flutter.dart';
import 'package:meshsightapp/core/models/app_setting_api.dart';

import '../utils/shared_preferences_util.dart';

class MeshsightGatewayApiService {
  final double _generalTimeout =
      GlobalConfiguration().getDeepValue("api:timeout").toDouble();
  // 將錯誤處理抽象化到一個單獨的方法中，避免在每個 API 請求中重複相同的錯誤處理代碼
  // 當錯誤發生時，則拋出錯誤，以便在後續進行處理
  Future<http.Response> _performRequest(http.BaseRequest request,
      {double timeout = 60}) async {
    try {
      // 取得 request 的 method 和 body
      String requestBody = request is http.Request
          ? request.body
          : (request as http.MultipartRequest).fields.toString();
      http.StreamedResponse streamedResponse = await (request is http.Request
              ? request.send()
              : (request as http.MultipartRequest).send())
          .timeout(Duration(seconds: (timeout).toInt()));
      http.Response response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200) {
        String message = jsonDecode(response.body)["message"] ?? response.body;
        throw ('code: ${response.statusCode}\nmessage\n$message\nrequest: $requestBody\nbody: ${response.body}');
      }
      // Flogger.d('API 呼叫成功: ${request.url}');
      return response;
    } catch (e) {
      Flogger.d('API 呼叫失敗: ${request.url}\n錯誤訊息: $e');
      rethrow;
    }
  }

  // 將 URL 的構建抽象化到一個單獨的方法中，避免在每個 API 請求中重複相同的 URL 構建代碼
  Future<Uri> _buildGeneralUri(String path,
      {Map<String, dynamic>? queryParams, bool isEmbed = false}) async {
    AppSettingApi appSettingApi =
        await SharedPreferencesUtil.getAppSettingApi();
    String baseURL = appSettingApi.apiUrl;
    if (isEmbed) {
      baseURL = GlobalConfiguration().getDeepValue("api:server:default:url");
    }

    Uri uri = Uri.parse(baseURL);

    // 如果 queryParams 不為 null，遍歷每個鍵值，將非 String 類型，轉為 String 類型
    if (queryParams != null) {
      queryParams = queryParams.map((key, value) {
        if (value is! String) {
          return MapEntry(key, value.toString());
        } else {
          return MapEntry(key, value);
        }
      });
    }

    switch (uri.scheme) {
      case 'http':
        return Uri(
          scheme: 'http',
          host: uri.host,
          port: uri.port,
          path: path,
          queryParameters: queryParams,
        );
      case 'https':
      default:
        return Uri(
          scheme: 'https',
          host: uri.host,
          port: uri.port,
          path: path,
          queryParameters: queryParams,
        );
    }
  }

  // 將 Map<String, dynamic> 轉為 'application/x-www-form-urlencoded' 格式的字串
  String encodeMapToUrlFormEncoded(Map<String, dynamic> json) {
    return json.keys.map((key) {
      var value = Uri.encodeComponent(json[key].toString());
      return '$key=$value';
    }).join('&');
  }

  /// 以下為各項 API Function

  Future<Map<String, dynamic>?> analysisActiveHourlyRecords(
      {DateTime? start, DateTime? end}) async {
    try {
      http.Response response;
      // 重複嘗試，如果成功就不再重複，以確保資料取得，避免因網路問題導致資料取得失敗
      int doCount = 1; // 重複次數
      int doLimit = 3; // 重複上限
      do {
        response = await _performRequest(
          http.Request(
              'GET',
              await _buildGeneralUri('v1/analysis/active-hourly-records',
                  queryParams: {
                    if (start != null) 'start': start.toIso8601String(),
                    if (end != null) 'end': end.toIso8601String(),
                  })),
          timeout: _generalTimeout,
        );
        if (response.statusCode == 200) {
          // 資料取得成功，跳出
          break;
        }
        doCount++;
      } while (doCount <= doLimit);
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> analysisDistribution(String type) async {
    try {
      http.Response response;
      // 重複嘗試，如果成功就不再重複，以確保資料取得，避免因網路問題導致資料取得失敗
      int doCount = 1; // 重複次數
      int doLimit = 3; // 重複上限
      do {
        response = await _performRequest(
          http.Request(
              'GET', await _buildGeneralUri('v1/analysis/distribution/$type')),
          timeout: _generalTimeout,
        );
        if (response.statusCode == 200) {
          // 資料取得成功，跳出
          break;
        }
        doCount++;
      } while (doCount <= doLimit);
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> appSettingData() async {
    try {
      http.Response response;
      // 重複嘗試，如果成功就不再重複，以確保資料取得，避免因網路問題導致資料取得失敗
      int doCount = 1; // 重複次數
      int doLimit = 3; // 重複上限
      do {
        response = await _performRequest(
          http.Request('GET', await _buildGeneralUri('v1/app/setting/data')),
          timeout: _generalTimeout,
        );
        if (response.statusCode == 200) {
          // 資料取得成功，跳出
          break;
        }
        doCount++;
      } while (doCount <= doLimit);
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> mapCoordinates(
      {DateTime? start,
      DateTime? end,
      int? reportNodeHours,
      bool isEmbed = false}) async {
    try {
      http.Response response;
      // 重複嘗試，如果成功就不再重複，以確保資料取得，避免因網路問題導致資料取得失敗
      int doCount = 1; // 重複次數
      int doLimit = 3; // 重複上限
      do {
        response = await _performRequest(
          http.Request(
              'GET',
              await _buildGeneralUri('v1/map/coordinates',
                  queryParams: {
                    if (start != null) 'start': start.toIso8601String(),
                    if (end != null) 'end': end.toIso8601String(),
                    if (reportNodeHours != null)
                      'reportNodeHours': reportNodeHours.toString(),
                  },
                  isEmbed: isEmbed)),
          timeout: _generalTimeout,
        );
        if (response.statusCode == 200) {
          // 資料取得成功，跳出
          break;
        }
        doCount++;
      } while (doCount <= doLimit);
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      return null;
    }
  }
}
