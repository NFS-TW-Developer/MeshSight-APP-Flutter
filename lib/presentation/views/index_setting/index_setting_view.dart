import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:meshsightapp/router/app_router.gr.dart';

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
              BaseExpansionTile(
                title: S.current.Language,
                children: [
                  RadioListTile<Locale>(
                    title: const Text('English'),
                    value: const Locale('en'),
                    groupValue: model.currentLocale,
                    onChanged: (value) {
                      model.setCurrentLocale(value);
                    },
                  ),
                  RadioListTile<Locale>(
                    title: const Text('繁體中文(台灣)'),
                    value: const Locale.fromSubtags(
                      languageCode: 'zh',
                      scriptCode: 'Hant',
                      countryCode: 'TW',
                    ),
                    groupValue: model.currentLocale,
                    onChanged: (value) {
                      model.setCurrentLocale(value);
                    },
                  ),
                ],
              ),
              BaseExpansionTile(
                title: S.current.ApiUrl,
                children: [
                  Text(model.appSettingApi.apiUrl ?? ''),
                  BaseListTile(
                    title: S.current.Reset,
                    onTapFunction: () async {
                      await model.resetAppSettingApi();
                      AutoRouter.of(context).replaceAll([const IndexRoute()]);
                    },
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
              BaseListTitle(title: S.current.Map),
              BaseExpansionTile(
                title: S.current.MapTileRegion,
                children: List.generate(
                  model.mapTileRegionList.length,
                  (index) {
                    String tileName = model.mapTileRegionList[index];
                    return RadioListTile<String>(
                      title: Text(tileName),
                      value: model.mapTileRegionList[index],
                      groupValue: model.appSettingMap.tileRegion,
                      onChanged: (value) {
                        model.setAppSettingMap(
                          model.appSettingMap.copyWith(
                              tileRegion: value, tileProvider: 'default'),
                        );
                      },
                    );
                  },
                ),
              ),
              BaseExpansionTile(
                title: S.current.MapTileProvider,
                children: List.generate(
                  model.mapTileProviderList.length,
                  (index) {
                    String? tileName = GlobalConfiguration().getDeepValue(
                        "map:tile:${model.appSettingMap.tileRegion}:${model.mapTileProviderList[index]}:name");
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
                  },
                ),
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
                    max: 36,
                    divisions: 35,
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
                    value: model.appSettingMap.nodeNeighborMaxAgeInHours
                        .toDouble(),
                    min: 1,
                    max: 6,
                    divisions: 5,
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
                          color: (model.appSettingMap.nodeMarkSize == 40)
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
                          color: (model.appSettingMap.nodeMarkSize == 64)
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
                          color: (model.appSettingMap.nodeMarkSize == 88)
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
                      model.setAppSettingMap(model.appSettingMap.copyWith(
                        nodeMarkSize: value.toInt(),
                      ));
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
            ],
          ),
        );
      },
    );
  }
}
