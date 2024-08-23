import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';

import '../../../localization/generated/l10n.dart';
import '../../widgets/base_expansion_tile.dart';
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
                      model.currentLocaleRadioOnChanged(value);
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
                      model.currentLocaleRadioOnChanged(value);
                    },
                  ),
                ],
              ),
              BaseExpansionTile(
                title: S.current.ApiRegion,
                children: [
                  RadioListTile<String>(
                    title: const Text('Global'),
                    value: "global",
                    groupValue: model.apiRegion,
                    onChanged: (value) {
                      model.apiRegionRadioOnChanged(value);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('台灣'),
                    value: "tw",
                    groupValue: model.apiRegion,
                    onChanged: (value) {
                      model.apiRegionRadioOnChanged(value);
                    },
                  ),
                ],
              ),
              BaseListTitle(title: S.current.Map),
              BaseExpansionTile(
                title: S.current.MapTile,
                children: List.generate(
                  model.mapTileList.length,
                  (index) {
                    String? tileName = GlobalConfiguration().getDeepValue(
                        "map:tile:${model.apiRegion}:${model.mapTileList[index]}:name");
                    tileName ??= 'Unknown';
                    return RadioListTile<String>(
                      title: Text(tileName),
                      value: model.mapTileList[index],
                      groupValue: model.mapTile,
                      onChanged: (value) {
                        model.mapTileRadioOnChanged(value);
                      },
                    );
                  },
                ),
              ),
              BaseSwitchListTile(
                title: S.current.MapDarkMode,
                value: model.mapDarkMode,
                onChangedFunction: (value) {
                  model.mapDarkModeSwitchOnChanged(value);
                },
              ),
              BaseSwitchListTile(
                title: S.current.MapScalebar,
                value: model.mapScalebarVisibility,
                onChangedFunction: (value) {
                  model.mapScalebarVisibilitySwitchOnChanged(value);
                },
              ),
              BaseSwitchListTile(
                title: S.current.MapFunctionButtonMini,
                value: model.mapFunctionButtonMiniVisibility,
                onChangedFunction: (value) {
                  model.mapFunctionButtonMiniVisibilitySwitchOnChanged(value);
                },
              ),
              BaseSwitchListTile(
                title: S.current.MapNodeLine,
                value: model.mapNodeLineVisibility,
                onChangedFunction: (value) {
                  model.mapNodeLineVisibilitySwitchOnChanged(value);
                },
              ),
              BaseSwitchListTile(
                title: S.current.MapNodeCover,
                value: model.mapNodeCoverVisibility,
                onChangedFunction: (value) {
                  model.mapNodeCoverVisibilitySwitchOnChanged(value);
                },
              ),
              BaseExpansionTile(
                title: S.current.MapNodeMaxAge,
                children: [
                  RadioListTile<int>(
                    title: Text('24 ${S.current.Hour}'),
                    value: 24,
                    groupValue: model.mapNodeMaxAgeInHours,
                    onChanged: (value) {
                      model.mapNodeMaxAgeInHoursRadioOnChanged(value);
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('3 ${S.current.Day}'),
                    value: 72,
                    groupValue: model.mapNodeMaxAgeInHours,
                    onChanged: (value) {
                      model.mapNodeMaxAgeInHoursRadioOnChanged(value);
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('5 ${S.current.Day}'),
                    value: 120,
                    groupValue: model.mapNodeMaxAgeInHours,
                    onChanged: (value) {
                      model.mapNodeMaxAgeInHoursRadioOnChanged(value);
                    },
                  ),
                  RadioListTile<int>(
                    title: Text('7 ${S.current.Day}'),
                    value: 168,
                    groupValue: model.mapNodeMaxAgeInHours,
                    onChanged: (value) {
                      model.mapNodeMaxAgeInHoursRadioOnChanged(value);
                    },
                  ),
                ],
              ),
              BaseExpansionTile(
                title: S.current.MapNodeNeighborMaxAge,
                children: [
                  Slider(
                    value: model.mapNodeNeighborMaxAgeInHours.toDouble(),
                    min: 1,
                    max: 6,
                    divisions: 5,
                    label:
                        "${model.mapNodeNeighborMaxAgeInHours.toString()} ${S.current.Hour}",
                    onChanged: (value) {
                      model.mapNodeNeighborMaxAgeInHoursSliderOnChanged(
                          value.toInt());
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
                          color: (model.mapNodeMarkSize == 40)
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
                          color: (model.mapNodeMarkSize == 64)
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
                          color: (model.mapNodeMarkSize == 88)
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
                    value: model.mapNodeMarkSize.toDouble(),
                    min: 40,
                    max: 88,
                    divisions: 2,
                    // label: model.mapNodeMarkSize.toString(),
                    onChanged: (value) {
                      model.mapNodeMarkSizeSliderOnChanged(value.toInt());
                    },
                  ),
                ],
              ),
              BaseSwitchListTile(
                title: S.current.MapNodeMarkName,
                value: model.mapNodeMarkNameVisibility,
                onChangedFunction: (value) {
                  model.mapNodeMarkNameVisibilitySwitchOnChanged(value);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
