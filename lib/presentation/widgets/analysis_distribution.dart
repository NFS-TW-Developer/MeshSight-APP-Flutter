import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging_flutter/logging_flutter.dart';

import '../../core/app_core.dart';
import '../../core/services/meshsight_gateway_api_service.dart';
import '../../localization/generated/l10n.dart';

class AnalysisDistribution extends StatefulWidget {
  final String type;
  const AnalysisDistribution({super.key, required this.type});
  @override
  State<StatefulWidget> createState() => AnalysisDistributionState();
}

class AnalysisDistributionState extends State<AnalysisDistribution> {
  Map<String, dynamic> _apiData = {}; // API data
  List<String> _meshtasticDeviceImageFiles = [];

  @override
  void initState() {
    super.initState();
    _initAll();
    Timer.periodic(const Duration(hours: 1), (timer) {
      _getApiData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List<Widget>.generate(
        _apiData['items']?.length ?? 0,
        (index) {
          Map<String, dynamic> item = _apiData['items'][index];

          String deviceImagePath = _meshtasticDeviceImageFiles.firstWhere(
              (file) => file.endsWith("${item['name']}.jpg"),
              orElse: () => 'assets/images/meshtastic/device/0.default.png');
          return SizedBox(
            width: 150,
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  child: Image.asset(deviceImagePath),
                ),
                Text(item['name']),
                Text("(${item['count']})"),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _initAll() async {
    await _initEnv();
    await _getApiData();
  }

  Future<void> _initEnv() async {
    // _meshtasticDeviceImageFiles
    try {
      // 讀取 AssetManifest.json 檔案
      final String manifestContent =
          await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // 過濾出指定資料夾下的檔案
      final List<String> meshtasticDeviceImageFiles = manifestMap.keys
          .where((String key) =>
              key.startsWith('assets/images/meshtastic/device/'))
          .toList();

      // 更新檔案列表
      setState(() {
        _meshtasticDeviceImageFiles = meshtasticDeviceImageFiles;
      });
    } catch (e) {
      Flogger.e('Failed to load device images: $e');
    }
  }

  // 初始化數據
  Future<void> _getApiData() async {
    try {
      setState(() {
        _apiData = {};
      });
      Map<String, dynamic>? data =
          await appLocator<MeshsightGatewayApiService>()
              .analysisDistribution(widget.type);
      if (data == null || data["status"] == "error") {
        throw (data != null
            ? "${S.current.ApiErrorMsg1}\n${data['message']}"
            : S.current.ApiErrorMsg1);
      }
      setState(() {
        _apiData = data['data'];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
