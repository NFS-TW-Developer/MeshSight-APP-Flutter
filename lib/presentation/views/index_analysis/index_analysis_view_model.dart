import 'package:logging_flutter/logging_flutter.dart';

import '../../../core/app_core.dart';
import '../../../core/services/meshsight_gateway_api_service.dart';
import '../../../localization/generated/l10n.dart';
import '../base_view_model.dart';

class IndexAnalysisViewModel extends BaseViewModel {
  Map<String, dynamic> _roleData = {};
  Map<String, dynamic> get roleData => _roleData;

  Map<String, dynamic> _hardwareData = {};
  Map<String, dynamic> get hardwareData => _hardwareData;

  Map<String, dynamic> _firmwareData = {};
  Map<String, dynamic> get firmwareData => _firmwareData;

  @override
  Future<void> initViewModel(context) async {
    super.initViewModel(context);
    await _loadAnalysisData();
  }

  Future<void> _loadAnalysisData() async {
    setBusy(true);
    try {
      // 並行獲取三種類型的數據
      final futures = [
        _getAnalysisData('role'),
        _getAnalysisData('hardware'),
        _getAnalysisData('firmware'),
      ];

      final results = await Future.wait(futures);

      _roleData = results[0];
      _hardwareData = results[1];
      _firmwareData = results[2];

      notifyListeners();
    } catch (e) {
      // 處理錯誤，可以加入錯誤狀態
      Flogger.e('Error loading analysis data: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<Map<String, dynamic>> _getAnalysisData(String type) async {
    try {
      final data = await appLocator<MeshsightGatewayApiService>()
          .analysisDistribution(type);

      if (data == null || data["status"] == "error") {
        throw (data != null
            ? "${S.current.ApiErrorMsg1}\n${data['message']}"
            : S.current.ApiErrorMsg1);
      }

      return data['data'] ?? {};
    } catch (e) {
      // 返回空數據而不是拋出錯誤，讓 UI 能正常顯示
      return {};
    }
  }

  // 重新載入數據的方法
  Future<void> refreshData() async {
    await _loadAnalysisData();
  }
}
