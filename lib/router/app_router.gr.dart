// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:meshsightapp/presentation/views/index/index_view.dart' as _i3;
import 'package:meshsightapp/presentation/views/index_map/index_map_view.dart'
    as _i1;
import 'package:meshsightapp/presentation/views/index_setting/index_setting_view.dart'
    as _i2;

abstract class $AppRouter extends _i4.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i4.PageFactory> pagesMap = {
    IndexMapRoute.name: (routeData) {
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.IndexMapView(),
      );
    },
    IndexSettingRoute.name: (routeData) {
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.IndexSettingView(),
      );
    },
    IndexRoute.name: (routeData) {
      return _i4.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.IndexView(),
      );
    },
  };
}

/// generated route for
/// [_i1.IndexMapView]
class IndexMapRoute extends _i4.PageRouteInfo<void> {
  const IndexMapRoute({List<_i4.PageRouteInfo>? children})
      : super(
          IndexMapRoute.name,
          initialChildren: children,
        );

  static const String name = 'IndexMapRoute';

  static const _i4.PageInfo<void> page = _i4.PageInfo<void>(name);
}

/// generated route for
/// [_i2.IndexSettingView]
class IndexSettingRoute extends _i4.PageRouteInfo<void> {
  const IndexSettingRoute({List<_i4.PageRouteInfo>? children})
      : super(
          IndexSettingRoute.name,
          initialChildren: children,
        );

  static const String name = 'IndexSettingRoute';

  static const _i4.PageInfo<void> page = _i4.PageInfo<void>(name);
}

/// generated route for
/// [_i3.IndexView]
class IndexRoute extends _i4.PageRouteInfo<void> {
  const IndexRoute({List<_i4.PageRouteInfo>? children})
      : super(
          IndexRoute.name,
          initialChildren: children,
        );

  static const String name = 'IndexRoute';

  static const _i4.PageInfo<void> page = _i4.PageInfo<void>(name);
}
