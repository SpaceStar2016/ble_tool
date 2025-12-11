import 'package:ble_tool/main.dart';
import 'package:ble_tool/log_module/model/ble_log.dart';
import 'package:ble_tool/log_module/provider/log_provider.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BleActionBar extends StatefulWidget {
  final ValueNotifier<bool> canSave;

  const BleActionBar({super.key, required this.canSave});

  @override
  State<BleActionBar> createState() => _BleActionBarState();
}

class _BleActionBarState extends State<BleActionBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.auto_awesome_rounded,
            label: '生成行',
            onTap: () {
              final provider = Provider.of<LogProvider>(context, listen: false);
              provider.updateRowData();
            },
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          ValueListenableBuilder(
            valueListenable: widget.canSave,
            builder: (context, value, child) {
              return _buildActionButton(
                icon: Icons.save_rounded,
                label: '保存',
                enabled: value,
                onTap: () async {
                  // 保存逻辑
                },
              );
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: enabled ? AppTheme.primaryGradient : null,
          color: enabled ? null : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: enabled ? AppTheme.textPrimary : AppTheme.textDisabled,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: enabled ? AppTheme.textPrimary : AppTheme.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
