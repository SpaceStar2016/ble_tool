import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/string_module/util/string_format_util.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StringFormatPage extends AppBaseStatefulPage {
  const StringFormatPage({super.key});

  @override
  State<StringFormatPage> createState() => _StringFormatPageState();
}

class _StringFormatPageState extends AppBaseStatefulPageState<StringFormatPage> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';

  @override
  String get pageTitle => '字符串格式化';

  @override
  void Function()? get onBackClick => () => Navigator.pop(context);

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _applyFormat(String Function(String) formatter) {
    final input = _inputController.text;
    if (input.isEmpty) return;
    
    setState(() {
      _result = formatter(input);
    });
  }

  void _copyResult() {
    if (_result.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _result));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('已复制到剪贴板'),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
    }
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _inputController.text = data!.text!;
      setState(() {});
    }
  }

  void _clear() {
    _inputController.clear();
    setState(() {
      _result = '';
    });
  }

  void _applyResult() {
    if (_result.isNotEmpty) {
      _inputController.text = _result;
      setState(() {
        _result = '';
      });
    }
  }

  @override
  Widget body(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 输入区域
          _buildSectionTitle('输入文本', icon: Icons.input_rounded),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildInputField(),
          const SizedBox(height: AppTheme.spacingLarge),

          // 格式化选项
          _buildSectionTitle('格式化选项', icon: Icons.text_format_rounded),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildFormatOptions(),
          const SizedBox(height: AppTheme.spacingLarge),

          // 结果区域
          _buildSectionTitle('结果', icon: Icons.output_rounded),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildResultArea(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required IconData icon}) {
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
      ],
    );
  }

  Widget _buildInputField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _inputController,
            maxLines: 5,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontFamily: 'monospace',
              height: 1.5,
            ),
            decoration: const InputDecoration(
              hintText: '请输入要格式化的文本...',
              hintStyle: TextStyle(
                color: AppTheme.textHint,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppTheme.spacingMedium),
            ),
            onChanged: (_) => setState(() {}),
          ),
          Container(
            height: 1,
            color: AppTheme.dividerColor.withOpacity(0.5),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSmall,
              vertical: AppTheme.spacingXSmall,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_inputController.text.length} 字符',
                  style: const TextStyle(
                    color: AppTheme.textHint,
                    fontSize: 11,
                  ),
                ),
                Row(
                  children: [
                    _buildSmallButton(
                      icon: Icons.content_paste_rounded,
                      label: '粘贴',
                      onTap: _pasteFromClipboard,
                    ),
                    const SizedBox(width: 8),
                    _buildSmallButton(
                      icon: Icons.clear_rounded,
                      label: '清除',
                      onTap: _clear,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatOptions() {
    return Wrap(
      spacing: AppTheme.spacingSmall,
      runSpacing: AppTheme.spacingSmall,
      children: [
        _buildFormatButton(
          label: '大写',
          icon: Icons.arrow_upward_rounded,
          color: const Color(0xFFFF6482),
          onTap: () => _applyFormat(StringFormatUtil.toUpperCase),
        ),
        _buildFormatButton(
          label: '小写',
          icon: Icons.arrow_downward_rounded,
          color: const Color(0xFF64D2FF),
          onTap: () => _applyFormat(StringFormatUtil.toLowerCase),
        ),
        _buildFormatButton(
          label: '首字母大写',
          icon: Icons.format_color_text_rounded,
          color: const Color(0xFFBF5AF2),
          onTap: () => _applyFormat(StringFormatUtil.capitalize),
        ),
        _buildFormatButton(
          label: '每词首字母大写',
          icon: Icons.title_rounded,
          color: const Color(0xFF30D158),
          onTap: () => _applyFormat(StringFormatUtil.titleCase),
        ),
        _buildFormatButton(
          label: '驼峰命名',
          icon: Icons.code_rounded,
          color: const Color(0xFFFF9F0A),
          onTap: () => _applyFormat(StringFormatUtil.toCamelCase),
        ),
        _buildFormatButton(
          label: '下划线命名',
          icon: Icons.horizontal_rule_rounded,
          color: const Color(0xFF5E5CE6),
          onTap: () => _applyFormat(StringFormatUtil.toSnakeCase),
        ),
        _buildFormatButton(
          label: '反转字符串',
          icon: Icons.swap_horiz_rounded,
          color: const Color(0xFFFF453A),
          onTap: () => _applyFormat(StringFormatUtil.reverse),
        ),
        _buildFormatButton(
          label: '去除空格',
          icon: Icons.compress_rounded,
          color: const Color(0xFF00C7BE),
          onTap: () => _applyFormat(StringFormatUtil.removeSpaces),
        ),
        _buildFormatButton(
          label: '去除首尾空格',
          icon: Icons.format_indent_decrease_rounded,
          color: const Color(0xFFAC8E68),
          onTap: () => _applyFormat(StringFormatUtil.trim),
        ),
      ],
    );
  }

  Widget _buildFormatButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultArea() {
    final hasResult = _result.isNotEmpty;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: hasResult
              ? AppTheme.accentColor.withOpacity(0.5)
              : AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: hasResult ? _buildResultContent() : _buildEmptyContent(),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          children: [
            Icon(
              Icons.text_format_rounded,
              size: 40,
              color: AppTheme.textHint,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            const Text(
              '格式化结果将显示在这里',
              style: TextStyle(
                color: AppTheme.textHint,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: SelectableText(
            _result,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ),
        Container(
          height: 1,
          color: AppTheme.dividerColor.withOpacity(0.5),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSmall,
            vertical: AppTheme.spacingXSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_result.length} 字符',
                style: const TextStyle(
                  color: AppTheme.textHint,
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _applyResult,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 14,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '应用',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  GestureDetector(
                    onTap: _copyResult,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.copy_rounded,
                            size: 14,
                            color: AppTheme.textPrimary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '复制',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

