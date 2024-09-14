import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/app_core.dart';
import '../../../core/services/meshsight_gateway_api_service.dart';
import '../../../localization/generated/l10n.dart';
import '../base_view_model.dart';

class NodeDetailViewModel extends BaseViewModel {
  final int nodeId;
  NodeDetailViewModel(this.nodeId);

  String _initDataStatus = ""; // 初始化數據狀態
  String get initDataStatus => _initDataStatus;
  set initDataStatus(String value) {
    setBusy(true);
    _initDataStatus = value;
    setBusy(false);
  }

  int _initDataProgress = 0; // 初始化數據進度
  int get initDataProgress => _initDataProgress;
  set initDataProgress(int value) {
    setBusy(true);
    _initDataProgress = value;
    setBusy(false);
  }

  String _initDataErrorMesssage = ""; // 初始化數據錯誤信息
  String get initDataErrorMesssage => _initDataErrorMesssage;
  set initDataErrorMesssage(String value) {
    setBusy(true);
    _initDataErrorMesssage = value;
    setBusy(false);
  }

  List<String> _meshtasticDeviceImageFiles = [];
  List<String> get meshtasticDeviceImageFiles => _meshtasticDeviceImageFiles;
  set meshtasticDeviceImageFiles(List<String> value) {
    setBusy(true);
    _meshtasticDeviceImageFiles = value;
    setBusy(false);
  }

  String _deviceImagePath = "assets/images/app_icon.png";
  String get deviceImagePath => _deviceImagePath;
  set deviceImagePath(String value) {
    setBusy(true);
    _deviceImagePath = value;
    setBusy(false);
  }

  Map<String, dynamic> _nodeInfo = {}; // 節點資訊
  Map<String, dynamic> get nodeInfo => _nodeInfo;
  set nodeInfo(Map<String, dynamic> value) {
    setBusy(true);
    _nodeInfo = value;
    setBusy(false);
  }

  Map<String, dynamic> _nodeTelemetryDevice = {}; // 節點遙測 device
  Map<String, dynamic> get nodeTelemetryDevice => _nodeTelemetryDevice;
  set nodeTelemetryDevice(Map<String, dynamic> value) {
    setBusy(true);
    _nodeTelemetryDevice = value;
    setBusy(false);
  }

  DateTime _nodeTelemetryDeviceStart =
      DateTime.now().subtract(const Duration(hours: 24)); // 節點遙測 device 開始時間
  DateTime get nodeTelemetryDeviceStart => _nodeTelemetryDeviceStart;
  set nodeTelemetryDeviceStart(DateTime value) {
    setBusy(true);
    _nodeTelemetryDeviceStart = value;
    setBusy(false);
  }

  DateTime _nodeTelemetryDeviceEnd = DateTime.now(); // 節點遙測 device 結束時間
  DateTime get nodeTelemetryDeviceEnd => _nodeTelemetryDeviceEnd;
  set nodeTelemetryDeviceEnd(DateTime value) {
    setBusy(true);
    _nodeTelemetryDeviceEnd = value;
    setBusy(false);
  }

  @override
  Future<void> initViewModel(context) async {
    super.initViewModel(context);
    await initData();
  }

  // 初始化數據
  Future<void> initData() async {
    setBusy(true);
    try {
      initDataProgress = 0;
      Map<String, dynamic>? result;
      result = await appLocator<MeshsightGatewayApiService>().nodeInfo(nodeId);
      if (result == null || result["status"] == "error") {
        throw (result != null
            ? "${S.current.ApiErrorMsg1}\n${result['message']}"
            : S.current.ApiErrorMsg1);
      }
      nodeInfo = result['data'];
      initDataProgress = 30;
      result = await appLocator<MeshsightGatewayApiService>()
          .nodeTelemetryDevice(nodeId,
              start: nodeTelemetryDeviceStart, end: nodeTelemetryDeviceEnd);
      if (result == null || result["status"] == "error") {
        throw (result != null
            ? "${S.current.ApiErrorMsg1}\n${result['message']}"
            : S.current.ApiErrorMsg1);
      }
      nodeTelemetryDevice = result['data'];
      initDataProgress = 90;
      meshtasticDeviceImageFiles =
          (json.decode(await rootBundle.loadString('AssetManifest.json')))
              .keys
              .where((String key) =>
                  key.startsWith('assets/images/meshtastic/device/'))
              .toList();
      deviceImagePath = meshtasticDeviceImageFiles.firstWhere(
          (file) => file.endsWith("${nodeInfo['item']?['hardware']}.jpg"),
          orElse: () => 'assets/images/meshtastic/device/0.default.png');
      initDataProgress = 100;
      initDataStatus = 'success';
    } catch (e) {
      initDataStatus = 'error';
      initDataErrorMesssage = e.toString();
    }
    setBusy(false);
  }
}
