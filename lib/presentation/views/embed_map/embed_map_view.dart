import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/models/map_vision.dart';
import '../../../localization/generated/l10n.dart';
import '../../widgets/base_scaffold.dart';
import '../../widgets/mesh_node_map.dart';
import '../base_view.dart';
import 'embed_map_view_model.dart';

@RoutePage()
class EmbedMapView extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  const EmbedMapView(
      {super.key,
      @pathParam this.latitude = 23.46999,
      @pathParam this.longitude = 120.95726,
      @pathParam this.zoom = 7.5});

  @override
  Widget build(BuildContext context) {
    MapVision embedMapVision = MapVision(
      center: LatLng(latitude, longitude),
      zoom: zoom,
    );
    return BaseView(
      modelProvider: () => EmbedMapViewModel(),
      onModelReady: (model) => model.initViewModel(context),
      builder: (context, model, child) {
        return BaseScaffold(
          appBarShow: false,
          appBarTitle: S.current.EmbedMap,
          body: MeshNodeMap(isEmbed: true, embedMapVision: embedMapVision),
        );
      },
    );
  }
}
