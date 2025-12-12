import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/log_module/model/ble_log.dart';
import 'package:ble_tool/log_module/page/ble_log_edit_page.dart';
import 'package:ble_tool/log_module/page/log_item_view.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/log_provider.dart';

class LogListPage extends AppBaseStatefulPage {
  const LogListPage({super.key});

  @override
  State<LogListPage> createState() => _LogPageState();
}

class _LogPageState extends AppBaseStatefulPageState<LogListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  bool _isSearching = false;

  @override
  String get pageTitle => '日志记录';

  @override
  List<Widget>? get navigatorRightWidget => [
        // 搜索按钮
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close_rounded : Icons.search_rounded,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          onPressed: _toggleSearch,
        ),
        // 添加按钮
        IconButton(
          icon: const Icon(
            Icons.add_rounded,
            color: AppTheme.primaryColor,
            size: 26,
          ),
          onPressed: () => _navigateToEditPage(),
        ),
      ];

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchKeyword = '';
      }
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchKeyword = value.trim().toLowerCase();
    });
  }

  List<BleLog> _filterLogs(List<BleLog> logs) {
    if (_searchKeyword.isEmpty) return logs;
    
    return logs.where((log) {
      final remark = log.remark?.toLowerCase() ?? '';
      return remark.contains(_searchKeyword);
    }).toList();
  }

  void _navigateToEditPage({BleLog? bleLog}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (ctx) => BleLogEditPage(bleLog: bleLog)),
    );
    if (result == true && mounted) {
      final logProvider = Provider.of<LogProvider>(context, listen: false);
      logProvider.fetchLog();
    }
  }

  @override
  void initState() {
    super.initState();
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    logProvider.fetchLog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget body(BuildContext context) {
    return Consumer<LogProvider>(builder: (context, bleProvider, child) {
      final filteredLogs = _filterLogs(bleProvider.logs);
      
      return Column(
        children: [
          // 搜索框
          if (_isSearching) _buildSearchBar(),
          
          // 日志列表
          Expanded(
            child: filteredLogs.isEmpty
                ? _noDataView(_searchKeyword.isEmpty ? "暂无日志数据" : "未找到匹配的日志")
                : ListView.separated(
                    padding: const EdgeInsets.all(AppTheme.spacingMedium),
                    itemCount: filteredLogs.length,
                    separatorBuilder: (ctx, index) =>
                        const SizedBox(height: AppTheme.spacingSmall),
                    itemBuilder: (ctx, index) {
                      final log = filteredLogs[index];
                      return _buildSwipeableLogItem(log);
                    },
                  ),
          ),
        ],
      );
    });
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
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: '搜索备注...',
          hintStyle: const TextStyle(
            color: AppTheme.textHint,
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.textHint,
            size: 20,
          ),
          suffixIcon: _searchKeyword.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  child: const Icon(
                    Icons.clear_rounded,
                    color: AppTheme.textHint,
                    size: 20,
                  ),
                )
              : null,
          filled: true,
          fillColor: AppTheme.surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
            vertical: AppTheme.spacingSmall,
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildSwipeableLogItem(BleLog log) {
    return Dismissible(
      key: Key('log_${log.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteConfirmDialog(log),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppTheme.spacingLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.errorColor.withOpacity(0.1),
              AppTheme.errorColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              '删除',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: LogItemView(
        bleLog: log,
        onTap: () => _navigateToEditPage(bleLog: log),
      ),
    );
  }

  Future<bool> _showDeleteConfirmDialog(BleLog log) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.errorColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '确认删除',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '确定要删除这条日志吗？此操作不可撤销。',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                log.data,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              '取消',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.errorColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
            child: const Text(
              '删除',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final logProvider = Provider.of<LogProvider>(context, listen: false);
      await logProvider.deleteLog(log.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('已删除'),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    return false;
  }

  Widget _noDataView(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXLarge),
          GestureDetector(
            onTap: () => _navigateToEditPage(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_rounded,
                    color: AppTheme.textPrimary,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '添加日志',
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
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  @override
  void Function()? get onBackClick {
    return () {
      Navigator.pop(context);
    };
  }
}
