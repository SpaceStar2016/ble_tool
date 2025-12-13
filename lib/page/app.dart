import 'package:ble_tool/log_module/provider/log_provider.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'main_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LogProvider())],
      child: ScreenUtilInit(
          designSize: const Size(1125, 2436),
          minTextAdapt: true,
          splitScreenMode: true,
        builder: (context,child) {
          return MaterialApp(
            title: 'BLE Tool',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const MainPage(),
          );
        }
      ),
    );
  }
}
