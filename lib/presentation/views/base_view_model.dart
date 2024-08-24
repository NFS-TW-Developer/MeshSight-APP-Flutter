import 'package:flutter/material.dart';

import '../../core/app_core.dart';
import '../../core/services/localization_service.dart';
import 'global_view_model.dart';

class BaseViewModel extends ChangeNotifier {
  final GlobalViewModel globalViewModel = appLocator<GlobalViewModel>();

  bool _busy = false; // 是否忙碌中
  bool get busy => _busy;

  bool _disposed = false; // 是否已經被釋放
  bool get disposed => _disposed;

  late BuildContext _context; // 目前頁面
  BuildContext get context => _context;

  @override
  void dispose() {
    super.dispose();
    _disposed = true;
  }

  @override
  void notifyListeners() {
    if (!disposed) super.notifyListeners();
  }

  void setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  void initViewModel(BuildContext context) {
    globalViewModel.initGlobalViewModel();
    setBusy(true);
    _context = context;
    // 初始化時重新載入語言
    LocalizationService localizationService = appLocator<LocalizationService>();
    localizationService.loadAppLocale();
    setBusy(false);
  }

  // 顯示ScaffoldMessenger
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
