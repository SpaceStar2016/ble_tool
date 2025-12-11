import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/log_module/model/ble_log.dart';
import 'package:ble_tool/main.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BleLogEditPage extends AppBaseStatefulPage {
  const BleLogEditPage({super.key});

  @override
  State<BleLogEditPage> createState() => _BleLogEditPageState();
}

class _BleLogEditPageState extends AppBaseStatefulPageState<BleLogEditPage> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  final FocusNode _remarkFocusNode = FocusNode();

  @override
  String get pageTitle => '编辑日志';

  @override
  List<Widget>? get navigatorRightWidget => [
        TextButton(
          onPressed: _saveLog,
          child: const Text(
            '保存',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ];

  @override
  void Function()? get onBackClick {
    return () {
      Navigator.pop(context);
    };
  }

  @override
  void dispose() {
    _contentController.dispose();
    _remarkController.dispose();
    _contentFocusNode.dispose();
    _remarkFocusNode.dispose();
    super.dispose();
  }

  void _saveLog() async {
    final content = _contentController.text.trim();
    final remark = _remarkController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入日志内容'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
      return;
    }

    // 创建 BleLog 对象
    final bleLog = BleLog(
      data: content,
      remark: remark.isNotEmpty ? remark : null,
    );

    // 保存到数据库
    await objectBox.addBleLog(bleLog);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('保存成功'),
        backgroundColor: AppTheme.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );

    Navigator.pop(context, true);  // 返回 true 表示有新增数据
  }

  @override
  Widget body(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击空白区域收起键盘
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 内容输入区域
            _buildSectionTitle('日志内容', icon: Icons.edit_note_rounded, required: true),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildContentInput(),
            const SizedBox(height: AppTheme.spacingLarge),

            // 备注输入区域
            _buildSectionTitle('备注', icon: Icons.sticky_note_2_outlined),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildRemarkInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required IconData icon, bool required = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              color: AppTheme.errorColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildContentInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _contentController,
        focusNode: _contentFocusNode,
        maxLines: 8,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
        decoration: const InputDecoration(
          hintText: '请输入日志内容...',
          hintStyle: TextStyle(
            color: AppTheme.textHint,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppTheme.spacingMedium),
        ),
        onSubmitted: (_) {
          _remarkFocusNode.requestFocus();
        },
      ),
    );
  }

  Widget _buildRemarkInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _remarkController,
        focusNode: _remarkFocusNode,
        maxLines: 4,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
        decoration: const InputDecoration(
          hintText: '添加备注信息（可选）...',
          hintStyle: TextStyle(
            color: AppTheme.textHint,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppTheme.spacingMedium),
        ),
      ),
    );
  }
}
