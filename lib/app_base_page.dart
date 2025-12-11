import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppBackArrowStyle {
  // 箭头
  styleGoBack,
  // 叉 ×
  styleClose,
}

enum AppStatusBarStyle {
  light,
  dark,
}

abstract mixin class AppBaseScreen {
  // 页面的title
  String pageTitle = '';

  Widget? titleWidget;

  bool navigatorBottomLine = false;

  List<Widget>? navigatorRightWidget;

  // 背景色
  Color backgroundColor = AppTheme.scaffoldBackground;

  Color appBarBackgroundColor = AppTheme.appBarBackground;

  // 是否隐藏appBar
  bool hiddeAppBar = false;

  bool extendBodyBehindAppBar = false;

  // 返回按钮的样式
  AppBackArrowStyle backArrowStyle = AppBackArrowStyle.styleGoBack;

  AppStatusBarStyle statusBarStyle = AppStatusBarStyle.light;

  // 返回按钮事件
  void Function()? onBackClick;

  // 自定义app bar
  PreferredSizeWidget? appBar;
  
  PreferredSizeWidget? defaultAppBar() {
    if (hiddeAppBar) return null;
    return AppBar(
      backgroundColor: appBarBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      bottom: navigatorBottomLine
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color: AppTheme.dividerColor,
                height: 1.0,
              ),
            )
          : null,
      centerTitle: true,
      title: titleWidget ??
          Text(
            pageTitle,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
      leading: IconButton(
        icon: Icon(
          backArrowStyle == AppBackArrowStyle.styleGoBack
              ? Icons.arrow_back_ios_new_rounded
              : Icons.close_rounded,
          color: AppTheme.textPrimary,
          size: 22,
        ),
        style: IconButton.styleFrom(
          minimumSize: Size.zero,
          padding: const EdgeInsets.all(8),
        ),
        onPressed: () {
          if (onBackClick != null) {
            onBackClick!();
          }
        },
      ),
      actions: navigatorRightWidget,
    );
  }
}

abstract class AppBaseStatefulPage extends StatefulWidget {
  const AppBaseStatefulPage({super.key});
}

abstract class AppBaseStatefulPageState<Page extends AppBaseStatefulPage>
    extends State<Page> with AppBaseScreen {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: statusBarStyle == AppStatusBarStyle.light
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
      child: Scaffold(
        appBar: appBar ?? defaultAppBar(),
        backgroundColor: backgroundColor,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        body: body(context),
      ),
    );
  }

  Widget body(BuildContext context);
}
