import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../localization/generated/l10n.dart';
import '../../widgets/base_scaffold.dart';
import '../../widgets/mesh_node_map.dart';
import '../base_view.dart';
import 'index_map_view_model.dart';

@RoutePage()
class IndexMapView extends StatelessWidget {
  const IndexMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      modelProvider: () => IndexMapViewModel(),
      onModelReady: (model) => model.initViewModel(context),
      builder: (context, model, child) {
        return BaseScaffold(
          appBarTitle: S.current.Map,
          body: const MeshNodeMap(),
        );
      },
    );
  }
}
