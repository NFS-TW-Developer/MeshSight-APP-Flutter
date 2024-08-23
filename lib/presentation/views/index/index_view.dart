import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../localization/generated/l10n.dart';
import '../../../router/app_router.gr.dart';
import '../base_view.dart';
import 'index_view_model.dart';

@RoutePage()
class IndexView extends StatelessWidget {
  const IndexView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      modelProvider: () => IndexViewModel(),
      onModelReady: (model) => model.initViewModel(context),
      builder: (context, model, child) {
        return AutoTabsScaffold(
            routes: const [
              IndexMapRoute(),
              IndexSettingRoute(),
            ],
            bottomNavigationBuilder: (_, tabsRouter) {
              return BottomNavigationBar(
                currentIndex: tabsRouter.activeIndex,
                onTap: tabsRouter.setActiveIndex,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.map),
                    label: S.current.Map,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings),
                    label: S.current.Setting,
                  ),
                ],
              );
            });
      },
    );
  }
}
