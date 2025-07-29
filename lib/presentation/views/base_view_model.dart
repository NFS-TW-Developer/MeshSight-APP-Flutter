import 'package:flutter/material.dart';

import '../../core/app_core.dart';
import '../../core/models/app_status_message.dart';
import '../../core/services/localization_service.dart';
import '../../localization/generated/l10n.dart';
import 'global_view_model.dart';

class BaseViewModel extends ChangeNotifier {
  final GlobalViewModel globalViewModel = appLocator<GlobalViewModel>();

  ValueNotifier<bool> _busy = ValueNotifier<bool>(false); // 是否忙碌中
  ValueNotifier<bool> get busy => _busy;

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
    _busy = ValueNotifier<bool>(value);
    notifyListeners();
  }

  void initViewModel(BuildContext context) {
    globalViewModel.initGlobalViewModel();
    setBusy(true);
    _context = context;
    // 初始化時清除 SnackBar
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ScaffoldMessenger.of(context).clearSnackBars(),
    );
    // 初始化時重新載入語言
    LocalizationService localizationService = appLocator<LocalizationService>();
    localizationService.loadAppLocale();
    setBusy(false);
  }

  // 顯示ScaffoldMessenger
  void showSnackBar(
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (disposed) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), action: action, duration: duration),
    );
  }

  // 顯示 StatusSnackBar
  void showStatusSnackBar(AppStatusMessage response) {
    String? message = response.message;
    if (response.status) {
      message = '${S.current.Successful}${message != null ? ': $message' : ''}';
    } else {
      message = '${S.current.Failed}${message != null ? ': $message' : ''}';
    }
    showSnackBar(message);
  }
}
