import 'package:ble_tool/base64_module/page/base64_convert_page.dart';
import 'package:ble_tool/json_module/page/json_tool_page.dart';
import 'package:ble_tool/log_module/page/log_list_page.dart';
import 'package:ble_tool/string_module/page/string_diff_page.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarBackground,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.bluetooth_rounded,
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'BLE Tool',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '工具箱',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Wrap(
                spacing: AppTheme.spacingMedium,
                runSpacing: AppTheme.spacingMedium,
                children: [
                  _buildToolCard(
                    icon: Icons.article_outlined,
                    title: '日志记录',
                    subtitle: '查看和管理日志',
                    gradient: AppTheme.primaryGradient,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LogListPage(),
                        ),
                      );
                    },
                  ),
                  _buildToolCard(
                    icon: Icons.transform_rounded,
                    title: 'Base64转16进制',
                    subtitle: '编码解码工具',
                    gradient: AppTheme.accentGradient,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Base64ConvertPage(),
                        ),
                      );
                    },
                  ),
                  _buildToolCard(
                    icon: Icons.data_object_rounded,
                    title: 'JSON 工具',
                    subtitle: '格式化与解析',
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFBF5AF2), Color(0xFFFF6482)],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JsonToolPage(),
                        ),
                      );
                    },
                  ),
                  _buildToolCard(
                    icon: Icons.compare_arrows_rounded,
                    title: '字符串对比',
                    subtitle: '差异对比分析',
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF9F0A), Color(0xFFFFCC00)],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StringDiffPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: AppTheme.borderColor.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(
                icon,
                color: AppTheme.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXSmall),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
