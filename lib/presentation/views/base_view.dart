import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/*
所有 view 都要 return 此類。
*/
class BaseView<T extends ChangeNotifier> extends StatefulWidget {
  final Widget Function(BuildContext context, T model, Widget? child) builder;
  final T Function() modelProvider;
  final Function(T)? onModelReady;
  final bool keepAlive;

  const BaseView({
    super.key,
    required this.builder,
    required this.modelProvider,
    this.onModelReady,
    this.keepAlive = false,
  });

  @override
  BaseViewState<T> createState() => BaseViewState<T>();
}

class BaseViewState<T extends ChangeNotifier> extends State<BaseView<T>>
    with AutomaticKeepAliveClientMixin<BaseView<T>> {
  late T model;

  @override
  void initState() {
    super.initState();
    model = widget.modelProvider();

    if (widget.onModelReady != null) {
      widget.onModelReady!(model);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 重要：當使用 AutomaticKeepAliveClientMixin 時，必須調用 super.build
    super.build(context);
    return SafeArea(
      child: ChangeNotifierProvider<T>(
        create: (context) => model,
        child: Consumer<T>(
          builder: widget.builder,
        ),
      ),
    );
  }

  // AutomaticKeepAliveClientMixin 需要實現的方法
  @override
  bool get wantKeepAlive => widget.keepAlive;
}
