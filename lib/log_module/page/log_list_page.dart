import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/log_module/model/ble_log.dart';
import 'package:ble_tool/log_module/page/ble_log_edit_page.dart';
import 'package:ble_tool/log_module/page/log_item_view.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          onPressed: () => _navigateToEditPage(),
        ),
      ];

  void _navigateToEditPage({BleLog? bleLog}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (ctx) => BleLogEditPage(bleLog: bleLog)),
    );
    if (result == true && mounted) {
      final logProvider = Provider.of<LogProvider>(context, listen: false);
      logProvider.fetchLog();
    }
  }

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
              separatorBuilder: (ctx, index) =>
                  const SizedBox(height: AppTheme.spacingSmall),
              itemBuilder: (ctx, index) {
                final log = bleProvider.logs[index];
                return _buildSwipeableLogItem(log);
              },
            );
    });
  }

  Widget _buildSwipeableLogItem(BleLog log) {
    return Dismissible(
      key: Key('log_${log.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteConfirmDialog(log),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppTheme.spacingLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.errorColor.withOpacity(0.1),
              AppTheme.errorColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              '删除',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: LogItemView(
        bleLog: log,
        onTap: () => _navigateToEditPage(bleLog: log),
      ),
    );
  }

  Future<bool> _showDeleteConfirmDialog(BleLog log) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.errorColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '确认删除',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '确定要删除这条日志吗？此操作不可撤销。',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                log.data,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              '取消',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.errorColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
            child: const Text(
              '删除',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final logProvider = Provider.of<LogProvider>(context, listen: false);
      await logProvider.deleteLog(log.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('已删除'),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    return false;
  }

  Widget _noDataView(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
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
            onTap: () => _navigateToEditPage(),
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
