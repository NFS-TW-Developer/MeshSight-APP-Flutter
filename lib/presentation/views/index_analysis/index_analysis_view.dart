import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../localization/generated/l10n.dart';
import '../../widgets/analysis_active_hourly_records.dart';
import '../../widgets/base_scaffold.dart';
import '../../widgets/distribution_card.dart';
import '../base_view.dart';
import 'index_analysis_view_model.dart';

@RoutePage()
class IndexAnalysisView extends StatelessWidget {
  const IndexAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      modelProvider: () => IndexAnalysisViewModel(),
      onModelReady: (model) => model.initViewModel(context),
      builder: (context, model, child) {
        return BaseScaffold(
          appBarTitle: S.current.Analysis,
          body: _buildDashboardLayout(context, model),
        );
      },
    );
  }

  Widget _buildDashboardLayout(
    BuildContext context,
    IndexAnalysisViewModel model,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomScrollView(
        slivers: [
          // 主要圖表區域
          SliverToBoxAdapter(child: _buildMainChart(context)),

          // 分佈分析網格
          SliverToBoxAdapter(child: _buildDistributionGrid(context, model)),

          // 底部間距
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildMainChart(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.timeline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.current.AnalysisActiveHourlyRecord,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      S.current.AnalysisActiveHourlyRecordSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildCompactLegend(),
          const SizedBox(height: 16),
          const AnalysisActiceHourlyRecords(),
        ],
      ),
    );
  }

  Widget _buildDistributionGrid(
    BuildContext context,
    IndexAnalysisViewModel model,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
              child: DistributionCard(
                category: DistributionCategory.role,
                title: S.current.AnalysisDistributionRole,
                subtitle: S.current.AnalysisDistributionRoleSubtitle,
                icon: Icons.people,
                colorScheme: Colors.green,
                data: model.roleData,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
              child: DistributionCard(
                category: DistributionCategory.hardware,
                title: S.current.AnalysisDistributionHardware,
                subtitle: S.current.AnalysisDistributionHardwareSubtitle,
                icon: Icons.memory,
                colorScheme: Colors.orange,
                data: model.hardwareData,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
              child: DistributionCard(
                category: DistributionCategory.firmware,
                title: S.current.AnalysisDistributionFirmware,
                subtitle: S.current.AnalysisDistributionFirmwareSubtitle,
                icon: Icons.settings_applications,
                colorScheme: Colors.deepPurple,
                data: model.firmwareData,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: _buildLegendDot(
              Colors.blue,
              S.current.AnalysisActiveHourlyRecordKnownCount,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: _buildLegendDot(
              Colors.orange,
              S.current.AnalysisActiveHourlyRecordUnKnownCount,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
