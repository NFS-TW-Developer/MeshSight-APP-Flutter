import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;

  const BaseAppBar(
      {super.key,
      required this.appBar,
      this.title,
      this.actions,
      this.leading});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      // 如果有提供 leading，則使用提供的 leading，否則使用路由判斷
      leading: (leading != null)
          ? leading
          : (AutoRouter.of(context).canPop())
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    AutoRouter.of(context).maybePop();
                  },
                )
              : const SizedBox.shrink(),
      title: (title != null)
          ? Text(
              title!,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900),
            )
          : SizedBox(width: 200, child: Image.asset('assets/images/logo.png')),
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}
