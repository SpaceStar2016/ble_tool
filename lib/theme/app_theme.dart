import 'package:flutter/material.dart';

/// 应用主题配置
/// 采用深色科技风格，适合BLE工具类应用
class AppTheme {
  AppTheme._();

  // ============ 主色调 ============
  /// 主色 - 科技蓝
  static const Color primaryColor = Color(0xFF0A84FF);
  
  /// 主色亮色变体
  static const Color primaryLight = Color(0xFF5AC8FA);
  
  /// 主色暗色变体
  static const Color primaryDark = Color(0xFF0066CC);

  // ============ 强调色 ============
  /// 强调色 - 电子青
  static const Color accentColor = Color(0xFF30D158);
  
  /// 警告色 - 琥珀橙
  static const Color warningColor = Color(0xFFFF9F0A);
  
  /// 错误色 - 珊瑚红
  static const Color errorColor = Color(0xFFFF453A);
  
  /// 成功色
  static const Color successColor = Color(0xFF32D74B);

  // ============ 背景色 ============
  /// 主背景色 - 深灰
  static const Color scaffoldBackground = Color(0xFF1C1C1E);
  
  /// 次背景色 - 卡片背景
  static const Color cardBackground = Color(0xFF2C2C2E);
  
  /// 表面色 - 组件表面
  static const Color surfaceColor = Color(0xFF3A3A3C);
  
  /// 导航栏背景
  static const Color appBarBackground = Color(0xFF1C1C1E);

  // ============ 文字颜色 ============
  /// 主文字色
  static const Color textPrimary = Color(0xFFFFFFFF);
  
  /// 次文字色
  static const Color textSecondary = Color(0xFF8E8E93);
  
  /// 提示文字色
  static const Color textHint = Color(0xFF636366);
  
  /// 禁用文字色
  static const Color textDisabled = Color(0xFF48484A);

  // ============ 边框和分割线 ============
  /// 分割线颜色
  static const Color dividerColor = Color(0xFF38383A);
  
  /// 边框颜色
  static const Color borderColor = Color(0xFF48484A);

  // ============ 渐变色 ============
  /// 主渐变
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A84FF), Color(0xFF5AC8FA)],
  );
  
  /// 强调渐变
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF30D158), Color(0xFF5AC8FA)],
  );

  // ============ 阴影 ============
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // ============ 圆角 ============
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // ============ 间距 ============
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // ============ 主题数据 ============
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldBackground,
    
    // 颜色方案
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: textPrimary,
      onSecondary: textPrimary,
      onSurface: textPrimary,
      onError: textPrimary,
    ),
    
    // AppBar 主题
    appBarTheme: const AppBarTheme(
      backgroundColor: appBarBackground,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(
        color: textPrimary,
        size: 24,
      ),
    ),

    
    // 按钮主题
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    ),
    
    // 文本按钮主题
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    
    // 输入框主题
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      hintStyle: const TextStyle(color: textHint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    ),
    
    // Chip 主题
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColor,
      selectedColor: primaryColor,
      disabledColor: textDisabled,
      labelStyle: const TextStyle(color: textPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
      ),
    ),
    
    // 分割线主题
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
    ),
    
    // 图标主题
    iconTheme: const IconThemeData(
      color: textSecondary,
      size: 24,
    ),
    
    // 列表瓦片主题
    listTileTheme: const ListTileThemeData(
      textColor: textPrimary,
      iconColor: textSecondary,
    ),
    
    // 底部导航栏主题
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardBackground,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
    ),
    
    // 浮动按钮主题
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: textPrimary,
    ),
    
  );
}

// ============ 便捷扩展 ============
extension AppThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
}

