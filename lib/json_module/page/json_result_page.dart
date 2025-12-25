import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// JSON 结果查看页面
/// 提供全屏查看、搜索、高亮、导航等功能
class JsonResultPage extends AppBaseStatefulPage {
  final String result;
  final bool hasError;

  const JsonResultPage({
    super.key,
    required this.result,
    this.hasError = false,
  });

  @override
  State<JsonResultPage> createState() => _JsonResultPageState();
}

class _JsonResultPageState extends AppBaseStatefulPageState<JsonResultPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _searchKeyword = '';
  bool _isSearching = false;
  int _matchCount = 0;
  int _currentMatchIndex = 0;
  List<int> _matchPositions = [];

  @override
  String get pageTitle => '查看结果';

  @override
  void Function()? get onBackClick => () => Navigator.pop(context);

  @override
  List<Widget>? get navigatorRightWidget => [
    // 复制按钮
    IconButton(
      icon: const Icon(
        Icons.copy_rounded,
        color: AppTheme.primaryColor,
        size: 22,
      ),
      onPressed: _copyResult,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: widget.result));
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

  void _onSearchChanged(String value) {
    setState(() {
      _searchKeyword = value;
      _matchPositions = _findAllMatchPositions();
      _matchCount = _matchPositions.length;
      _currentMatchIndex = _matchCount > 0 ? 0 : -1;
    });
    if (_matchCount > 0) {
      _scrollToCurrentMatch();
    }
  }

  List<int> _findAllMatchPositions() {
    if (_searchKeyword.isEmpty || widget.result.isEmpty) return [];
    final positions = <int>[];
    final lowerResult = widget.result.toLowerCase();
    final lowerKeyword = _searchKeyword.toLowerCase();
    int index = 0;
    while ((index = lowerResult.indexOf(lowerKeyword, index)) != -1) {
      positions.add(index);
      index += lowerKeyword.length;
    }
    return positions;
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
    
    final matchPos = _matchPositions[_currentMatchIndex];
    final textBeforeMatch = widget.result.substring(0, matchPos);
    final lineNumber = '\n'.allMatches(textBeforeMatch).length;
    
    const lineHeight = 14.0 * 1.5;
    final scrollOffset = lineNumber * lineHeight;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final targetOffset = scrollOffset.clamp(0.0, maxScroll);
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget body(BuildContext context) {
    return Column(
      children: [
        // 搜索栏
        _buildSearchBar(),
        // 统计信息
        _buildStatsBar(),
        // 结果内容
        Expanded(
          child: _buildResultContent(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isSearching 
                    ? AppTheme.primaryColor.withOpacity(0.15) 
                    : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                size: 20,
                color: _isSearching ? AppTheme.primaryColor : AppTheme.textHint,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 搜索输入框
          Expanded(
            child: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: '搜索内容...',
                      hintStyle: const TextStyle(
                        color: AppTheme.textHint,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      suffixIcon: _searchKeyword.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                              child: const Icon(
                                Icons.clear_rounded,
                                size: 18,
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
                      '点击搜索内容...',
                      style: TextStyle(
                        color: AppTheme.textHint,
                        fontSize: 15,
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _matchCount > 0
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 22,
                  color: _matchCount > 0
                      ? AppTheme.primaryColor
                      : AppTheme.textHint,
                ),
              ),
            ),
            const SizedBox(width: 6),
            // 向下按钮
            GestureDetector(
              onTap: _matchCount > 0 ? _goToNextMatch : null,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _matchCount > 0
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22,
                  color: _matchCount > 0
                      ? AppTheme.primaryColor
                      : AppTheme.textHint,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 匹配数量显示
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
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
          Icon(
            widget.hasError ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
            size: 16,
            color: widget.hasError ? AppTheme.errorColor : AppTheme.accentColor,
          ),
          const SizedBox(width: 8),
          Text(
            widget.hasError ? 'JSON 格式有误' : 'JSON 格式正确',
            style: TextStyle(
              color: widget.hasError ? AppTheme.errorColor : AppTheme.accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '${widget.result.length} 字符  |  ${widget.result.split('\n').length} 行',
            style: const TextStyle(
              color: AppTheme.textHint,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    return Container(
      color: AppTheme.cardBackground,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: _searchKeyword.isNotEmpty
            ? _buildSearchHighlightedText()
            : SelectableText(
                widget.result,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontFamily: 'monospace',
                  height: 1.5,
                ),
              ),
      ),
    );
  }

  Widget _buildSearchHighlightedText() {
    if (_searchKeyword.isEmpty) {
      return SelectableText(
        widget.result,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontFamily: 'monospace',
          height: 1.5,
        ),
      );
    }

    final spans = <TextSpan>[];
    final lowerResult = widget.result.toLowerCase();
    final lowerKeyword = _searchKeyword.toLowerCase();
    int lastEnd = 0;
    int matchIndex = 0;

    int index = 0;
    while ((index = lowerResult.indexOf(lowerKeyword, lastEnd)) != -1) {
      // 添加匹配前的普通文本
      if (index > lastEnd) {
        spans.add(TextSpan(
          text: widget.result.substring(lastEnd, index),
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontFamily: 'monospace',
            height: 1.5,
          ),
        ));
      }

      // 判断是否为当前选中的匹配
      final isCurrentMatch = matchIndex == _currentMatchIndex;

      // 添加高亮匹配文本
      spans.add(TextSpan(
        text: widget.result.substring(index, index + _searchKeyword.length),
        style: TextStyle(
          color: isCurrentMatch 
              ? Colors.white 
              : const Color(0xFF1A1A2E),
          fontSize: 14,
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
    if (lastEnd < widget.result.length) {
      spans.add(TextSpan(
        text: widget.result.substring(lastEnd),
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontFamily: 'monospace',
          height: 1.5,
        ),
      ));
    }

    return SelectableText.rich(
      TextSpan(children: spans),
    );
  }
}



