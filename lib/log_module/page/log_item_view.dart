import 'package:ble_tool/log_module/model/ble_log.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LogItemView extends StatelessWidget {
  final BleLog bleLog;
  final VoidCallback? onTap;

  const LogItemView({
    super.key,
    required this.bleLog,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：时间
            _buildTimeRow(),
            
            // 第二行：备注（如果有）
            if (bleLog.remark != null && bleLog.remark!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingSmall),
              _buildRemarkRow(),
            ],
            
            // 第三行：内容
            const SizedBox(height: AppTheme.spacingSmall),
            _buildContentRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: const Icon(
            Icons.access_time_rounded,
            color: AppTheme.primaryColor,
            size: 14,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSmall),
        Text(
          bleLog.dateFormat,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        const Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.textHint,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildRemarkRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: const Icon(
            Icons.sticky_note_2_outlined,
            color: AppTheme.accentColor,
            size: 14,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSmall),
        Expanded(
          child: Text(
            bleLog.remark!,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildContentRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: const Icon(
            Icons.article_outlined,
            color: AppTheme.warningColor,
            size: 14,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSmall),
        Expanded(
          child: Text(
            bleLog.data,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

