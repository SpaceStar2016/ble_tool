import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/log_module/model/ble_log.dart';
import 'package:ble_tool/log_module/page/log_select_page.dart';
import 'package:ble_tool/string_module/page/string_format_page.dart';
import 'package:ble_tool/string_module/util/string_diff_util.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StringDiffPage extends AppBaseStatefulPage {
  const StringDiffPage({super.key});

  @override
  State<StringDiffPage> createState() => _StringDiffPageState();
}

class _StringDiffPageState extends AppBaseStatefulPageState<StringDiffPage> {
  final TextEditingController _textAController = TextEditingController();
  final TextEditingController _textBController = TextEditingController();
  
  List<DiffItem> _diffs = [];
  DiffStats? _stats;
  bool _hasCompared = false;

  @override
  String get pageTitle => '字符串对比';

  @override
  void Function()? get onBackClick => () => Navigator.pop(context);

  @override
  void dispose() {
    _textAController.dispose();
    _textBController.dispose();
    super.dispose();
  }

  void _compare() {
    final textA = _textAController.text;
    final textB = _textBController.text;

    final diffs = StringDiffUtil.compare(textA, textB);
    final stats = StringDiffUtil.getStats(diffs);

    setState(() {
      _diffs = diffs;
      _stats = stats;
      _hasCompared = true;
    });
  }

  void _clear() {
    _textAController.clear();
    _textBController.clear();
    setState(() {
      _diffs = [];
      _stats = null;
      _hasCompared = false;
    });
  }

  void _swap() {
    final temp = _textAController.text;
    _textAController.text = _textBController.text;
    _textBController.text = temp;
    if (_hasCompared) {
      _compare();
    }
  }

  Future<void> _importFromLog(TextEditingController controller) async {
    final BleLog? selectedLog = await Navigator.push<BleLog>(
      context,
      MaterialPageRoute(builder: (ctx) => const LogSelectPage()),
    );

    if (selectedLog != null) {
      controller.text = selectedLog.data;
      setState(() {});
    }
  }

  Future<void> _formatText(TextEditingController controller) async {
    final String? result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (ctx) => StringFormatPage(
          initialText: controller.text,
          selectMode: true,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      controller.text = result;
      setState(() {});
    }
  }

  @override
  Widget body(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文本 A 输入
          _buildSectionTitle('文本 A', icon: Icons.text_fields_rounded),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildInputField(_textAController, 'A'),
          const SizedBox(height: AppTheme.spacingMedium),

          // 交换按钮
          Center(
            child: GestureDetector(
              onTap: _swap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.swap_vert_rounded,
                  color: AppTheme.textSecondary,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // 文本 B 输入
          _buildSectionTitle('文本 B', icon: Icons.text_fields_rounded),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildInputField(_textBController, 'B'),
          const SizedBox(height: AppTheme.spacingLarge),

          // 操作按钮
          _buildActionButtons(),
          const SizedBox(height: AppTheme.spacingLarge),

          // 统计信息
          if (_hasCompared && _stats != null) ...[
            _buildStatsCard(),
            const SizedBox(height: AppTheme.spacingMedium),
          ],

          // 差异结果
          _buildSectionTitle('对比结果', icon: Icons.compare_arrows_rounded),
          const SizedBox(height: AppTheme.spacingSmall),
          _buildDiffResult(),
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

  Widget _buildInputField(TextEditingController controller, String label) {
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
            controller: controller,
            maxLines: 8,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontFamily: 'monospace',
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: '请输入文本 $label...',
              hintStyle: const TextStyle(
                color: AppTheme.textHint,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppTheme.spacingMedium),
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
                  '${controller.text.length} 字符',
                  style: const TextStyle(
                    color: AppTheme.textHint,
                    fontSize: 11,
                  ),
                ),
                Row(
                  children: [
                    // 从日志导入按钮
                    GestureDetector(
                      onTap: () => _importFromLog(controller),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 12,
                              color: AppTheme.textPrimary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '日志导入',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 格式化按钮
                    GestureDetector(
                      onTap: () => _formatText(controller),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.text_format_rounded,
                              size: 12,
                              color: AppTheme.textPrimary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '格式化',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 粘贴按钮
                    GestureDetector(
                      onTap: () async {
                        final data = await Clipboard.getData(Clipboard.kTextPlain);
                        if (data?.text != null) {
                          controller.text = data!.text!;
                          setState(() {});
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.content_paste_rounded,
                              size: 12,
                              color: AppTheme.textSecondary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '粘贴',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
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
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _compare,
            child: Container(
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.compare_arrows_rounded,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '对比差异',
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
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        GestureDetector(
          onTap: _clear,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.borderColor.withOpacity(0.5),
              ),
            ),
            child: const Icon(
              Icons.clear_all_rounded,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    final stats = _stats!;
    final isIdentical = !stats.hasChanges;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: isIdentical
            ? AppTheme.accentColor.withOpacity(0.1)
            : AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: isIdentical
              ? AppTheme.accentColor.withOpacity(0.3)
              : AppTheme.warningColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isIdentical ? Icons.check_circle_rounded : Icons.info_rounded,
            color: isIdentical ? AppTheme.accentColor : AppTheme.warningColor,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIdentical ? '完全相同' : '发现差异',
                  style: TextStyle(
                    color: isIdentical ? AppTheme.accentColor : AppTheme.warningColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '相似度: ${stats.similarityPercent.toStringAsFixed(1)}%  |  '
                  '新增: ${stats.insertCount}  |  删除: ${stats.deleteCount}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffResult() {
    if (!_hasCompared) {
      return _buildEmptyResult();
    }

    if (_diffs.isEmpty) {
      return _buildEmptyResult(message: '两个文本均为空');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图例
          _buildLegend(),
          const SizedBox(height: AppTheme.spacingMedium),
          const Divider(color: AppTheme.dividerColor),
          const SizedBox(height: AppTheme.spacingMedium),
          // 差异内容
          Wrap(
            children: _diffs.map((diff) => _buildDiffSpan(diff)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('相同', AppTheme.textPrimary, null),
        const SizedBox(width: AppTheme.spacingMedium),
        _buildLegendItem('新增', AppTheme.accentColor, AppTheme.accentColor.withOpacity(0.2)),
        const SizedBox(width: AppTheme.spacingMedium),
        _buildLegendItem('删除', AppTheme.errorColor, AppTheme.errorColor.withOpacity(0.2)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color textColor, Color? bgColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: bgColor ?? AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(4),
            border: bgColor == null
                ? Border.all(color: AppTheme.borderColor)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDiffSpan(DiffItem diff) {
    Color textColor;
    Color? bgColor;
    TextDecoration? decoration;

    switch (diff.type) {
      case DiffType.insert:
        textColor = AppTheme.accentColor;
        bgColor = AppTheme.accentColor.withOpacity(0.2);
        break;
      case DiffType.delete:
        textColor = AppTheme.errorColor;
        bgColor = AppTheme.errorColor.withOpacity(0.2);
        decoration = TextDecoration.lineThrough;
        break;
      case DiffType.equal:
        textColor = AppTheme.textPrimary;
        bgColor = null;
        break;
    }

    // 处理换行符，使其可见
    final displayText = diff.text
        .replaceAll('\n', '↵\n')
        .replaceAll('\t', '→');

    return Container(
      padding: bgColor != null
          ? const EdgeInsets.symmetric(horizontal: 2, vertical: 1)
          : EdgeInsets.zero,
      decoration: bgColor != null
          ? BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(2),
            )
          : null,
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontFamily: 'monospace',
          height: 1.6,
          decoration: decoration,
          decorationColor: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyResult({String? message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingXLarge),
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
          Icon(
            Icons.compare_rounded,
            size: 40,
            color: AppTheme.textHint,
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            message ?? '输入文本后点击"对比差异"查看结果',
            style: const TextStyle(
              color: AppTheme.textHint,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
