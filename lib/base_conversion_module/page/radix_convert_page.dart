import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/base_conversion_module/util/radix_convert_util.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RadixConvertPage extends AppBaseStatefulPage {
  const RadixConvertPage({super.key});

  @override
  State<RadixConvertPage> createState() => _RadixConvertPageState();
}

class _RadixConvertPageState extends AppBaseStatefulPageState<RadixConvertPage> {
  final TextEditingController _inputController = TextEditingController();
  
  RadixType _fromRadix = RadixType.decimal;
  RadixType _toRadix = RadixType.hexadecimal;
  String _result = '';
  String _errorMessage = '';

  @override
  String get pageTitle => '进制转换';

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

    final result = RadixConvertUtil.convert(
      input: input,
      fromRadix: _fromRadix,
      toRadix: _toRadix,
    );

    setState(() {
      if (result.isSuccess) {
        _result = result.data ?? '';
        _errorMessage = '';
      } else {
        _result = '';
        _errorMessage = result.errorMessage ?? '转换失败';
      }
    });
  }

  void _swapRadix() {
    setState(() {
      final temp = _fromRadix;
      _fromRadix = _toRadix;
      _toRadix = temp;
      
      // 如果有结果，将结果设为输入
      if (_result.isNotEmpty) {
        _inputController.text = _result.replaceAll(' ', '');
        _convert();
      }
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
          // 进制选择
          _buildRadixSelector(),
          const SizedBox(height: AppTheme.spacingLarge),

          // 输入区域
          _buildSectionTitle(
            '${_fromRadix.label}输入',
            icon: Icons.input_rounded,
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildInputField(),
          const SizedBox(height: AppTheme.spacingMedium),

          // 转换按钮
          _buildConvertButton(),
          const SizedBox(height: AppTheme.spacingLarge),

          // 结果区域
          _buildSectionTitle(
            '${_toRadix.label}输出',
            icon: Icons.output_rounded,
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildResultArea(),
          const SizedBox(height: AppTheme.spacingLarge),

          // 快捷转换
          _buildSectionTitle('快捷转换', icon: Icons.flash_on_rounded),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildQuickConvertOptions(),
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

  Widget _buildRadixSelector() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRadixDropdown(
              label: '从',
              value: _fromRadix,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _fromRadix = value;
                  });
                  _convert();
                }
              },
            ),
          ),
          GestureDetector(
            onTap: _swapRadix,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: _buildRadixDropdown(
              label: '转为',
              value: _toRadix,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _toRadix = value;
                  });
                  _convert();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadixDropdown({
    required String label,
    required RadixType value,
    required ValueChanged<RadixType?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textHint,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: DropdownButton<RadixType>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppTheme.cardBackground,
            icon: const Icon(
              Icons.arrow_drop_down_rounded,
              color: AppTheme.textSecondary,
            ),
            items: RadixType.values.map((radix) {
              return DropdownMenuItem<RadixType>(
                value: radix,
                child: Text(
                  '${radix.label} (${radix.shortLabel})',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
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
              : AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _inputController,
            maxLines: 3,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
            decoration: InputDecoration(
              hintText: _getHintText(),
              hintStyle: const TextStyle(
                color: AppTheme.textHint,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppTheme.spacingMedium),
            ),
            onChanged: (_) => _convert(),
          ),
          if (_errorMessage.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingSmall,
              ),
              color: AppTheme.errorColor.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 14,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 12,
                    ),
                  ),
                ],
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
              mainAxisAlignment: MainAxisAlignment.end,
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
          ),
        ],
      ),
    );
  }

  String _getHintText() {
    return switch (_fromRadix) {
      RadixType.binary => '请输入二进制数（如：1010 1100）',
      RadixType.octal => '请输入八进制数（如：754）',
      RadixType.decimal => '请输入十进制数（如：255）',
      RadixType.hexadecimal => '请输入十六进制数（如：FF 或 0xFF）',
    };
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

  Widget _buildConvertButton() {
    return GestureDetector(
      onTap: _convert,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.transform_rounded,
              color: AppTheme.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '${_fromRadix.shortLabel} → ${_toRadix.shortLabel} 转换',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
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
      constraints: const BoxConstraints(minHeight: 100),
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
              Icons.calculate_outlined,
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
              fontSize: 18,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
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
                '${_result.replaceAll(' ', '').length} 位',
                style: const TextStyle(
                  color: AppTheme.textHint,
                  fontSize: 12,
                ),
              ),
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
        ),
      ],
    );
  }

  Widget _buildQuickConvertOptions() {
    return Wrap(
      spacing: AppTheme.spacingSmall,
      runSpacing: AppTheme.spacingSmall,
      children: [
        _buildQuickButton('DEC → HEX', RadixType.decimal, RadixType.hexadecimal, const Color(0xFFFF6482)),
        _buildQuickButton('HEX → DEC', RadixType.hexadecimal, RadixType.decimal, const Color(0xFF64D2FF)),
        _buildQuickButton('DEC → BIN', RadixType.decimal, RadixType.binary, const Color(0xFF30D158)),
        _buildQuickButton('BIN → DEC', RadixType.binary, RadixType.decimal, const Color(0xFFBF5AF2)),
        _buildQuickButton('HEX → BIN', RadixType.hexadecimal, RadixType.binary, const Color(0xFFFF9F0A)),
        _buildQuickButton('BIN → HEX', RadixType.binary, RadixType.hexadecimal, const Color(0xFF5E5CE6)),
      ],
    );
  }

  Widget _buildQuickButton(String label, RadixType from, RadixType to, Color color) {
    final isSelected = _fromRadix == from && _toRadix == to;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _fromRadix = from;
          _toRadix = to;
        });
        _convert();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

