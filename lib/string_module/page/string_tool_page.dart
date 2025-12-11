import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/string_module/page/radix_convert_page.dart';
import 'package:ble_tool/string_module/page/string_diff_page.dart';
import 'package:ble_tool/string_module/page/string_format_page.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StringToolPage extends AppBaseStatefulPage {
  const StringToolPage({super.key});

  @override
  State<StringToolPage> createState() => _StringToolPageState();
}

class _StringToolPageState extends AppBaseStatefulPageState<StringToolPage> {
  @override
  String get pageTitle => '字符串工具';

  @override
  void Function()? get onBackClick => () => Navigator.pop(context);

  @override
  Widget body(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择工具',
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
              _buildToolCard(
                icon: Icons.text_format_rounded,
                title: '字符串格式化',
                subtitle: '大小写转换等',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF64D2FF), Color(0xFF5E5CE6)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StringFormatPage(),
                    ),
                  );
                },
              ),
              _buildToolCard(
                icon: Icons.calculate_rounded,
                title: '进制转换',
                subtitle: '2/8/10/16进制',
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF30D158), Color(0xFF00C7BE)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RadixConvertPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
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

