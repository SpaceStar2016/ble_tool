/// 字符串格式化工具类
class StringFormatUtil {
  StringFormatUtil._();

  /// 转大写
  static String toUpperCase(String input) {
    return input.toUpperCase();
  }

  /// 转小写
  static String toLowerCase(String input) {
    return input.toLowerCase();
  }

  /// 首字母大写
  static String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  /// 每个单词首字母大写（Title Case）
  static String titleCase(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// 转驼峰命名（camelCase）
  static String toCamelCase(String input) {
    if (input.isEmpty) return input;
    
    // 分割：按空格、下划线、连字符分割
    final words = input.split(RegExp(r'[\s_\-]+'));
    if (words.isEmpty) return input;
    
    final buffer = StringBuffer();
    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.isEmpty) continue;
      
      if (i == 0) {
        buffer.write(word.toLowerCase());
      } else {
        buffer.write(word[0].toUpperCase());
        buffer.write(word.substring(1).toLowerCase());
      }
    }
    return buffer.toString();
  }

  /// 转下划线命名（snake_case）
  static String toSnakeCase(String input) {
    if (input.isEmpty) return input;
    
    // 先处理驼峰命名
    final result = input
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)}_${match.group(2)}',
        )
        // 处理空格和连字符
        .replaceAll(RegExp(r'[\s\-]+'), '_')
        .toLowerCase();
    
    // 去除多余的下划线
    return result.replaceAll(RegExp(r'_+'), '_');
  }

  /// 反转字符串
  static String reverse(String input) {
    return input.split('').reversed.join();
  }

  /// 去除所有空格
  static String removeSpaces(String input) {
    return input.replaceAll(RegExp(r'\s+'), '');
  }

  /// 去除首尾空格
  static String trim(String input) {
    return input.trim();
  }

  /// 转短横线命名（kebab-case）
  static String toKebabCase(String input) {
    if (input.isEmpty) return input;
    
    final result = input
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)}-${match.group(2)}',
        )
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .toLowerCase();
    
    return result.replaceAll(RegExp(r'-+'), '-');
  }

  /// 转常量命名（CONSTANT_CASE）
  static String toConstantCase(String input) {
    return toSnakeCase(input).toUpperCase();
  }

  /// 统计字符数（不含空格）
  static int countCharsWithoutSpaces(String input) {
    return input.replaceAll(RegExp(r'\s'), '').length;
  }

  /// 统计单词数
  static int countWords(String input) {
    if (input.trim().isEmpty) return 0;
    return input.trim().split(RegExp(r'\s+')).length;
  }

  /// 统计行数
  static int countLines(String input) {
    if (input.isEmpty) return 0;
    return input.split('\n').length;
  }
}

