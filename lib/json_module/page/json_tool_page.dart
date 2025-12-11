import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/json_module/util/json_util.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JsonToolPage extends AppBaseStatefulPage {
  const JsonToolPage({super.key});

  @override
  State<JsonToolPage> createState() => _JsonToolPageState();
}

class _JsonToolPageState extends AppBaseStatefulPageState<JsonToolPage> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  String _errorMessage = '';
  bool _isValid = false;

  @override
  String get pageTitle => 'JSON 工具';

  @override
  void Function()? get onBackClick => () => Navigator.pop(context);

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _validateJson() {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _result = '';
        _errorMessage = '';
        _isValid = false;
      });
      return;
    }

    final result = JsonUtil.validate(input);
    setState(() {
      _isValid = result.isValid;
      _errorMessage = result.errorMessage ?? '';
    });
  }

  void _formatJson() {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _result = '';
        _errorMessage = '';
        _isValid = false;
      });
      return;
    }

    final result = JsonUtil.format(input);
    setState(() {
      _isValid = result.isValid;
      _result = result.data ?? '';
      _errorMessage = result.errorMessage ?? '';
    });
  }

  void _compressJson() {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _result = '';
        _errorMessage = '';
        _isValid = false;
      });
      return;
    }

    final result = JsonUtil.compress(input);
    setState(() {
      _isValid = result.isValid;
      _result = result.data ?? '';
      _errorMessage = result.errorMessage ?? '';
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
      _validateJson();
    }
  }

  void _clear() {
    _inputController.clear();
    setState(() {
      _result = '';
      _errorMessage = '';
      _isValid = false;
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
          _buildSectionTitle('JSON 输入', icon: Icons.input_rounded),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildInputField(),
          const SizedBox(height: AppTheme.spacingMedium),

          // 校验状态
          if (_inputController.text.isNotEmpty) ...[
            _buildValidationStatus(),
            const SizedBox(height: AppTheme.spacingMedium),
          ],

          // 操作按钮
          _buildActionButtons(),
          const SizedBox(height: AppTheme.spacingLarge),

          // 结果区域
          _buildSectionTitle('处理结果', icon: Icons.output_rounded),
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
          color: _errorMessage.isNotEmpty
              ? AppTheme.errorColor.withOpacity(0.5)
              : _isValid
                  ? AppTheme.accentColor.withOpacity(0.5)
                  : AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _inputController,
            maxLines: 8,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontFamily: 'monospace',
              height: 1.5,
            ),
            decoration: const InputDecoration(
              hintText: '请输入 JSON 字符串...\n\n例如：{"name": "test", "value": 123}',
              hintStyle: TextStyle(
                color: AppTheme.textHint,
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppTheme.spacingMedium),
            ),
            onChanged: (_) => _validateJson(),
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildSmallButton(
                  icon: Icons.content_paste_rounded,
                  label: '粘贴',
                  onTap: _pasteFromClipboard,
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                _buildSmallButton(
                  icon: Icons.clear_rounded,
                  label: '清除',
                  onTap: _clear,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: _isValid
            ? AppTheme.accentColor.withOpacity(0.1)
            : AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: _isValid
              ? AppTheme.accentColor.withOpacity(0.3)
              : AppTheme.errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isValid ? Icons.check_circle_rounded : Icons.error_rounded,
            size: 18,
            color: _isValid ? AppTheme.accentColor : AppTheme.errorColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isValid ? 'JSON 格式正确 ✓' : _errorMessage,
              style: TextStyle(
                color: _isValid ? AppTheme.accentColor : AppTheme.errorColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.format_indent_increase_rounded,
            label: '格式化',
            gradient: AppTheme.primaryGradient,
            onTap: _formatJson,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: _buildActionButton(
            icon: Icons.compress_rounded,
            label: '压缩',
            gradient: AppTheme.accentGradient,
            onTap: _compressJson,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultArea() {
    final hasError = _errorMessage.isNotEmpty && _result.isEmpty;
    final hasResult = _result.isNotEmpty;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 150),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: hasError
              ? AppTheme.errorColor.withOpacity(0.5)
              : hasResult
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
              Icons.data_object_rounded,
              size: 40,
              color: AppTheme.textHint,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            const Text(
              '格式化或压缩结果将显示在这里',
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
              fontSize: 13,
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
                '长度: ${_result.length} 字符',
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
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
