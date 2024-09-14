import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:meshsightapp/presentation/widgets/node_information_card.dart';
import 'package:meshsightapp/presentation/widgets/node_telemetry_device_card.dart';

import '../../../localization/generated/l10n.dart';
import '../../widgets/base_scaffold.dart';
import '../../widgets/covering_error.dart';
import '../../widgets/covering_loading.dart';
import '../base_view.dart';
import 'node_detail_view_model.dart';

@RoutePage()
class NodeDetailView extends StatelessWidget {
  final int nodeId;
  const NodeDetailView({super.key, @pathParam required this.nodeId});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      modelProvider: () => NodeDetailViewModel(nodeId),
      onModelReady: (model) => model.initViewModel(context),
      builder: (context, model, child) {
        return BaseScaffold(
          appBarTitle: "${S.current.NodeDetail}@$nodeId",
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "${model.nodeInfo['item']?['longName']} (${model.nodeInfo['item']?['shortName']})",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Text(
                        "#${model.nodeInfo['id']} (${model.nodeInfo['idHex']})",
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(),
                    // 顯示裝置圖片
                    Center(
                      child: SizedBox(
                        height: 160.0,
                        child: Image.asset(model.deviceImagePath),
                      ),
                    ),
                    const Divider(),
                    // 顯示裝置資訊
                    NodeInformationCard(nodeInfo: model.nodeInfo),
                    const Divider(),
                    // 顯示裝置遙測
                    NodeTelemetryDeviceCard(
                        nodeTelemetryDevice: model.nodeTelemetryDevice)
                  ],
                ),
              ),
              if (model.initDataStatus == "loading" ||
                  model.initDataProgress < 100) ...[
                // 如果 API 正在讀取或進度小於 100
                CoveringLoading(
                  progress: model.initDataProgress.toDouble(),
                ),
              ] else if (model.initDataStatus == "error") ...[
                // 如果 API 讀取發生錯誤
                CoveringError(
                  pageErrorMessage: model.initDataErrorMesssage,
                  retryFunction: () {
                    model.initData();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
