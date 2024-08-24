import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/app_core.dart';
import '../../core/services/meshsight_gateway_api_service.dart';
import '../../localization/generated/l10n.dart';

class AnalysisActiceHourlyRecords extends StatefulWidget {
  const AnalysisActiceHourlyRecords({super.key});
  @override
  State<StatefulWidget> createState() => AnalysisActiceHourlyRecordsState();
}

class AnalysisActiceHourlyRecordsState
    extends State<AnalysisActiceHourlyRecords> {
  late Map<String, dynamic> _apiData; // API data
  List<BarChartGroupData> _barGroups = [];

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
    return AspectRatio(
      aspectRatio: 1.66,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                barTouchData: BarTouchData(
                  enabled: true,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: _bottomTitles,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: _leftTitles,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  checkToShowHorizontalLine: (value) => value % 10 == 0,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: _barGroups,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _initAll() async {
    await _getApiData();
    await _generateBarGroups();
  }

  // 初始化數據
  Future<void> _getApiData() async {
    try {
      setState(() {
        _apiData = {};
      });
      DateTime now = DateTime.now();
      Map<String, dynamic>? data =
          await appLocator<MeshsightGatewayApiService>()
              .analysisActiveHourlyRecords(
        start: now.subtract(const Duration(hours: 24)),
        end: now,
      );
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

  Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String timestamp = _apiData['items'][value.toInt()]['timestamp'];
    DateTime dateTime = DateTime.parse(timestamp).toLocal();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text("${dateTime.hour}h", style: style),
    );
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container();
    }
    const style = TextStyle(
      fontSize: 10,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue,
        style: style,
      ),
    );
  }

  Future<void> _generateBarGroups() async {
    List<BarChartGroupData> result = [];
    // 根據 API 回傳的數據，生成 BarChartGroupData
    if (_apiData.isNotEmpty) {
      List<dynamic> items = _apiData['items'];
      for (int i = items.length - 1; i >= 0; i--) {
        double knownCount = items[i]['knownCount'];
        double unknownCount = items[i]['unknownCount'];
        result.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: knownCount + unknownCount,
                rodStackItems: [
                  BarChartRodStackItem(0, knownCount, Colors.blue),
                  BarChartRodStackItem(
                      knownCount, knownCount + unknownCount, Colors.orange),
                ],
              ),
            ],
          ),
        );
      }
    }
    setState(() {
      _barGroups = result;
    });
  }
}
