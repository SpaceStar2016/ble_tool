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

  /// iOS 提取进制数据（从尖括号中提取十六进制数据）
  /// 例如：从 "发送 <a3000102 5107ff00>" 中提取十六进制数据
  /// 提取后去除空格，每20个字符分为一组换行输出
  static String extractHexDataIOS(String input) {
    if (input.isEmpty) return '';
    
    // 正则匹配尖括号内的内容
    final regex = RegExp(r'<([^>]+)>');
    final matches = regex.allMatches(input);
    
    final hexDataList = <String>[];
    
    for (final match in matches) {
      final content = match.group(1);
      if (content != null && _isHexData(content)) {
        // 去除空格
        final cleanHex = content.replaceAll(RegExp(r'\s'), '');
        // 每20个字符分为一组
        final formattedHex = _splitByLength(cleanHex, 20);
        hexDataList.add(formattedHex);
      }
    }
    
    return hexDataList.join('\n\n');
  }

  /// 按指定长度分割字符串，每组用换行分隔
  static String _splitByLength(String input, int length) {
    if (input.isEmpty) return input;
    if (input.length <= length) return input;
    
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i += length) {
      if (i > 0) buffer.write('\n');
      final end = (i + length > input.length) ? input.length : i + length;
      buffer.write(input.substring(i, end));
    }
    return buffer.toString();
  }

  /// 判断字符串是否为十六进制数据（只包含0-9, a-f, A-F和空格）
  static bool _isHexData(String content) {
    // 去除空格后检查是否只包含十六进制字符
    final cleanContent = content.replaceAll(RegExp(r'\s'), '');
    if (cleanContent.isEmpty) return false;
    
    // 检查是否只包含十六进制字符
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleanContent);
  }

  /// 提取所有尖括号内容（不限于十六进制）
  static String extractBracketContent(String input) {
    if (input.isEmpty) return '';
    
    final regex = RegExp(r'<([^>]+)>');
    final matches = regex.allMatches(input);
    
    final contentList = matches.map((m) => m.group(1) ?? '').where((s) => s.isNotEmpty).toList();
    
    return contentList.join('\n');
  }
}

