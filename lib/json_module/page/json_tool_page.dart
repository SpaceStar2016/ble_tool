import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/json_module/page/json_result_page.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _resultScrollController = ScrollController();
  String _result = '';
  String _errorMessage = '';
  bool _isValid = false;
  String _searchKeyword = '';
  bool _isSearching = false;
  int _matchCount = 0;
  int _currentMatchIndex = 0; // 当前匹配索引（从0开始）
  List<int> _matchPositions = []; // 所有匹配位置

  @override
  String get pageTitle => 'JSON 工具';

  @override
  void Function()? get onBackClick => () => Navigator.pop(context);

  @override
  void dispose() {
    _inputController.dispose();
    _searchController.dispose();
    _resultScrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchKeyword = value;
      _matchPositions = _findAllMatchPositions();
      _matchCount = _matchPositions.length;
      _currentMatchIndex = _matchCount > 0 ? 0 : -1;
    });
    // 自动滚动到第一个匹配
    if (_matchCount > 0) {
      _scrollToCurrentMatch();
    }
  }

  List<int> _findAllMatchPositions() {
    if (_searchKeyword.isEmpty || _result.isEmpty) return [];
    final positions = <int>[];
    final lowerResult = _result.toLowerCase();
    final lowerKeyword = _searchKeyword.toLowerCase();
    int index = 0;
    while ((index = lowerResult.indexOf(lowerKeyword, index)) != -1) {
      positions.add(index);
      index += lowerKeyword.length;
    }
    return positions;
  }

  int _countMatches() {
    if (_searchKeyword.isEmpty || _result.isEmpty) return 0;
    final lowerResult = _result.toLowerCase();
    final lowerKeyword = _searchKeyword.toLowerCase();
    int count = 0;
    int index = 0;
    while ((index = lowerResult.indexOf(lowerKeyword, index)) != -1) {
      count++;
      index += lowerKeyword.length;
    }
    return count;
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchKeyword = '';
        _matchCount = 0;
        _currentMatchIndex = -1;
        _matchPositions = [];
      }
    });
  }

  void _goToPreviousMatch() {
    if (_matchCount == 0) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex - 1 + _matchCount) % _matchCount;
    });
    _scrollToCurrentMatch();
  }

  void _goToNextMatch() {
    if (_matchCount == 0) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex + 1) % _matchCount;
    });
    _scrollToCurrentMatch();
  }

  void _scrollToCurrentMatch() {
    if (_currentMatchIndex < 0 || _matchPositions.isEmpty) return;
    
    // 计算当前匹配所在行
    final matchPos = _matchPositions[_currentMatchIndex];
    final textBeforeMatch = _result.substring(0, matchPos);
    final lineNumber = '\n'.allMatches(textBeforeMatch).length;
    
    // 估算每行高度（字体大小13 * 行高1.5）
    const lineHeight = 13.0 * 1.5;
    final scrollOffset = lineNumber * lineHeight;
    
    // 滚动到对应位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_resultScrollController.hasClients) {
        final maxScroll = _resultScrollController.position.maxScrollExtent;
        final targetOffset = scrollOffset.clamp(0.0, maxScroll);
        _resultScrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
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
    final hasError = _errorMessage.isNotEmpty;
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
      child: Column(
        children: [
          // 搜索栏（仅在有结果时显示）
          if (hasResult) _buildSearchBar(),
          // 结果内容
          hasResult 
              ? _buildResultContent(hasError: hasError) 
              : _buildEmptyContent(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical: AppTheme.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerColor.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // 搜索图标/按钮
          GestureDetector(
            onTap: _toggleSearch,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _isSearching 
                    ? AppTheme.primaryColor.withOpacity(0.15) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                size: 18,
                color: _isSearching ? AppTheme.primaryColor : AppTheme.textHint,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 搜索输入框
          Expanded(
            child: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: '搜索...',
                      hintStyle: const TextStyle(
                        color: AppTheme.textHint,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      suffixIcon: _searchKeyword.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                              child: const Icon(
                                Icons.clear_rounded,
                                size: 16,
                                color: AppTheme.textHint,
                              ),
                            )
                          : null,
                    ),
                    onChanged: _onSearchChanged,
                  )
                : GestureDetector(
                    onTap: _toggleSearch,
                    child: const Text(
                      '点击搜索结果...',
                      style: TextStyle(
                        color: AppTheme.textHint,
                        fontSize: 13,
                      ),
                    ),
                  ),
          ),
          // 导航按钮和匹配数量
          if (_isSearching && _searchKeyword.isNotEmpty) ...[
            // 向上按钮
            GestureDetector(
              onTap: _matchCount > 0 ? _goToPreviousMatch : null,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _matchCount > 0
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 20,
                  color: _matchCount > 0
                      ? AppTheme.primaryColor
                      : AppTheme.textHint,
                ),
              ),
            ),
            const SizedBox(width: 4),
            // 向下按钮
            GestureDetector(
              onTap: _matchCount > 0 ? _goToNextMatch : null,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _matchCount > 0
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: _matchCount > 0
                      ? AppTheme.primaryColor
                      : AppTheme.textHint,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 匹配数量显示
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _matchCount > 0
                    ? AppTheme.accentColor.withOpacity(0.15)
                    : AppTheme.errorColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                _matchCount > 0
                    ? '${_currentMatchIndex + 1}/$_matchCount'
                    : '0 匹配',
                style: TextStyle(
                  color: _matchCount > 0
                      ? AppTheme.accentColor
                      : AppTheme.errorColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          // 全屏查看按钮
          GestureDetector(
            onTap: _openFullScreenResult,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.fullscreen_rounded,
                size: 18,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreenResult() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => JsonResultPage(
          result: _result,
          hasError: _errorMessage.isNotEmpty,
        ),
      ),
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

  Widget _buildResultContent({bool hasError = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 如果有错误，显示错误提示标签
        if (hasError)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.errorColor.withOpacity(0.3),
                ),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: AppTheme.errorColor,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'JSON 格式有误，已尝试展开并标记错误位置',
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            controller: _resultScrollController,
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: _searchKeyword.isNotEmpty
                ? _buildSearchHighlightedText() // 搜索时优先显示搜索高亮
                : hasError 
                    ? _buildErrorHighlightedText() 
                    : SelectableText(
                        _result,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontFamily: 'monospace',
                          height: 1.5,
                        ),
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
                  if (!hasError)
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
                  if (!hasError) const SizedBox(width: AppTheme.spacingSmall),
                  GestureDetector(
                    onTap: _copyResult,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: hasError ? null : AppTheme.accentGradient,
                        color: hasError ? AppTheme.surfaceColor : null,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.copy_rounded,
                            size: 14,
                            color: hasError 
                                ? AppTheme.textSecondary 
                                : AppTheme.textPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '复制',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: hasError 
                                  ? AppTheme.textSecondary 
                                  : AppTheme.textPrimary,
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

  /// 构建带有搜索高亮的文本
  Widget _buildSearchHighlightedText() {
    if (_searchKeyword.isEmpty) {
      return SelectableText(
        _result,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 13,
          fontFamily: 'monospace',
          height: 1.5,
        ),
      );
    }

    final spans = <TextSpan>[];
    final lowerResult = _result.toLowerCase();
    final lowerKeyword = _searchKeyword.toLowerCase();
    int lastEnd = 0;
    int matchIndex = 0;

    int index = 0;
    while ((index = lowerResult.indexOf(lowerKeyword, lastEnd)) != -1) {
      // 添加匹配前的普通文本
      if (index > lastEnd) {
        spans.add(TextSpan(
          text: _result.substring(lastEnd, index),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontFamily: 'monospace',
            height: 1.5,
          ),
        ));
      }

      // 判断是否为当前选中的匹配
      final isCurrentMatch = matchIndex == _currentMatchIndex;

      // 添加高亮匹配文本
      // 当前匹配：橙红色背景 + 白色文字（最醒目）
      // 其他匹配：亮黄色背景 + 深色文字
      spans.add(TextSpan(
        text: _result.substring(index, index + _searchKeyword.length),
        style: TextStyle(
          color: isCurrentMatch 
              ? Colors.white 
              : const Color(0xFF1A1A2E), // 深色文字
          fontSize: 13,
          fontFamily: 'monospace',
          height: 1.5,
          fontWeight: FontWeight.bold,
          backgroundColor: isCurrentMatch 
              ? const Color(0xFFFF6B6B) // 橙红色，当前匹配
              : const Color(0xFFFFE066), // 亮黄色，其他匹配
        ),
      ));

      lastEnd = index + _searchKeyword.length;
      matchIndex++;
    }

    // 添加剩余文本
    if (lastEnd < _result.length) {
      spans.add(TextSpan(
        text: _result.substring(lastEnd),
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 13,
          fontFamily: 'monospace',
          height: 1.5,
        ),
      ));
    }

    return SelectableText.rich(
      TextSpan(children: spans),
    );
  }

  /// 构建带有错误高亮的文本
  Widget _buildErrorHighlightedText() {
    final lines = _result.split('\n');
    final spans = <TextSpan>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isErrorLine = line.startsWith('▶');
      final isMarkerLine = line.contains('↑↑↑');

      if (isMarkerLine) {
        // 错误标记行 - 红色
        spans.add(TextSpan(
          text: '$line\n',
          style: const TextStyle(
            color: AppTheme.errorColor,
            fontSize: 13,
            fontFamily: 'monospace',
            height: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ));
      } else if (isErrorLine) {
        // 错误行 - 红色背景
        spans.add(TextSpan(
          text: '$line\n',
          style: TextStyle(
            color: AppTheme.errorColor,
            fontSize: 13,
            fontFamily: 'monospace',
            height: 1.5,
            backgroundColor: AppTheme.errorColor.withOpacity(0.15),
          ),
        ));
      } else {
        // 普通行
        spans.add(TextSpan(
          text: i < lines.length - 1 ? '$line\n' : line,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontFamily: 'monospace',
            height: 1.5,
          ),
        ));
      }
    }

    return SelectableText.rich(
      TextSpan(children: spans),
    );
  }
}
