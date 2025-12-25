import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/log_module/model/ble_log.dart';
import 'package:ble_tool/log_module/page/log_item_view.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/log_provider.dart';

/// 日志选择页面，选择后返回 BleLog 对象
class LogSelectPage extends AppBaseStatefulPage {
  const LogSelectPage({super.key});

  @override
  State<LogSelectPage> createState() => _LogSelectPageState();
}

class _LogSelectPageState extends AppBaseStatefulPageState<LogSelectPage> {
  @override
  String get pageTitle => '选择日志';

  @override
  void Function()? get onBackClick => () => Navigator.pop(context);

  @override
  void initState() {
    super.initState();
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    logProvider.fetchLog();
  }

  void _selectLog(BleLog log) {
    Navigator.pop(context, log);
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
                return LogItemView(
                  bleLog: log,
                  onTap: () => _selectLog(log),
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
          const SizedBox(height: AppTheme.spacingSmall),
          const Text(
            '请先在日志模块中添加日志',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }
}



