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
  
  // 滚动控制器用于同步滚动
  final ScrollController _scrollControllerA = ScrollController();
  final ScrollController _scrollControllerB = ScrollController();
  bool _isSyncingScroll = false;  // 防止循环触发

  List<DiffItem> _diffs = [];
  DiffStats? _stats;
  bool _hasCompared = false;

  @override
  String get pageTitle => '字符串对比';

  @override
  void Function()? get onBackClick => () => Navigator.pop(context);

  @override
  void initState() {
    super.initState();
    // 添加滚动监听器实现同步滚动
    _scrollControllerA.addListener(_onScrollA);
    _scrollControllerB.addListener(_onScrollB);
  }

  @override
  void dispose() {
    _textAController.dispose();
    _textBController.dispose();
    _scrollControllerA.removeListener(_onScrollA);
    _scrollControllerB.removeListener(_onScrollB);
    _scrollControllerA.dispose();
    _scrollControllerB.dispose();
    super.dispose();
  }

  /// 文本 A 滚动时同步文本 B
  void _onScrollA() {
    if (_isSyncingScroll) return;
    if (!_scrollControllerB.hasClients) return;
    
    _isSyncingScroll = true;
    final maxScrollA = _scrollControllerA.position.maxScrollExtent;
    final maxScrollB = _scrollControllerB.position.maxScrollExtent;
    
    if (maxScrollA > 0 && maxScrollB > 0) {
      // 按比例同步滚动
      final ratio = _scrollControllerA.offset / maxScrollA;
      _scrollControllerB.jumpTo(ratio * maxScrollB);
    } else if (maxScrollA == 0 || maxScrollB == 0) {
      // 如果其中一个不可滚动，直接同步偏移量
      final targetOffset = _scrollControllerA.offset.clamp(0.0, maxScrollB);
      _scrollControllerB.jumpTo(targetOffset);
    }
    _isSyncingScroll = false;
  }

  /// 文本 B 滚动时同步文本 A
  void _onScrollB() {
    if (_isSyncingScroll) return;
    if (!_scrollControllerA.hasClients) return;
    
    _isSyncingScroll = true;
    final maxScrollA = _scrollControllerA.position.maxScrollExtent;
    final maxScrollB = _scrollControllerB.position.maxScrollExtent;
    
    if (maxScrollA > 0 && maxScrollB > 0) {
      // 按比例同步滚动
      final ratio = _scrollControllerB.offset / maxScrollB;
      _scrollControllerA.jumpTo(ratio * maxScrollA);
    } else if (maxScrollA == 0 || maxScrollB == 0) {
      // 如果其中一个不可滚动，直接同步偏移量
      final targetOffset = _scrollControllerB.offset.clamp(0.0, maxScrollA);
      _scrollControllerA.jumpTo(targetOffset);
    }
    _isSyncingScroll = false;
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
      setState(() {
        _hasCompared = false;
      });
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
      setState(() {
        _hasCompared = false;
      });
    }
  }

  // 差异高亮颜色（统一用橙黄色标注差异）
  static const Color _diffHighlightColor = Color(0xFFFF9500);

  /// 生成文本 A 的差异高亮视图（显示相同 + 删除部分高亮）
  List<InlineSpan> _buildTextASpans() {
    final spans = <InlineSpan>[];
    for (final diff in _diffs) {
      if (diff.type == DiffType.equal) {
        spans.add(TextSpan(
          text: diff.text,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontFamily: 'monospace',
            height: 1.5,
          ),
        ));
      } else if (diff.type == DiffType.delete) {
        spans.add(WidgetSpan(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _diffHighlightColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              diff.text,
              style: TextStyle(
                color: _diffHighlightColor,
                fontSize: 14,
                fontFamily: 'monospace',
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ));
      }
      // insert 类型在文本 A 中不显示
    }
    return spans;
  }

  /// 生成文本 B 的差异高亮视图（显示相同 + 新增部分高亮）
  List<InlineSpan> _buildTextBSpans() {
    final spans = <InlineSpan>[];
    for (final diff in _diffs) {
      if (diff.type == DiffType.equal) {
        spans.add(TextSpan(
          text: diff.text,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontFamily: 'monospace',
            height: 1.5,
          ),
        ));
      } else if (diff.type == DiffType.insert) {
        spans.add(WidgetSpan(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _diffHighlightColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              diff.text,
              style: TextStyle(
                color: _diffHighlightColor,
                fontSize: 14,
                fontFamily: 'monospace',
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ));
      }
      // delete 类型在文本 B 中不显示
    }
    return spans;
  }

  @override
  Widget body(BuildContext context) {
    return Column(
      children: [
        // 操作按钮区域
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: _buildActionButtons(),
        ),

        // 统计信息
        if (_hasCompared && _stats != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
            child: _buildStatsCard(),
          ),

        // 图例
        if (_hasCompared)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingSmall,
            ),
            child: _buildLegend(),
          ),

        // 横向布局的文本 A 和文本 B
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 文本 A
                Expanded(
                  child: _buildTextPanel(
                    label: 'A',
                    labelColor: const Color(0xFFFF6B6B),
                    controller: _textAController,
                    scrollController: _scrollControllerA,
                    diffSpans: _hasCompared ? _buildTextASpans() : null,
                    hintSuffix: '(原文本)',
                  ),
                ),

                // 中间交换按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _swap,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.borderColor.withOpacity(0.5),
                              ),
                            ),
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 文本 B
                Expanded(
                  child: _buildTextPanel(
                    label: 'B',
                    labelColor: const Color(0xFF4ECDC4),
                    controller: _textBController,
                    scrollController: _scrollControllerB,
                    diffSpans: _hasCompared ? _buildTextBSpans() : null,
                    hintSuffix: '(新文本)',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextPanel({
    required String label,
    required Color labelColor,
    required TextEditingController controller,
    required ScrollController scrollController,
    List<InlineSpan>? diffSpans,
    String hintSuffix = '',
  }) {
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
          // 标题栏
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: labelColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusMedium),
                topRight: Radius.circular(AppTheme.radiusMedium),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: labelColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    '文本 $label',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  hintSuffix,
                  style: const TextStyle(
                    color: AppTheme.textHint,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Text(
                  '${controller.text.length} 字符',
                  style: const TextStyle(
                    color: AppTheme.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // 内容区域
          Expanded(
            child: diffSpans != null && diffSpans.isNotEmpty
                ? _buildDiffView(diffSpans, scrollController)
                : _buildEditView(controller, label, scrollController),
          ),

          // 底部工具栏
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.dividerColor.withOpacity(0.5),
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSmall,
              vertical: AppTheme.spacingXSmall,
            ),
            child: Row(
              children: [
                // 从日志导入按钮
                _buildToolButton(
                  icon: Icons.article_outlined,
                  label: '日志导入',
                  gradient: AppTheme.primaryGradient,
                  onTap: () => _importFromLog(controller),
                ),
                const SizedBox(width: 6),
                // 格式化按钮
                _buildToolButton(
                  icon: Icons.text_format_rounded,
                  label: '格式化',
                  gradient: AppTheme.accentGradient,
                  onTap: () => _formatText(controller),
                ),
                const SizedBox(width: 6),
                // 粘贴按钮
                _buildToolButton(
                  icon: Icons.content_paste_rounded,
                  label: '粘贴',
                  onTap: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      controller.text = data!.text!;
                      setState(() {
                        _hasCompared = false;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditView(TextEditingController controller, String label, ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      child: TextField(
        controller: controller,
        maxLines: null,
        textAlignVertical: TextAlignVertical.top,
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
        onChanged: (_) {
          setState(() {
            _hasCompared = false;
          });
        },
      ),
    );
  }

  Widget _buildDiffView(List<InlineSpan> spans, ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: SelectableText.rich(
        TextSpan(children: spans),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    Gradient? gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? AppTheme.surfaceColor : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12,
                color: gradient != null ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: gradient != null ? FontWeight.w500 : FontWeight.normal,
                  color: gradient != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _compare,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        GestureDetector(
          onTap: _clear,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: AppTheme.borderColor.withOpacity(0.5),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.clear_all_rounded,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '清空',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
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

  Widget _buildStatsCard() {
    final stats = _stats!;
    final isIdentical = !stats.hasChanges;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
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
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          Text(
            isIdentical ? '完全相同' : '发现差异',
            style: TextStyle(
              color: isIdentical ? AppTheme.accentColor : AppTheme.warningColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Text(
              '相似度: ${stats.similarityPercent.toStringAsFixed(1)}%  |  '
              '差异字符: ${stats.totalChanges}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('相同', AppTheme.textPrimary, null),
        const SizedBox(width: AppTheme.spacingLarge),
        _buildLegendItem('差异', _diffHighlightColor, _diffHighlightColor.withOpacity(0.3)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color textColor, Color? bgColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: bgColor ?? AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(3),
            border: bgColor == null ? Border.all(color: AppTheme.borderColor) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
