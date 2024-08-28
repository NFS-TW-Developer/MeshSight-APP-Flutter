import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_cluster_2/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:logging_flutter/logging_flutter.dart';
import 'package:meshsightapp/core/models/app_setting_map.dart';
import 'package:meshsightapp/core/utils/app_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_core.dart';
import '../../core/models/map_vision.dart';
import '../../core/services/meshsight_gateway_api_service.dart';
import '../../core/utils/shared_preferences_util.dart';
import '../../localization/generated/l10n.dart';

class MeshNodeMap extends StatefulWidget {
  const MeshNodeMap({super.key});
  @override
  State<StatefulWidget> createState() => _MeshNodeMapState();
}

class _MeshNodeMapState extends State<MeshNodeMap>
    with TickerProviderStateMixin {
  AppSettingMap _appSettingMap = AppSettingMap();
  Map<String, dynamic> _mapCoordinatesData = {}; // 地圖節點資料
  final MapController _mapController = MapController(); // 地圖控制器
  MapVision _currentMapVision =
      const MapVision(center: LatLng(0, 0), zoom: 0); // 地圖視野
  // 是否顯示節點標籤
  bool _showNodeTag = false;
  bool _showNodeCover = false;
  bool _showNodeLine = false;

  List<Widget> _baseMapChildren1 = []; // 基礎地圖元素1
  List<Widget> _baseMapChildren2 = []; // 基礎地圖元素2
  List<Widget> _showMapChildren = []; // 顯示在地圖上的元素

  int _showCircleLayerID = 0; // 顯示的圓形ID

  List<String> _meshtasticDeviceImageFiles = [];

  bool _apiDataLoading = false;

  @override
  void initState() {
    super.initState();
    _initAll();
    Timer.periodic(const Duration(minutes: 1), (timer) {
      // 每分鐘更新一次資料
      _getApiData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentMapVision.center,
            initialZoom: _currentMapVision.zoom,
            onMapEvent: _onMapEvent,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate, // 禁止旋轉
            ),
            minZoom: 3.0,
            maxZoom: 18.0,
            cameraConstraint: CameraConstraint.contain(
              bounds: LatLngBounds(
                const LatLng(-90, -180),
                const LatLng(90, 180),
              ),
            ), // 相機邊界的最大經緯度 (接近南極北極)
          ),
          children: _showMapChildren,
        ),
        // 右下按鈕區
        Positioned(
          bottom: 32,
          right: 8,
          child: Column(
            children: [
              FloatingActionButton(
                mini: _appSettingMap.miniButton,
                onPressed: _getApiData,
                backgroundColor: Colors.blue,
                child: _apiDataLoading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.restart_alt),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: _appSettingMap.miniButton,
                onPressed: _pressLocationButton,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: _appSettingMap.miniButton,
                onPressed: _pressQuestionButton,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.question_mark),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _initAll() async {
    await _initEnv();
    await _initMap();
    await _getApiData();
  }

  Future<void> _initEnv() async {
    // _appSettingMap
    AppSettingMap appSettingMap =
        await SharedPreferencesUtil.getAppSettingMap();
    setState(() {
      _appSettingMap = appSettingMap;
    });
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

  Future<void> _initMap() async {
    await _initBaseMapChildren();
    await _setCurrentMapVision(_appSettingMap.mapVision);
    _goCurrentMapVision(animate: false);
  }

  Future<void> _initBaseMapChildren() async {
    bool scalebarVisibility = _appSettingMap.scalebarVisible;

    String tileRegion = _appSettingMap.tileRegion;
    String tileProvider = _appSettingMap.tileProvider;

    List<Widget> baseMapChildren1 = [
      // 地圖底圖
      GestureDetector(
        onTap: () async {
          _pressMapTile();
        },
        child: await _darkModeContainerIfEnabled(
          TileLayer(
            urlTemplate: GlobalConfiguration()
                .getDeepValue("map:tile:$tileRegion:$tileProvider:url"),
            userAgentPackageName:
                GlobalConfiguration().getDeepValue("map:userAgentPackageName"),
            tileProvider: CancellableNetworkTileProvider(),
          ),
        ),
      ),
    ];
    List<Widget> baseMapChildren2 = [
      if (scalebarVisibility) ...[
        // 比例尺
        const Scalebar(
          textStyle: TextStyle(color: Colors.black, fontSize: 14),
          alignment: Alignment.bottomCenter,
          length: ScalebarLength.xxl,
        ),
      ],
      // 左下方 Attribution 宣告
      RichAttributionWidget(
        alignment: AttributionAlignment.bottomLeft,
        popupInitialDisplayDuration: const Duration(seconds: 1),
        animationConfig: const ScaleRAWA(),
        showFlutterMapAttribution: true,
        attributions: [
          const TextSourceAttribution(
            'This project is not affiliated with or endorsed by the Meshtastic project.\n'
            'The Meshtastic logo is the trademark of Meshtastic LLC.',
            prependCopyright: false,
            textStyle: TextStyle(fontSize: 8),
          ),
          TextSourceAttribution(
            GlobalConfiguration().getDeepValue(
                "map:tile:$tileRegion:$tileProvider:copyrightName"),
            onTap: () async {
              await launchUrl(Uri.parse(GlobalConfiguration().getDeepValue(
                  "map:tile:$tileRegion:$tileProvider:copyrightUrl")));
            },
          ),
        ],
      ),
    ];

    setState(() {
      _baseMapChildren1 = baseMapChildren1;
      _baseMapChildren2 = baseMapChildren2;
    });
  }

  // 初始化數據
  Future<void> _getApiData() async {
    setState(() {
      _apiDataLoading = true;
    });
    try {
      DateTime now = DateTime.now();
      int mapNodeMaxAgeInHours = _appSettingMap.nodeMaxAgeInHours;
      int mapNodeNeighborMaxAgeInHours =
          _appSettingMap.nodeNeighborMaxAgeInHours;
      Map<String, dynamic>? data =
          await appLocator<MeshsightGatewayApiService>().mapCoordinates(
        start: now.subtract(Duration(hours: mapNodeMaxAgeInHours)),
        end: now,
        reportNodeHours: mapNodeNeighborMaxAgeInHours,
      );
      if (data == null || data["status"] == "error") {
        throw (data != null
            ? "${S.current.ApiErrorMsg1}\n${data['message']}"
            : S.current.ApiErrorMsg1);
      }
      setState(() {
        _mapCoordinatesData = data['data'];
      });
      await _generateShowMapChildren();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    setState(() {
      _apiDataLoading = false;
    });
  }

  Future<void> _onMapEvent(MapEvent event) async {
    switch (event) {
      case MapEventScrollWheelZoom():
        await _setCurrentMapVision(MapVision(
            center: _mapController.camera.center,
            zoom: _mapController.camera.zoom));
        await _generateShowMapChildren();
        break;
      case MapEventMove():
        _setCurrentMapVision(MapVision(
            center: _mapController.camera.center,
            zoom: _mapController.camera.zoom));
        break;
      case MapEventMoveEnd():
        await _generateShowMapChildren();
        break;
      default:
        break;
    }
  }

  Future<void> _setCurrentMapVision(MapVision vision) async {
    setState(() {
      _currentMapVision = vision;
      _showNodeCover = vision.zoom >= 9.5;
      _showNodeLine = vision.zoom >= 10.5;
      _showNodeTag = vision.zoom >= 12.0;
    });
    AppSettingMap appSettingMap = await SharedPreferencesUtil.setAppSettingMap(
        _appSettingMap.copyWith(mapVision: vision));
    setState(() {
      _appSettingMap = appSettingMap;
    });
  }

  void _goCurrentMapVision({bool animate = true}) {
    if (!animate) {
      _mapController.move(_currentMapVision.center, _currentMapVision.zoom);
      return;
    }
    LatLng destLocation = _currentMapVision.center;
    double destZoom = _currentMapVision.zoom;
    final camera = _mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  // 產生地圖元素
  Future<void> _generateShowMapChildren() async {
    // 清空地圖元素
    setState(() {
      _showMapChildren = _baseMapChildren1 + _baseMapChildren2;
    });
    List<Widget> showMapChildren = [];
    List<Widget> nodeLineChildren = [];
    List<Widget> nodeLineNeighborChildren = [];
    List<Widget> nodeCoverChildren = [];
    List<CircleMarker> nodeCircleMarker = [];
    List<Marker> nodeMarker = [];

    if (_mapCoordinatesData.isEmpty) {
      return;
    }

    // 產生節點標記
    List<dynamic> items = _mapCoordinatesData['items'];
    for (Map<String, dynamic> nodeA in items) {
      int nodeAId = nodeA['id'];
      Map<String, dynamic>? nodeAInfo = nodeA['info'];
      Map<String, dynamic>? nodeAPosition = nodeA['positions'][0];

      if (nodeAPosition == null) {
        continue;
      }

      LatLng nodeAPoint = LatLng(
          double.tryParse(nodeAPosition['latitude'].toString()) ?? 0.0,
          double.tryParse(nodeAPosition['longitude'].toString()) ?? 0.0);
      int nodeAPrecisionInMeters = nodeAPosition['precisionInMeters'] ?? 0;

      // 檢查節點是否在視野內
      if (!_isInCurrentMapVision(nodeAPoint)) {
        continue;
      }

      // 加入節點標記
      if (_showCircleLayerID == nodeAId) {
        nodeCircleMarker.add(_generateNodeCircleMarker(
            nodeAPoint, nodeAPrecisionInMeters, nodeAId));
      }
      nodeMarker.add(await _generateNodeMarker(
          nodeAPoint,
          nodeAPrecisionInMeters,
          nodeAId,
          nodeAInfo?['shortName'] ?? '???',
          DateTime.tryParse(nodeAPosition['updateAt'])!));
      // 反轉順序，讓最新的節點在最上面
      nodeMarker = nodeMarker.reversed.toList();
    }

    // 產生節點連線
    if (_showNodeLine && _appSettingMap.lineVisible) {
      List<dynamic> nodeLine = _mapCoordinatesData['nodeLine'];
      for (var line in nodeLine) {
        Map<String, dynamic>? nodeA = _mapCoordinatesData['items'].firstWhere(
            (element) => element['id'] == line[0],
            orElse: () => null);
        Map<String, dynamic>? nodeB = _mapCoordinatesData['items'].firstWhere(
            (element) => element['id'] == line[1],
            orElse: () => null);
        if (nodeA == null || nodeB == null) {
          continue;
        }
        Map<String, dynamic>? nodeAPosition = nodeA['positions'][0];
        Map<String, dynamic>? nodeBPosition = nodeB['positions'][0];
        if (nodeAPosition == null || nodeBPosition == null) {
          continue;
        }
        LatLng nodeAPoint = LatLng(
            double.tryParse(nodeAPosition['latitude'].toString()) ?? 0.0,
            double.tryParse(nodeAPosition['longitude'].toString()) ?? 0.0);
        LatLng nodeBPoint = LatLng(
            double.tryParse(nodeBPosition['latitude'].toString()) ?? 0.0,
            double.tryParse(nodeBPosition['longitude'].toString()) ?? 0.0);
        // 檢查節點是否在視野內
        if (!_isInCurrentMapVision(nodeAPoint) &&
            !_isInCurrentMapVision(nodeBPoint)) {
          continue;
        }
        nodeLineChildren.add(
            _generatePolyline(nodeAPoint, nodeBPoint, color: Colors.redAccent));
      }
    }

    // 產生節點連線 Neighbor
    if (_showNodeLine && _appSettingMap.lineVisible) {
      List<dynamic> nodeLine = _mapCoordinatesData['nodeLineNeighbor'];
      for (var line in nodeLine) {
        Map<String, dynamic>? nodeA = _mapCoordinatesData['items'].firstWhere(
            (element) => element['id'] == line[0],
            orElse: () => null);
        Map<String, dynamic>? nodeB = _mapCoordinatesData['items'].firstWhere(
            (element) => element['id'] == line[1],
            orElse: () => null);
        if (nodeA == null || nodeB == null) {
          continue;
        }
        Map<String, dynamic>? nodeAPosition = nodeA['positions'][0];
        Map<String, dynamic>? nodeBPosition = nodeB['positions'][0];
        if (nodeAPosition == null || nodeBPosition == null) {
          continue;
        }
        LatLng nodeAPoint = LatLng(
            double.tryParse(nodeAPosition['latitude'].toString()) ?? 0.0,
            double.tryParse(nodeAPosition['longitude'].toString()) ?? 0.0);
        LatLng nodeBPoint = LatLng(
            double.tryParse(nodeBPosition['latitude'].toString()) ?? 0.0,
            double.tryParse(nodeBPosition['longitude'].toString()) ?? 0.0);
        // 檢查節點是否在視野內
        if (!_isInCurrentMapVision(nodeAPoint) &&
            !_isInCurrentMapVision(nodeBPoint)) {
          continue;
        }
        nodeLineNeighborChildren.add(_generatePolyline(nodeAPoint, nodeBPoint,
            color: Colors.blueAccent));
      }
    }

    // 產生節點覆蓋
    if (_showNodeCover && _appSettingMap.coverVisible) {
      List<dynamic> nodeCoverage = _mapCoordinatesData['nodeCoverage'];
      for (var coverage in nodeCoverage) {
        Map<String, dynamic>? nodeA = _mapCoordinatesData['items'].firstWhere(
            (element) => element['id'] == coverage[0],
            orElse: () => null);
        Map<String, dynamic>? nodeB = _mapCoordinatesData['items'].firstWhere(
            (element) => element['id'] == coverage[1],
            orElse: () => null);
        Map<String, dynamic>? nodeC = _mapCoordinatesData['items'].firstWhere(
            (element) => element['id'] == coverage[2],
            orElse: () => null);
        if (nodeA == null || nodeB == null || nodeC == null) {
          continue;
        }
        Map<String, dynamic>? nodeAPosition = nodeA['positions'][0];
        Map<String, dynamic>? nodeBPosition = nodeB['positions'][0];
        Map<String, dynamic>? nodeCPosition = nodeC['positions'][0];
        if (nodeAPosition == null ||
            nodeBPosition == null ||
            nodeCPosition == null) {
          continue;
        }
        LatLng nodeAPoint = LatLng(
            double.tryParse(nodeAPosition['latitude'].toString()) ?? 0.0,
            double.tryParse(nodeAPosition['longitude'].toString()) ?? 0.0);
        LatLng nodeBPoint = LatLng(
            double.tryParse(nodeBPosition['latitude'].toString()) ?? 0.0,
            double.tryParse(nodeBPosition['longitude'].toString()) ?? 0.0);
        LatLng nodeCPoint = LatLng(
            double.tryParse(nodeCPosition['latitude'].toString()) ?? 0.0,
            double.tryParse(nodeCPosition['longitude'].toString()) ?? 0.0);
        // 檢查節點是否在視野內
        if (!_isInCurrentMapVision(nodeAPoint) &&
            !_isInCurrentMapVision(nodeBPoint) &&
            !_isInCurrentMapVision(nodeCPoint)) {
          continue;
        }
        nodeCoverChildren
            .add(_generatePolygon(nodeAPoint, nodeBPoint, nodeCPoint));
      }
    }

    // 開始堆疊地圖元素
    showMapChildren.addAll(_baseMapChildren1);
    showMapChildren.addAll(nodeCoverChildren);
    showMapChildren.addAll(nodeLineChildren);
    showMapChildren.addAll(nodeLineNeighborChildren);
    showMapChildren.add(
      CircleLayer(
        circles: nodeCircleMarker,
      ),
    );
    showMapChildren.add(
      MarkerClusterLayerWidget(
        options: MarkerClusterLayerOptions(
          showPolygon: false,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          markers: nodeMarker,
          centerMarkerOnClick: false,
          builder: (context, markers) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    markers.length < 50
                        ? Colors.purple
                        : markers.length < 100
                            ? Colors.cyan
                            : Colors.pink,
                    Colors.transparent,
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
              child: Center(
                child: Text(
                  markers.length.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        ),
      ),
    );
    showMapChildren.addAll(_baseMapChildren2);
    setState(() {
      _showMapChildren = showMapChildren;
    });
  }

  Future<void> _pressLocationButton() async {
    Position position = await Geolocator.getCurrentPosition();
    MapVision vision = MapVision(
        center: LatLng(position.latitude, position.longitude), zoom: 13);
    await _setCurrentMapVision(vision);
    _goCurrentMapVision();
    await _generateShowMapChildren();
  }

  Future<void> _pressQuestionButton() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(S.current.Guide,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // 寬度為螢幕寬度的 80%
            height: MediaQuery.of(context).size.height * 0.5, // 高度為螢幕高度的 50%
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(S.current.Legend),
                  Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Colors.grey[500]!,
                        width: 1,
                      ),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(8),
                    },
                    children: [
                      TableRow(children: [
                        const Icon(Icons.location_on, color: Colors.green),
                        Text(S.current.MapNodeMarkLegendGreen),
                      ]),
                      TableRow(children: [
                        const Icon(Icons.location_on, color: Colors.yellow),
                        Text(S.current.MapNodeMarkLegendYellow),
                      ]),
                      TableRow(children: [
                        const Icon(Icons.location_on, color: Colors.orange),
                        Text(S.current.MapNodeMarkLegendOrange),
                      ]),
                      TableRow(children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        Text(S.current.MapNodeMarkLegendBlue),
                      ]),
                      TableRow(children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        Text(S.current.MapNodeMarkLegendGrey),
                      ]),
                      TableRow(children: [
                        const Text(
                          ' -- - -- ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(S.current.MapNodeLineNeighborLegend),
                      ]),
                      TableRow(children: [
                        const Text(
                          ' -- - -- ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(S.current.MapNodeLineLegend),
                      ]),
                      TableRow(children: [
                        Text(
                          ' ▲  ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.green.withOpacity(0.22),
                              fontWeight: FontWeight.bold),
                        ),
                        Text(S.current.MapNodeCoverLegend),
                      ]),
                    ],
                  ),
                  const Divider(),
                  Text(S.current.Operate),
                  Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Colors.grey[500]!,
                        width: 1,
                      ),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(8),
                    },
                    children: [
                      TableRow(
                        children: [
                          const Wrap(
                            children: [
                              Icon(Icons.location_on, color: Colors.black),
                              Icon(Icons.touch_app),
                            ],
                          ),
                          Text(S.current.MapNodeMarkOnTapLegend),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Wrap(
                            children: [
                              Icon(Icons.location_on, color: Colors.black),
                              Icon(Icons.touch_app),
                            ],
                          ),
                          Text(S.current.MapNodeMarkOnLongPressLegend),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(S.current.IUnderstand),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 點擊地圖標記
  Future<void> _pressNodeMarker(int nodeId) async {
    // 繪製圓形
    setState(() {
      _showCircleLayerID = nodeId;
    });
    await _generateShowMapChildren();

    // 移動到節點位置，保持縮放
    LatLng? nodePosition = _getNodePosition(nodeId);
    double zoom = _currentMapVision.zoom < 12 ? 12 : _currentMapVision.zoom;
    if (nodePosition != null) {
      MapVision vision = MapVision(center: nodePosition, zoom: zoom);
      await _setCurrentMapVision(vision);
      _goCurrentMapVision();
    }
  }

  // 長按地圖標記
  Future<void> _longPressNodeMarker(int nodeId) async {
    await _pressNodeMarker(nodeId);
    await _showNodeInfo(nodeId);
  }

  // 點擊地圖底圖
  Future<void> _pressMapTile() async {
    setState(() {
      _showCircleLayerID = 0;
    });
    await _generateShowMapChildren();
  }

  // 產生節點標記
  Future<Marker> _generateNodeMarker(LatLng point, int precisionInMeters,
      int nodeId, String shortName, DateTime updateAt) async {
    int nodeMarkSize = _appSettingMap.nodeMarkSize;
    bool nodeMarkNameVisibility = _appSettingMap.nodeMarkNameVisible;
    return Marker(
      point: point,
      width: nodeMarkSize.toDouble(),
      height: nodeMarkSize.toDouble(),
      child: GestureDetector(
        onTap: () => _pressNodeMarker(nodeId),
        onLongPress: () => _longPressNodeMarker(nodeId),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_showNodeTag && nodeMarkNameVisibility) ...[
              Positioned(
                top: -nodeMarkSize / 10,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.56),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    shortName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: nodeMarkSize / 5,
                    ),
                  ),
                ),
              )
            ],
            Icon(
              Icons.location_on,
              size: nodeMarkSize / 2,
              color: updateAt.isAfter(
                      DateTime.now().subtract(const Duration(hours: 1)))
                  ? Colors.green // 一小時內
                  : updateAt.isAfter(
                          DateTime.now().subtract(const Duration(hours: 3)))
                      ? Colors.yellow // 三小時內
                      : updateAt.isAfter(
                              DateTime.now().subtract(const Duration(hours: 6)))
                          ? Colors.orange // 六小時內
                          : updateAt.isAfter(DateTime.now()
                                  .subtract(const Duration(hours: 12)))
                              ? Colors.blue // 12小時內
                              : Colors.grey, // 超過12小時
              shadows: const [
                Shadow(
                  color: Colors.black,
                  offset: Offset(1, 1),
                  blurRadius: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 產生節點標記
  CircleMarker _generateNodeCircleMarker(
      LatLng point, int precisionInMeters, int nodeId) {
    return CircleMarker(
      point: point,
      color: Colors.orange.withOpacity(0.22),
      borderColor: Colors.orange,
      borderStrokeWidth: 2,
      useRadiusInMeter: true,
      radius: precisionInMeters.toDouble(),
    );
  }

  // 計算兩個座標之間的距離
  double _calculateDistance(LatLng pointA, LatLng pointB) {
    const R = 6371; // 地球半徑，單位：公里
    double degToRad(double deg) {
      return deg * (pi / 180);
    }

    final dLat = degToRad(pointB.latitude - pointA.latitude);
    final dLon = degToRad(pointB.longitude - pointA.longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degToRad(pointA.latitude)) *
            cos(degToRad(pointB.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = R * c; // 單位：公里
    return distance * 1000; // 轉換為公尺
  }

  // 產生折線
  Widget _generatePolyline(LatLng pointA, LatLng pointB,
      {Color color = Colors.red}) {
    double distance = _calculateDistance(pointA, pointB);
    List<double> segments;
    if (distance < 100) {
      segments = [8, 4];
    } else if (distance < 1000) {
      segments = [16, 8];
    } else if (distance < 5000) {
      segments = [32, 16];
    } else {
      segments = [64, 32];
    }

    return PolylineLayer(
      polylines: [
        Polyline(
          points: [
            pointA,
            pointB,
          ],
          strokeWidth: 2,
          color: color.withOpacity(0.78),
          pattern: StrokePattern.dashed(
            segments: segments,
          ),
        ),
      ],
    );
  }

  // 產生多邊形
  Widget _generatePolygon(
    LatLng pointA,
    LatLng pointB,
    LatLng pointC,
  ) {
    return PolygonLayer(
      polygons: [
        Polygon(
          points: [
            pointA,
            pointB,
            pointC,
          ],
          color: Colors.green.withOpacity(0.22),
        ),
      ],
    );
  }

  // 取得某節點的資料
  Map<String, dynamic>? _getNodeData(int nodeId) {
    return _mapCoordinatesData['items']
        .firstWhere((element) => element['id'] == nodeId, orElse: () => null);
  }

  // 取得某節點的位置
  LatLng? _getNodePosition(int nodeId) {
    Map<String, dynamic>? node = _getNodeData(nodeId);
    if (node == null) {
      return null;
    }
    Map<String, dynamic>? nodePosition = node['positions'][0];
    if (nodePosition == null) {
      return null;
    }
    return LatLng(double.tryParse(nodePosition['latitude'].toString()) ?? 0.0,
        double.tryParse(nodePosition['longitude'].toString()) ?? 0.0);
  }

  // 顯示節點基本資訊
  Future<void> _showNodeInfo(int nodeId) async {
    Map<String, dynamic>? node = _getNodeData(nodeId);
    if (node == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.current.MapNodeNotFound)),
      );
      return;
    }

    // 初始化一些變數
    Map<String, dynamic>? nodeInfo = node['info'];
    List<Map<String, dynamic>> nodePositions = (node['positions'] as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();

    String deviceImagePath = _meshtasticDeviceImageFiles.firstWhere(
        (file) => file.endsWith("${nodeInfo?['hardware']}.jpg"),
        orElse: () => 'assets/images/meshtastic/device/0.default.png');

    var textSizeGroup1 = AutoSizeGroup();
    var textSizeGroup2 = AutoSizeGroup();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // 寬度為螢幕寬度的 80%
            height: MediaQuery.of(context).size.height * 0.5, // 高度為螢幕高度的 50%
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(
                      "${nodeInfo?['longName']}\n(${nodeInfo?['shortName']})",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: Text(
                      "#${node['id']} (${node['idHex']})",
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Divider(),
                  // 顯示裝置圖片
                  Center(
                    child: SizedBox(
                      height: 160.0,
                      child: Image.asset(deviceImagePath),
                    ),
                  ),
                  const Divider(),
                  // 顯示裝置資訊
                  Center(
                    child: Text(
                      S.current.NodeInformation,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Colors.grey[500]!,
                        width: 1,
                      ),
                    ),
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: AutoSizeText('#', group: textSizeGroup2),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: AutoSizeText('#', group: textSizeGroup2),
                            ),
                          ),
                        ],
                      ),
                      if (nodeInfo?['hardware'] != null) ...[
                        TableRow(
                          children: [
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText('📟${S.current.Hardware}',
                                    group: textSizeGroup2),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(nodeInfo?['hardware'],
                                    group: textSizeGroup2),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (nodeInfo?['firmware'] != null) ...[
                        TableRow(
                          children: [
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText('🔧${S.current.Firmware}',
                                    group: textSizeGroup2),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(nodeInfo?['firmware'],
                                    group: textSizeGroup2),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (nodeInfo?['role'] != null) ...[
                        TableRow(
                          children: [
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText('🎭${S.current.Role}',
                                    group: textSizeGroup2),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(nodeInfo?['role'],
                                    group: textSizeGroup2),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (nodeInfo?['isLicensed'] != null) ...[
                        TableRow(
                          children: [
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText('📜${S.current.IsLicensed}',
                                    group: textSizeGroup2),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(
                                    "${nodeInfo?['isLicensed']}",
                                    group: textSizeGroup2),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (nodeInfo?['loraRegion'] != null) ...[
                        TableRow(
                          children: [
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText('🌍${S.current.LoraRegion}',
                                    group: textSizeGroup2),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(nodeInfo?['loraRegion'],
                                    group: textSizeGroup2),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (nodeInfo?['loraModemPreset'] != null) ...[
                        TableRow(
                          children: [
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(
                                    '📡${S.current.LoraModemPreset}',
                                    group: textSizeGroup2),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(
                                    nodeInfo?['loraModemPreset'],
                                    group: textSizeGroup2),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (nodeInfo?['hasDefaultChannel'] != null) ...[
                        TableRow(
                          children: [
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(
                                    '📻${S.current.HasDefaultChannel}',
                                    group: textSizeGroup2),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(
                                    "${nodeInfo?['hasDefaultChannel']}",
                                    group: textSizeGroup2),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (nodeInfo?['numOnlineLocalNodes'] != null) ...[
                        TableRow(
                          children: [
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(
                                    '🕸️${S.current.NumOnlineLocalNodes}',
                                    group: textSizeGroup2),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(
                                    "${nodeInfo?['numOnlineLocalNodes']}",
                                    group: textSizeGroup2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const Divider(),
                  // 顯示裝置定位資訊
                  Center(
                    child: Text(
                      S.current.LocationInformation,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (nodePositions[0]['altitude'] != null) ...[
                    Text(
                        "🏔️${S.current.Altitude}: ${nodePositions[0]['altitude'].toInt()} m"),
                  ],
                  if (nodePositions[0]['satsInView'] != null) ...[
                    Text(
                        "🛰️${S.current.SatsInView}: ${nodePositions[0]['satsInView']}"),
                  ],
                  if (nodePositions[0]['precisionInMeters'] != 0) ...[
                    Text(
                        "❓${S.current.LocationPrecision}: ±${nodePositions[0]['precisionInMeters']} m"),
                  ],
                  Table(
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Colors.grey[500]!,
                        width: 1,
                      ),
                    ),
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: AutoSizeText(
                                S.current.Via,
                                group: textSizeGroup1,
                                maxFontSize: 10,
                                minFontSize: 8,
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: AutoSizeText(S.current.RootTopic,
                                  group: textSizeGroup1),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: AutoSizeText(S.current.Channel,
                                  group: textSizeGroup1),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: AutoSizeText(S.current.UpdateAt,
                                  group: textSizeGroup1),
                            ),
                          ),
                        ],
                      ),
                      // 建立 Node 位置資訊列
                      for (var x in nodePositions)
                        TableRow(
                          children: [
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  children: [
                                    if (x['viaId'] == x['nodeId']) ...[
                                      AutoSizeText('self',
                                          group: textSizeGroup1),
                                    ] else ...[
                                      Column(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                _longPressNodeMarker(
                                                    x['viaId']);
                                              },
                                              icon: const Icon(
                                                Icons.location_pin,
                                                size: 16,
                                              )),
                                          AutoSizeText(x['viaIdHex'],
                                              group: textSizeGroup1),
                                        ],
                                      )
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            /*
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(
                                    x['viaId'] == x['nodeId']
                                        ? 'self'
                                        : x['viaIdHex'],
                                    group: textSizeGroup1),
                              ),
                            ),
                            */
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(x['rootTopic'],
                                    group: textSizeGroup1),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(x['channel'],
                                    group: textSizeGroup1),
                              ),
                            ),
                            TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AutoSizeText(
                                    AppUtils.timeAgo(
                                        DateTime.parse(x['updateAt'])),
                                    group: textSizeGroup1),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(S.current.IUnderstand),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 檢查是否在目前視野內
  bool _isInCurrentMapVision(LatLng point) {
    // 取得目前畫面上的範圍
    LatLngBounds bounds = _mapController.camera.visibleBounds;
    return bounds.contains(point);
  }

  Future<Widget> _darkModeContainerIfEnabled(Widget child) async {
    if (!_appSettingMap.darkMode) return child;
    if (!mounted) return child;
    return darkModeTilesContainerBuilder(context, child);
  }
}
