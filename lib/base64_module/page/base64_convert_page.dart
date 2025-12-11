import 'dart:convert';

import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Base64ConvertPage extends AppBaseStatefulPage {
  const Base64ConvertPage({super.key});

  @override
  State<Base64ConvertPage> createState() => _Base64ConvertPageState();
}

class _Base64ConvertPageState extends AppBaseStatefulPageState<Base64ConvertPage> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  String _errorMessage = '';
  bool _isDecoding = true; // true: Base64 -> Hex, false: Hex -> Base64

  @override
  String get pageTitle => 'Base64 转换';

  @override
  void Function()? get onBackClick => () => Navigator.pop(context);

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _result = '';
        _errorMessage = '';
      });
      return;
    }

    try {
      if (_isDecoding) {
        // Base64 -> Hex
        final bytes = base64Decode(input);
        _result = bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
        _errorMessage = '';
      } else {
        // Hex -> Base64
        final hexString = input.replaceAll(RegExp(r'\s+'), '');
        if (hexString.length % 2 != 0) {
          throw FormatException('Hex长度必须为偶数');
        }
        final bytes = <int>[];
        for (var i = 0; i < hexString.length; i += 2) {
          bytes.add(int.parse(hexString.substring(i, i + 2), radix: 16));
        }
        _result = base64Encode(bytes);
        _errorMessage = '';
      }
    } catch (e) {
      _result = '';
      _errorMessage = _isDecoding ? '无效的 Base64 字符串' : '无效的 Hex 字符串';
    }
    setState(() {});
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
      _convert();
    }
  }

  void _clear() {
    _inputController.clear();
    setState(() {
      _result = '';
      _errorMessage = '';
    });
  }

  @override
  Widget body(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 模式切换
          _buildModeSwitch(),
          const SizedBox(height: AppTheme.spacingLarge),

          // 输入区域
          _buildSectionTitle(
            _isDecoding ? 'Base64 输入' : 'Hex 输入',
            icon: Icons.input_rounded,
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildInputField(),
          const SizedBox(height: AppTheme.spacingMedium),

          // 操作按钮
          _buildActionButtons(),
          const SizedBox(height: AppTheme.spacingLarge),

          // 结果区域
          _buildSectionTitle(
            _isDecoding ? 'Hex 输出' : 'Base64 输出',
            icon: Icons.output_rounded,
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildResultArea(),
        ],
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isDecoding) {
                  setState(() {
                    _isDecoding = true;
                    _clear();
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: _isDecoding ? AppTheme.primaryGradient : null,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_open_rounded,
                      size: 18,
                      color: _isDecoding
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Base64 → Hex',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isDecoding
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isDecoding) {
                  setState(() {
                    _isDecoding = false;
                    _clear();
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: !_isDecoding ? AppTheme.accentGradient : null,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 18,
                      color: !_isDecoding
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Hex → Base64',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: !_isDecoding
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
            ),
            decoration: InputDecoration(
              hintText: _isDecoding
                  ? '请输入 Base64 字符串...'
                  : '请输入 Hex 字符串（如：48 65 6C 6C 6F）...',
              hintStyle: const TextStyle(
                color: AppTheme.textHint,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppTheme.spacingMedium),
            ),
            onChanged: (_) => _convert(),
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
          child: GestureDetector(
            onTap: _convert,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: _isDecoding
                    ? AppTheme.primaryGradient
                    : AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: (_isDecoding
                            ? AppTheme.primaryColor
                            : AppTheme.accentColor)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isDecoding
                        ? Icons.transform_rounded
                        : Icons.enhanced_encryption_rounded,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isDecoding ? '解码' : '编码',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultArea() {
    final hasError = _errorMessage.isNotEmpty;
    final hasResult = _result.isNotEmpty;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
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
      child: hasError
          ? _buildErrorContent()
          : hasResult
              ? _buildResultContent()
              : _buildEmptyContent(),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          children: [
            Icon(
              Icons.text_snippet_outlined,
              size: 40,
              color: AppTheme.textHint,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            const Text(
              '转换结果将显示在这里',
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

  Widget _buildErrorContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              _errorMessage,
              style: const TextStyle(
                color: AppTheme.errorColor,
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
                '长度: ${_result.length} 字符',
                style: const TextStyle(
                  color: AppTheme.textHint,
                  fontSize: 12,
                ),
              ),
              GestureDetector(
                onTap: _copyResult,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        ),
      ],
    );
  }
}

