import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../localization/generated/l10n.dart';
import '../../widgets/analysis_active_hourly_records.dart';
import '../../widgets/analysis_distribution.dart';
import '../../widgets/base_scaffold.dart';
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
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    Container(
                      width: 800,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey
                                .withValues(alpha: (0.5 * 255).toDouble()),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            S.current.AnalysisActiveHourlyRecord,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: Colors.blue,
                              ),
                              Text(S.current
                                  .AnalysisActiveHourlyRecordKnownCount),
                              const SizedBox(width: 16),
                              Container(
                                width: 16,
                                height: 16,
                                color: Colors.orange,
                              ),
                              Text(S.current
                                  .AnalysisActiveHourlyRecordUnKnownCount),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: const AnalysisActiceHourlyRecords(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 800,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: (0.5 * 255).toDouble()),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            S.current.AnalysisDistributionRole,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Container(
                              padding: const EdgeInsets.all(16),
                              child: const AnalysisDistribution(
                                type: 'role',
                              )),
                        ],
                      ),
                    ),
                    Container(
                      width: 800,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withValues(alpha: (0.5 * 255).toDouble()),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            S.current.AnalysisDistributionHardware,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Container(
                              padding: const EdgeInsets.all(16),
                              child: const AnalysisDistribution(
                                type: 'hardware',
                              )),
                        ],
                      ),
                    ),
                    Container(
                      width: 800,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withValues(alpha: (0.5 * 255).toDouble()),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            S.current.AnalysisDistributionFirmware,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Container(
                              padding: const EdgeInsets.all(16),
                              child: const AnalysisDistribution(
                                type: 'firmware',
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
