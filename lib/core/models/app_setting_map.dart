import 'package:meshsightapp/core/models/map_vision.dart';

class AppSettingMap {
  final String tileRegion;
  final String tileProvider;
  final bool darkMode;
  final bool scalebarVisible;
  final bool miniButton;
  final bool lineVisible;
  final bool coverVisible;
  final int nodeMaxAgeInHours;
  final int nodeNeighborMaxAgeInHours;
  final int nodeMarkSize;
  final bool nodeMarkNameVisible;
  final List<String> nodeModemPresetList;
  final MapVision mapVision;

  AppSettingMap({
    this.tileRegion = 'Global',
    this.tileProvider = 'default',
    this.darkMode = false,
    this.scalebarVisible = true,
    this.miniButton = false,
    this.lineVisible = false,
    this.coverVisible = false,
    this.nodeMaxAgeInHours = 24,
    this.nodeNeighborMaxAgeInHours = 1,
    this.nodeMarkSize = 64,
    this.nodeMarkNameVisible = true,
    this.nodeModemPresetList = const [
      "UNKNOWN",
      "LONG_SLOW",
      "LONG_MOD",
      "LONG_FAST",
      "MEDIUM_SLOW",
      "MEDIUM_FAST",
      "SHORT_SLOW",
      "SHORT_FAST",
      "SHORT_TURBO",
    ],
    this.mapVision = const MapVision(),
  });

  AppSettingMap copyWith({
    String? tileRegion,
    String? tileProvider,
    bool? darkMode,
    bool? scalebarVisible,
    bool? miniButton,
    bool? lineVisible,
    bool? coverVisible,
    int? nodeMaxAgeInHours,
    int? nodeNeighborMaxAgeInHours,
    int? nodeMarkSize,
    bool? nodeMarkNameVisible,
    List<String>? nodeModemPresetList,
    MapVision? mapVision,
  }) {
    return AppSettingMap(
      tileRegion: tileRegion ?? this.tileRegion,
      tileProvider: tileProvider ?? this.tileProvider,
      darkMode: darkMode ?? this.darkMode,
      scalebarVisible: scalebarVisible ?? this.scalebarVisible,
      miniButton: miniButton ?? this.miniButton,
      lineVisible: lineVisible ?? this.lineVisible,
      coverVisible: coverVisible ?? this.coverVisible,
      nodeMaxAgeInHours: nodeMaxAgeInHours ?? this.nodeMaxAgeInHours,
      nodeNeighborMaxAgeInHours:
          nodeNeighborMaxAgeInHours ?? this.nodeNeighborMaxAgeInHours,
      nodeMarkSize: nodeMarkSize ?? this.nodeMarkSize,
      nodeMarkNameVisible: nodeMarkNameVisible ?? this.nodeMarkNameVisible,
      nodeModemPresetList: nodeModemPresetList ?? this.nodeModemPresetList,
      mapVision: mapVision ?? this.mapVision,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tileRegion': tileRegion,
      'tileProvider': tileProvider,
      'darkMode': darkMode,
      'scalebarVisible': scalebarVisible,
      'miniButton': miniButton,
      'lineVisible': lineVisible,
      'coverVisible': coverVisible,
      'nodeMaxAgeInHours': nodeMaxAgeInHours,
      'nodeNeighborMaxAgeInHours': nodeNeighborMaxAgeInHours,
      'nodeMarkSize': nodeMarkSize,
      'nodeMarkNameVisible': nodeMarkNameVisible,
      'nodeModemPresetList': nodeModemPresetList,
      'mapVision': mapVision.toMap(),
    };
  }

  static AppSettingMap? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    return AppSettingMap(
      tileRegion: map['tileRegion'],
      tileProvider: map['tileProvider'],
      darkMode: map['darkMode'],
      scalebarVisible: map['scalebarVisible'],
      miniButton: map['miniButton'],
      lineVisible: map['lineVisible'],
      coverVisible: map['coverVisible'],
      nodeMaxAgeInHours: map['nodeMaxAgeInHours'],
      nodeNeighborMaxAgeInHours: map['nodeNeighborMaxAgeInHours'],
      nodeMarkSize: map['nodeMarkSize'],
      nodeMarkNameVisible: map['nodeMarkNameVisible'],
      nodeModemPresetList: List<String>.from(map['nodeModemPresetList']),
      mapVision: MapVision.fromMap(map['mapVision']) ?? const MapVision(),
    );
  }
}
