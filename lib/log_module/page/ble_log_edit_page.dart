import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BleLogEditPage extends AppBaseStatefulPage {
  const BleLogEditPage({super.key});

  @override
  State<BleLogEditPage> createState() => _BleLogEditPageState();
}

class _BleLogEditPageState extends AppBaseStatefulPageState<BleLogEditPage> {
  bool _selected = false;
  bool _filterSelected = false;

  @override
  String get pageTitle => '编辑日志';

  @override
  void Function()? get onBackClick {
    return () {
      Navigator.pop(context);
    };
  }

  @override
  Widget body(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '标签选择',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Wrap(
            spacing: AppTheme.spacingSmall,
            runSpacing: AppTheme.spacingSmall,
            children: [
              // 基础 Chip
              Chip(
                label: const Text('基础标签'),
                backgroundColor: AppTheme.surfaceColor,
                side: BorderSide(color: AppTheme.borderColor.withOpacity(0.5)),
                deleteIcon: const Icon(Icons.close_rounded, size: 18),
                deleteIconColor: AppTheme.textSecondary,
                onDeleted: () => print('删除'),
              ),

              // 输入型 Chip
              InputChip(
                label: const Text('可选标签'),
                selected: _selected,
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                backgroundColor: AppTheme.surfaceColor,
                checkmarkColor: AppTheme.primaryColor,
                side: BorderSide(
                  color: _selected
                      ? AppTheme.primaryColor
                      : AppTheme.borderColor.withOpacity(0.5),
                ),
                onSelected: (bool selected) {
                  setState(() {
                    _selected = selected;
                  });
                },
              ),

              // 筛选型 Chip
              FilterChip(
                label: const Text('筛选标签'),
                selected: _filterSelected,
                selectedColor: AppTheme.accentColor.withOpacity(0.2),
                backgroundColor: AppTheme.surfaceColor,
                checkmarkColor: AppTheme.accentColor,
                side: BorderSide(
                  color: _filterSelected
                      ? AppTheme.accentColor
                      : AppTheme.borderColor.withOpacity(0.5),
                ),
                onSelected: (bool selected) {
                  setState(() {
                    _filterSelected = selected;
                  });
                },
              ),

              // 动作型 Chip
              ActionChip(
                avatar: const Icon(
                  Icons.bolt_rounded,
                  size: 18,
                  color: AppTheme.warningColor,
                ),
                label: const Text('动作标签'),
                backgroundColor: AppTheme.surfaceColor,
                side: BorderSide(color: AppTheme.borderColor.withOpacity(0.5)),
                onPressed: () => print('点击'),
              ),

              // 头像 Chip
              Chip(
                avatar: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(
                    Icons.person_rounded,
                    size: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                label: const Text('用户标签'),
                backgroundColor: AppTheme.surfaceColor,
                side: BorderSide(color: AppTheme.borderColor.withOpacity(0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
