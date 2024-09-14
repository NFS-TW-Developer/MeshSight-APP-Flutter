import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../localization/generated/l10n.dart';

class NodeTelemetryDeviceCard extends StatelessWidget {
  final Map<String, dynamic> nodeTelemetryDevice;
  final int hourRange;

  const NodeTelemetryDeviceCard({
    super.key,
    required this.nodeTelemetryDevice,
    this.hourRange = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Text(
              S.current.NodeTelemetryDevice,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          AspectRatio(
            aspectRatio: 3 / 2,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 18,
                left: 12,
                top: 24,
                bottom: 12,
              ),
              child: LineChart(
                mainData(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        DateFormat('HH').format(DateTime.now()
            .subtract(Duration(hours: hourRange - value.toInt() - 1))),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final Map<int, String> valueTextMap = {
                0: '0%',
                25: '25%',
                50: '50%',
                75: '75%',
                100: '100%',
              };

              String text = valueTextMap[value.toInt()] ?? '';
              if (text.isEmpty) {
                return Container();
              }

              return Text(text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.left);
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: hourRange.toDouble() - 1,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        // 其他資料用
        LineChartBarData(
          color: Colors.transparent,
          spots: List.generate(
            nodeTelemetryDevice['items']?.length ?? 0,
            (index) {
              final item = nodeTelemetryDevice['items'][index];
              double x = hourRange -
                  DateTime.now()
                      .difference(DateTime.parse(item['createAt']))
                      .inHours -
                  1;
              return FlSpot(x, 100);
            },
          ),
        ),
        // 電量
        LineChartBarData(
          color: Colors.greenAccent,
          spots: List.generate(
            nodeTelemetryDevice['items']?.length ?? 0,
            (index) {
              final item = nodeTelemetryDevice['items'][index];
              double x = hourRange -
                  DateTime.now()
                      .difference(DateTime.parse(item['createAt']))
                      .inHours -
                  1;
              double y = item['batteryLevel'] ?? 0;
              return FlSpot(x, y);
            },
          ),
          barWidth: 3,
          dotData: FlDotData(
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 6,
                color: Colors.white,
                strokeWidth: 3,
                strokeColor: Colors.greenAccent,
              );
            },
          ),
        ),
        // Air Util TX
        LineChartBarData(
          color: Colors.redAccent,
          spots: List.generate(
            nodeTelemetryDevice['items']?.length ?? 0,
            (index) {
              final item = nodeTelemetryDevice['items'][index];
              double x = hourRange -
                  DateTime.now()
                      .difference(DateTime.parse(item['createAt']))
                      .inHours -
                  1;
              double y = ((item['airUtilTx'] ?? 0) * 100).roundToDouble() / 100;
              return FlSpot(x, y);
            },
          ),
          barWidth: 3,
          dotData: FlDotData(
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 6,
                color: Colors.white,
                strokeWidth: 3,
                strokeColor: Colors.redAccent,
              );
            },
          ),
        ),
        // Channel Utilization
        LineChartBarData(
          color: Colors.blueAccent,
          spots: List.generate(
            nodeTelemetryDevice['items']?.length ?? 0,
            (index) {
              final item = nodeTelemetryDevice['items'][index];
              double x = hourRange -
                  DateTime.now()
                      .difference(DateTime.parse(item['createAt']))
                      .inHours -
                  1;
              double y =
                  ((item['channelUtilization'] ?? 0) * 100).roundToDouble() /
                      100;
              return FlSpot(x, y);
            },
          ),
          barWidth: 3,
          dotData: FlDotData(
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 6,
                color: Colors.white,
                strokeWidth: 3,
                strokeColor: Colors.blueAccent,
              );
            },
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.grey,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              final item = nodeTelemetryDevice['items']?[flSpot.spotIndex];
              switch (flSpot.barIndex) {
                case 0:
                  return LineTooltipItem(
                    'Time\n',
                    const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat('MM/dd HH:00')
                            .format(DateTime.parse(item['createAt']).toLocal()),
                      ),
                    ],
                  );
                case 1:
                  double voltage =
                      ((item['voltage'] ?? 0) * 100).roundToDouble() / 100;
                  return LineTooltipItem(
                    'Battery Level\n',
                    const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '${flSpot.y}%(${voltage}v)',
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  );
                case 2:
                  return LineTooltipItem(
                    'AirUtilTX\n',
                    const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '${flSpot.y}%',
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  );
                case 3:
                  return LineTooltipItem(
                    'ChUtil\n',
                    const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '${flSpot.y}%',
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  );
                default:
                  return LineTooltipItem(
                    'Unknown\n',
                    const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '${flSpot.y}',
                      ),
                    ],
                  );
              }
            }).toList();
          },
        ),
      ),
    );
  }
}
