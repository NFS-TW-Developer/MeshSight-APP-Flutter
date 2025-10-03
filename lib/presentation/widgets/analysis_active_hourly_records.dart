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
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _initAll();
    // 每小時自動刷新數據
    _refreshTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _getApiData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: _buildChartContent(),
    );
  }

  Widget _buildChartContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_barGroups.isEmpty) {
      return _buildEmptyState();
    }

    return _buildChart();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 16),
          Text(
            S.current.Loading,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? S.current.ApiErrorMsg1,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _initAll,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(S.current.Retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            S.current.NoDataAvailable,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根據螢幕寬度調整顯示間隔
        final screenWidth = constraints.maxWidth;
        final showEveryNth = screenWidth < 400
            ? 24
            : screenWidth < 600
            ? 12
            : 8;

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: showEveryNth.toDouble(),
                  getTitlesWidget: (value, meta) => _bottomTitles(value, meta),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
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
              getDrawingHorizontalLine: (value) =>
                  FlLine(strokeWidth: 1, color: Colors.grey.shade300),
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                left: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            barGroups: _barGroups,
            maxY: _getMaxY(),
            groupsSpace: screenWidth < 400 ? 1 : 2,
          ),
        );
      },
    );
  }

  Future<void> _initAll() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _getApiData();
    await _generateBarGroups();
  }

  // 初始化數據
  Future<void> _getApiData() async {
    try {
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
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    if (_apiData.isEmpty || _apiData['items'] == null) {
      return const SideTitleWidget(axisSide: AxisSide.bottom, child: Text(''));
    }

    final items = _apiData['items'] as List<dynamic>?;
    if (items == null || value.toInt() >= items.length) {
      return const SideTitleWidget(axisSide: AxisSide.bottom, child: Text(''));
    }

    try {
      String timestamp = items[value.toInt()]['timestamp'] ?? '';
      if (timestamp.isEmpty) {
        return const SideTitleWidget(
          axisSide: AxisSide.bottom,
          child: Text(''),
        );
      }

      DateTime dateTime = DateTime.parse(timestamp).toLocal();

      // 在窄螢幕上只顯示關鍵時間點
      final screenWidth = MediaQuery.of(context).size.width;
      if (screenWidth < 400 && dateTime.hour % 6 != 0) {
        return const SideTitleWidget(
          axisSide: AxisSide.bottom,
          child: Text(''),
        );
      }

      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Transform.rotate(
          angle: -0.2, // 進一步減少旋轉角度
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            child: Text(
              "${dateTime.hour.toString().padLeft(2, '0')}h",
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      return const SideTitleWidget(axisSide: AxisSide.bottom, child: Text(''));
    }
  }

  Widget _leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toInt().toString(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Future<void> _generateBarGroups() async {
    List<BarChartGroupData> result = [];
    // 根據 API 回傳的數據，生成 BarChartGroupData
    if (_apiData.isNotEmpty && _apiData['items'] != null) {
      List<dynamic> items = _apiData['items'];
      for (int i = items.length - 1; i >= 0; i--) {
        try {
          double knownCount = (items[i]['knownCount'] ?? 0).toDouble();
          double unknownCount = (items[i]['unknownCount'] ?? 0).toDouble();

          result.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: knownCount + unknownCount,
                  width: 16,
                  rodStackItems: [
                    BarChartRodStackItem(0, knownCount, Colors.blue.shade400),
                    BarChartRodStackItem(
                      knownCount,
                      knownCount + unknownCount,
                      Colors.orange.shade400,
                    ),
                  ],
                ),
              ],
            ),
          );
        } catch (e) {
          // 跳過有問題的數據點
          continue;
        }
      }
    }
    setState(() {
      _barGroups = result;
    });
  }

  double _getMaxY() {
    if (_barGroups.isEmpty) return 10;

    double maxValue = 0;
    for (var group in _barGroups) {
      for (var rod in group.barRods) {
        if (rod.toY > maxValue) {
          maxValue = rod.toY;
        }
      }
    }

    // 添加一些邊距，讓圖表看起來更好
    return (maxValue * 1.1).ceilToDouble();
  }
}
