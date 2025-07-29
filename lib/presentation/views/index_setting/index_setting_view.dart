import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:meshsightapp/core/models/app_setting_api.dart';
import 'package:meshsightapp/core/utils/app_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_core.dart';
import '../../../core/services/localization_service.dart';
import '../../../localization/generated/l10n.dart';
import '../../widgets/base_expansion_tile.dart';
import '../../widgets/base_list_tile.dart';
import '../../widgets/base_list_title.dart';
import '../../widgets/base_scaffold.dart';
import '../../widgets/base_switch_list_tile.dart';
import '../base_view.dart';
import 'index_setting_view_model.dart';

@RoutePage()
class IndexSettingView extends StatelessWidget {
  const IndexSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      modelProvider: () => IndexSettingViewModel(),
      onModelReady: (model) => model.initViewModel(context),
      builder: (context, model, child) {
        return BaseScaffold(
          appBarTitle: S.current.Setting,
          body: ListView(
            children: [
              BaseListTitle(title: S.current.Application),
              // 語言
              BaseExpansionTile(
                title: S.current.Language,
                children: List.generate(
                  appLocator<LocalizationService>()
                      .getSupportedLocales()
                      .length,
                  (index) {
                    Locale locale =
                        appLocator<LocalizationService>()
                            .getSupportedLocales()[index];
                    return RadioListTile<Locale>(
                      title: Text(
                        appLocator<LocalizationService>().getLanguageName(
                          locale,
                        ),
                      ),
                      value: locale,
                      groupValue: model.currentLocale,
                      onChanged: (value) {
                        model.setCurrentLocale(value);
                      },
                    );
                  },
                ),
              ),
              // API
              BaseExpansionTile(
                title:
                    model.appSettingApi.apiServer == 'custom'
                        ? "${S.current.ApiUrl} (${model.appSettingApi.apiUrl})"
                        : S.current.ApiUrl,
                children: List.generate(
                  GlobalConfiguration()
                      .getDeepValue('api:server')
                      .keys
                      .toList()
                      .length,
                  (index) {
                    String apiServerKey =
                        GlobalConfiguration()
                            .getDeepValue('api:server')
                            .keys
                            .toList()[index];
                    return RadioListTile<String>(
                      title: Text(
                        GlobalConfiguration().getDeepValue(
                          'api:server:$apiServerKey:name',
                        ),
                      ),
                      value: apiServerKey,
                      groupValue: model.appSettingApi.apiServer,
                      onChanged: (value) {
                        if (value == null || value.isEmpty) return;
                        if (value == 'custom') {
                          // 自訂 API，顯示輸入對話框
                          model.showInputDialog(
                            context: context,
                            title: S.current.ApiUrl,
                            hintText: S.current.ApiUrl,
                            textController: model.textController,
                            validateFunction: AppUtils.isValidUrl,
                            onConfirmFunction: () {
                              model.setAppSettingApi(
                                AppSettingApi(
                                  apiServer: 'custom',
                                  apiUrl: model.textController.text,
                                ),
                              );
                            },
                          );
                        } else {
                          model.setAppSettingApi(
                            AppSettingApi(
                              apiServer: value,
                              apiUrl: GlobalConfiguration().getDeepValue(
                                'api:server:$value:url',
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              // 版本
              BaseListTile(
                title:
                    "${model.globalViewModel.appInfo.version} (${model.globalViewModel.appInfo.buildNumber})",
                onTapFunction: () {},
              ),
              BaseListTitle(title: S.current.Map),
              BaseExpansionTile(
                title: S.current.MapTileRegion,
                children: List.generate(model.mapTileRegionList.length, (
                  index,
                ) {
                  String tileName = model.mapTileRegionList[index];
                  return RadioListTile<String>(
                    title: Text(tileName),
                    value: model.mapTileRegionList[index],
                    groupValue: model.appSettingMap.tileRegion,
                    onChanged: (value) {
                      model.setAppSettingMap(
                        model.appSettingMap.copyWith(
                          tileRegion: value,
                          tileProvider: 'default',
                        ),
                      );
                    },
                  );
                }),
              ),
              BaseExpansionTile(
                title: S.current.MapTileProvider,
                children: List.generate(model.mapTileProviderList.length, (
                  index,
                ) {
                  String? tileName = GlobalConfiguration().getDeepValue(
                    "map:tile:${model.appSettingMap.tileRegion}:${model.mapTileProviderList[index]}:name",
                  );
                  tileName ??= 'Unknown';
                  return RadioListTile<String>(
                    title: Text(tileName),
                    value: model.mapTileProviderList[index],
                    groupValue: model.appSettingMap.tileProvider,
                    onChanged: (value) {
                      model.setAppSettingMap(
                        model.appSettingMap.copyWith(tileProvider: value),
                      );
                    },
                  );
                }),
              ),
              BaseSwitchListTile(
                title: S.current.MapDarkMode,
                value: model.appSettingMap.darkMode,
                onChangedFunction: (value) {
                  model.setAppSettingMap(
                    model.appSettingMap.copyWith(darkMode: value),
                  );
                },
              ),
              BaseSwitchListTile(
                title: S.current.MapScalebar,
                value: model.appSettingMap.scalebarVisible,
                onChangedFunction: (value) {
                  model.setAppSettingMap(
                    model.appSettingMap.copyWith(scalebarVisible: value),
                  );
                },
              ),
              BaseSwitchListTile(
                title: S.current.MapFunctionButtonMini,
                value: model.appSettingMap.miniButton,
                onChangedFunction: (value) {
                  model.setAppSettingMap(
                    model.appSettingMap.copyWith(miniButton: value),
                  );
                },
              ),
              BaseSwitchListTile(
                title: S.current.MapNodeLine,
                value: model.appSettingMap.lineVisible,
                onChangedFunction: (value) {
                  model.setAppSettingMap(
                    model.appSettingMap.copyWith(lineVisible: value),
                  );
                },
              ),
              BaseSwitchListTile(
                title: S.current.MapNodeCover,
                value: model.appSettingMap.coverVisible,
                onChangedFunction: (value) {
                  model.setAppSettingMap(
                    model.appSettingMap.copyWith(coverVisible: value),
                  );
                },
              ),
              BaseExpansionTile(
                title: S.current.MapNodeMaxAge,
                children: [
                  Slider(
                    value: model.appSettingMap.nodeMaxAgeInHours.toDouble(),
                    min: 1,
                    max:
                        model
                            .apiAppSettingData['meshtasticPositionMaxQueryPeriod']
                            ?.toDouble() ??
                        48,
                    divisions:
                        model
                            .apiAppSettingData['meshtasticPositionMaxQueryPeriod']
                            ?.toInt() ??
                        48,
                    label:
                        "${model.appSettingMap.nodeMaxAgeInHours.toString()} ${S.current.Hour}",
                    onChanged: (value) {
                      model.setAppSettingMap(
                        model.appSettingMap.copyWith(
                          nodeMaxAgeInHours: value.toInt(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              BaseExpansionTile(
                title: S.current.MapNodeNeighborMaxAge,
                children: [
                  Slider(
                    value:
                        model.appSettingMap.nodeNeighborMaxAgeInHours
                            .toDouble(),
                    min: 1,
                    max:
                        model
                            .apiAppSettingData['meshtasticNeighborinfoMaxQueryPeriod']
                            ?.toDouble() ??
                        48,
                    divisions:
                        model
                            .apiAppSettingData['meshtasticNeighborinfoMaxQueryPeriod']
                            ?.toInt() ??
                        48,
                    label:
                        "${model.appSettingMap.nodeNeighborMaxAgeInHours.toString()} ${S.current.Hour}",
                    onChanged: (value) {
                      model.setAppSettingMap(
                        model.appSettingMap.copyWith(
                          nodeNeighborMaxAgeInHours: value.toInt(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              BaseExpansionTile(
                title: S.current.MapNodeMarkSize,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 40 / 2,
                          color:
                              (model.appSettingMap.nodeMarkSize == 40)
                                  ? Colors.green
                                  : Colors.grey,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.location_on,
                          size: 64 / 2,
                          color:
                              (model.appSettingMap.nodeMarkSize == 64)
                                  ? Colors.green
                                  : Colors.grey,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.location_on,
                          size: 88 / 2,
                          color:
                              (model.appSettingMap.nodeMarkSize == 88)
                                  ? Colors.green
                                  : Colors.grey,
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
                  Slider(
                    value: model.appSettingMap.nodeMarkSize.toDouble(),
                    min: 40,
                    max: 88,
                    divisions: 2,
                    // label: model.mapNodeMarkSize.toString(),
                    onChanged: (value) {
                      model.setAppSettingMap(
                        model.appSettingMap.copyWith(
                          nodeMarkSize: value.toInt(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              BaseSwitchListTile(
                title: S.current.MapNodeMarkName,
                value: model.appSettingMap.nodeMarkNameVisible,
                onChangedFunction: (value) {
                  model.setAppSettingMap(
                    model.appSettingMap.copyWith(nodeMarkNameVisible: value),
                  );
                },
              ),
              // 節點 Modem Preset
              BaseExpansionTile(
                title: S.current.NodeModemPreset,
                children: List.generate(model.nodeModemPresetList.length, (
                  index,
                ) {
                  final preset = model.nodeModemPresetList[index];
                  final selectedPresets =
                      model.appSettingMap.nodeModemPresetList;
                  return CheckboxListTile(
                    title: Text(preset),
                    value: selectedPresets.contains(preset),
                    onChanged: (checked) {
                      List<String> updatedList = List.from(selectedPresets);
                      if (checked == true) {
                        updatedList.add(preset);
                      } else {
                        updatedList.remove(preset);
                      }
                      model.setAppSettingMap(
                        model.appSettingMap.copyWith(
                          nodeModemPresetList: updatedList,
                        ),
                      );
                    },
                  );
                }),
              ),
              // 外部連結
              BaseListTitle(title: S.current.ExternalLink),
              BaseListTile(
                title: "Meshtastic Official Website",
                trailing: const Icon(Icons.open_in_new),
                onTapFunction: () {
                  launchUrl(Uri.parse('https://meshtastic.org/'));
                },
              ),
              BaseListTile(
                title: "Meshtastic Official Docs",
                trailing: const Icon(Icons.open_in_new),
                onTapFunction: () {
                  launchUrl(
                    Uri.parse('https://meshtastic.org/docs/introduction/'),
                  );
                },
              ),
              BaseListTile(
                title: "MeshSight on GitHub",
                trailing: const Icon(Icons.open_in_new),
                onTapFunction: () {
                  launchUrl(
                    Uri.parse('https://github.com/edwinyoo44/MeshSight/'),
                  );
                },
              ),
              BaseListTile(
                title: "MeshSight-APP-Flutter on GitHub",
                trailing: const Icon(Icons.open_in_new),
                onTapFunction: () {
                  launchUrl(
                    Uri.parse(
                      'https://github.com/edwinyoo44/MeshSight-APP-Flutter/',
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
