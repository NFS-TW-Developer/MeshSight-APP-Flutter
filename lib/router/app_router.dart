import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';
import 'guard/auth_guard.dart';

/*
  這是一個專門處理 Router 的地方
  這裡會有一些基本的路由操作
*/
@AutoRouterConfig(replaceInRouteName: 'View,Route')
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/welcome',
          page: WelcomeRoute.page,
        ),
        AutoRoute(
          path: '/index',
          initial: true,
          page: IndexRoute.page,
          guards: [AuthGuard()],
          children: [
            AutoRoute(
              path: 'map', page: IndexMapRoute.page,
              maintainState: false, // 當路由切換時保持狀態
            ),
            AutoRoute(
              path: 'analysis', page: IndexAnalysisRoute.page,
              maintainState: false, // 當路由切換時保持狀態
            ),
            AutoRoute(
              path: 'setting', page: IndexSettingRoute.page,
              maintainState: false, // 當路由切換時保持狀態
            ),
          ],
        ),
      ];
}
