import 'package:diff_match_patch/diff_match_patch.dart';

/// 差异类型
enum DiffType {
  equal,  // 相同
  insert, // 新增
  delete, // 删除
}

/// 差异项
class DiffItem {
  final DiffType type;
  final String text;

  const DiffItem({
    required this.type,
    required this.text,
  });

  bool get isEqual => type == DiffType.equal;
  bool get isInsert => type == DiffType.insert;
  bool get isDelete => type == DiffType.delete;
}

/// 差异统计
class DiffStats {
  final int insertCount;
  final int deleteCount;
  final int equalCount;

  const DiffStats({
    required this.insertCount,
    required this.deleteCount,
    required this.equalCount,
  });

  int get totalChanges => insertCount + deleteCount;
  bool get hasChanges => totalChanges > 0;
  
  double get similarityPercent {
    final total = insertCount + deleteCount + equalCount;
    if (total == 0) return 100.0;
    return (equalCount / total) * 100;
  }
}

/// 字符串差异对比工具
class StringDiffUtil {
  StringDiffUtil._();

  static final DiffMatchPatch _dmp = DiffMatchPatch();

  /// 对比两个字符串，返回差异列表
  static List<DiffItem> compare(String textA, String textB) {
    if (textA.isEmpty && textB.isEmpty) {
      return [];
    }

    final diffs = _dmp.diff(textA, textB);
    
    // 清理差异，使结果更易读
    _dmp.diffCleanupSemantic(diffs);

    return diffs.map((diff) {
      final type = switch (diff.operation) {
        DIFF_INSERT => DiffType.insert,
        DIFF_DELETE => DiffType.delete,
        _ => DiffType.equal,
      };
      return DiffItem(type: type, text: diff.text);
    }).toList();
  }

  /// 获取差异统计信息
  static DiffStats getStats(List<DiffItem> diffs) {
    int insertCount = 0;
    int deleteCount = 0;
    int equalCount = 0;

    for (final diff in diffs) {
      switch (diff.type) {
        case DiffType.insert:
          insertCount += diff.text.length;
          break;
        case DiffType.delete:
          deleteCount += diff.text.length;
          break;
        case DiffType.equal:
          equalCount += diff.text.length;
          break;
      }
    }

    return DiffStats(
      insertCount: insertCount,
      deleteCount: deleteCount,
      equalCount: equalCount,
    );
  }

  /// 快速检查两个字符串是否相同
  static bool isEqual(String textA, String textB) {
    return textA == textB;
  }

  /// 计算相似度百分比
  static double getSimilarityPercent(String textA, String textB) {
    if (textA.isEmpty && textB.isEmpty) return 100.0;
    if (textA.isEmpty || textB.isEmpty) return 0.0;
    
    final diffs = compare(textA, textB);
    final stats = getStats(diffs);
    return stats.similarityPercent;
  }
}

