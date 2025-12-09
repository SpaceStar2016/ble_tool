import 'package:ble_tool/ui_utils.dart';
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

  bool navigatorBottomLine = true;

  List<Widget>? navigatorRightWidget;

  // 背景色
  Color backgroundColor = Color(0xFFF4F4F4);

  Color appBarBackgroundColor = Color(0xFF00C87E);

  // 是否隐藏appBar
  bool hiddeAppBar = false;

  bool extendBodyBehindAppBar = false;

  // 返回按钮的颜色
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
      bottom: navigatorBottomLine
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1.0), // 下划线的高度
              child: Container(
                color: Colors.grey.withOpacity(0.1), // 下划线颜色
                height: 1.0, // 下划线高度
              ),
            )
          : null,
      flexibleSpace: Center(
        child: SafeArea(
          child: titleWidget ??
              Text(
                pageTitle,
                style: const TextStyle(
                  color: Color(0xFF181818),
                  fontSize: 52 / 3,
                  fontWeight: FontWeight.w500,
                ),
              ),
        ),
      ),
      // title: Text(
      //   pageTitle,
      //   style: const TextStyle(
      //     color: Color(0xFF181818),
      //     fontSize: 52 / 3,
      //     fontWeight: FontWeight.w500,
      //   ),
      // ),
      leading: IconButton(
        icon: backArrowStyle == AppBackArrowStyle.styleGoBack
            ? Png.name('icon_back_grey', width: 72 / 3)
            : Png.name('icon_close_grey', width: 72 / 3),
        style: IconButton.styleFrom(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
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

  // setStatusBarStyle() {
  //   if (statusBarStyle == AppStatusBarStyle.light) {
  //     SystemChrome.setSystemUIOverlayStyle(
  //       const SystemUiOverlayStyle(
  //         statusBarIconBrightness: Brightness.light,
  //         statusBarBrightness: Brightness.light, // 设置状态栏亮度（针对 iOS）
  //       ),
  //     );
  //   } else {
  //     SystemChrome.setSystemUIOverlayStyle(
  //       const SystemUiOverlayStyle(
  //         statusBarIconBrightness: Brightness.dark,
  //         statusBarBrightness: Brightness.dark, // 设置状态栏亮度（针对 iOS）
  //       ),
  //     );
  //   }
  // }
}

abstract class AppBaseStatefulPage extends StatefulWidget {
  const AppBaseStatefulPage({super.key});
}

abstract class AppBaseStatefulPageState<Page extends AppBaseStatefulPage>
    extends State<Page> with AppBaseScreen {
  @override
  Widget build(BuildContext context) {
    print("当前页面类型: ${context.widget.runtimeType}");
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
