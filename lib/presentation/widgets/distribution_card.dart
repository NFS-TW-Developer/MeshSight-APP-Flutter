import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging_flutter/logging_flutter.dart';

import '../../localization/generated/l10n.dart';

enum DistributionCategory { role, hardware, firmware }

class DistributionCard extends StatefulWidget {
  final DistributionCategory category;
  final String title;
  final String subtitle;
  final IconData icon;
  final MaterialColor colorScheme;
  final Map<String, dynamic> data;

  const DistributionCard({
    super.key,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colorScheme,
    required this.data,
  });

  @override
  State<DistributionCard> createState() => _DistributionCardState();
}

class _DistributionCardState extends State<DistributionCard> {
  List<String> _meshtasticDeviceImageFiles = [];

  @override
  void initState() {
    super.initState();
    _loadDeviceImages();
  }

  Future<void> _loadDeviceImages() async {
    try {
      final String manifestContent = await rootBundle.loadString(
        'AssetManifest.json',
      );
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final List<String> meshtasticDeviceImageFiles = manifestMap.keys
          .where(
            (String key) => key.startsWith('assets/images/meshtastic/device/'),
          )
          .toList();

      if (mounted) {
        setState(() {
          _meshtasticDeviceImageFiles = meshtasticDeviceImageFiles;
        });
      }
    } catch (e) {
      Flogger.e('Failed to load device images: $e');
    }
  }

  String _getDeviceImagePath(String deviceName) {
    return _meshtasticDeviceImageFiles.firstWhere(
      (file) => file.endsWith("$deviceName.jpg"),
      orElse: () => 'assets/images/meshtastic/device/0.default.png',
    );
  }

  void _showExpandedView(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 標題區域
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.colorScheme.shade400,
                              widget.colorScheme.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 完整列表
                  Flexible(child: _buildFullDistributionList()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullDistributionList() {
    final items = widget.data['items'] as List<dynamic>? ?? [];

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            S.current.NoData,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    // 計算總數用於計算百分比
    final totalCount = items.fold<int>(
      0,
      (sum, item) => sum + (item['count'] as int? ?? 0),
    );

    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index] as Map<String, dynamic>;
        final isTop = index < 3;
        final count = item['count'] as int? ?? 0;
        final percentage = totalCount > 0 ? count / totalCount : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: _buildDistributionItem(
            item['name'] as String? ?? S.current.Unknown,
            count,
            percentage,
            isTop,
            index,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.colorScheme.shade100, width: 1),
          boxShadow: [
            BoxShadow(
              color: widget.colorScheme.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題區域
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.colorScheme.shade400,
                        widget.colorScheme.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 統計卡片列表
            _buildDistributionList(),

            const SizedBox(height: 16),

            // 查看詳細按鈕
            GestureDetector(
              onTap: () => _showExpandedView(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: widget.colorScheme.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.colorScheme.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.expand_more,
                      color: widget.colorScheme.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      S.current.ViewDetails,
                      style: TextStyle(
                        color: widget.colorScheme.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionList() {
    // 使用傳入的真實數據，如果沒有數據則顯示空狀態
    final items = widget.data['items'] as List<dynamic>? ?? [];

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            S.current.NoData,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
      );
    }

    // 計算總數用於計算百分比
    final totalCount = items.fold<int>(
      0,
      (sum, item) => sum + (item['count'] as int? ?? 0),
    );

    // 處理數據：顯示前5名，第6名之後合併為「其他」
    final List<Map<String, dynamic>> processedItems = [];

    // 取前5名
    final topItems = items.take(5).toList();
    processedItems.addAll(topItems.cast<Map<String, dynamic>>());

    // 如果有第6名之後的數據，合併為「其他」
    if (items.length > 5) {
      final otherItems = items.skip(5);
      final otherCount = otherItems.fold<int>(
        0,
        (sum, item) => sum + (item['count'] as int? ?? 0),
      );

      if (otherCount > 0) {
        processedItems.add({'name': S.current.Other, 'count': otherCount});
      }
    }

    return Column(
      children: processedItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isTop = index < 3;
        final count = item['count'] as int? ?? 0;
        final percentage = totalCount > 0 ? count / totalCount : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: _buildDistributionItem(
            item['name'] as String? ?? S.current.Unknown,
            count,
            percentage,
            isTop,
            index,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDistributionItem(
    String name,
    int count,
    double percentage,
    bool isTop,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTop ? widget.colorScheme.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTop ? widget.colorScheme.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // 排名指示器
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isTop ? widget.colorScheme.shade600 : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: name == S.current.Other
                  ? const Icon(Icons.more_horiz, color: Colors.white, size: 16)
                  : Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // 硬體圖片（僅在 hardware 類型且不是「其他」時顯示）
          if (widget.category == DistributionCategory.hardware &&
              name != S.current.Other) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  _getDeviceImagePath(name),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.device_unknown,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // 名稱和進度條
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isTop
                              ? widget.colorScheme.shade800
                              : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isTop
                            ? widget.colorScheme.shade600
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percentage,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isTop
                                    ? [
                                        widget.colorScheme.shade400,
                                        widget.colorScheme.shade600,
                                      ]
                                    : [
                                        Colors.grey.shade400,
                                        Colors.grey.shade600,
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(percentage * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
