import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/log_module/page/ble_log_edit_page.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ble_action_bar.dart';
import 'send_row_view.dart';
import '../provider/log_provider.dart';

class LogListPage extends AppBaseStatefulPage {
  const LogListPage({super.key});

  @override
  State<LogListPage> createState() => _LogPageState();
}

class _LogPageState extends AppBaseStatefulPageState<LogListPage> {
  @override
  String get pageTitle => '日志记录';

  @override
  List<Widget>? get navigatorRightWidget => [
        IconButton(
          icon: const Icon(
            Icons.add_rounded,
            color: AppTheme.primaryColor,
            size: 26,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => const BleLogEditPage()),
            );
          },
        ),
      ];

  @override
  void initState() {
    super.initState();
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    logProvider.fetchLog();
  }

  @override
  Widget body(BuildContext context) {
    return Consumer<LogProvider>(builder: (context, bleProvider, child) {
      return bleProvider.logs.isEmpty
          ? _noDataView("暂无日志数据")
          : ListView.separated(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              itemCount: bleProvider.logs.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: AppTheme.spacingSmall),
              itemBuilder: (ctx, index) {
                final log = bleProvider.logs[index];
                return Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: AppTheme.borderColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: Text(
                          "${log.data}",
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                );
              },
            );
    });
  }

  Widget _noDataView(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXLarge),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                return const BleLogEditPage();
              }));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    color: AppTheme.textPrimary,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '添加日志',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  @override
  void Function()? get onBackClick {
    return () {
      Navigator.pop(context);
    };
  }
}
