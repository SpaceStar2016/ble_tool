import 'dart:convert';

/// JSON 处理结果
class JsonResult {
  final bool isValid;
  final String? data;
  final String? errorMessage;
  final int? errorPosition; // 错误位置（字符索引）
  final int? errorLine; // 错误行号
  final int? errorColumn; // 错误列号

  const JsonResult({
    required this.isValid,
    this.data,
    this.errorMessage,
    this.errorPosition,
    this.errorLine,
    this.errorColumn,
  });

  factory JsonResult.success(String data) => JsonResult(
        isValid: true,
        data: data,
      );

  factory JsonResult.error(
    String message, {
    int? position,
    int? line,
    int? column,
  }) =>
      JsonResult(
        isValid: false,
        errorMessage: message,
        errorPosition: position,
        errorLine: line,
        errorColumn: column,
      );

  /// 带有错误标记的数据
  factory JsonResult.errorWithData(
    String message,
    String data, {
    int? position,
    int? line,
    int? column,
  }) =>
      JsonResult(
        isValid: false,
        data: data,
        errorMessage: message,
        errorPosition: position,
        errorLine: line,
        errorColumn: column,
      );
}

/// JSON 工具类
class JsonUtil {
  JsonUtil._();

  /// 校验 JSON 格式
  static JsonResult validate(String input) {
    if (input.trim().isEmpty) {
      return const JsonResult(isValid: false);
    }

    try {
      json.decode(input);
      return const JsonResult(isValid: true);
    } catch (e) {
      final errorInfo = _parseErrorInfo(e.toString(), input);
      return JsonResult.error(
        errorInfo.message,
        position: errorInfo.position,
        line: errorInfo.line,
        column: errorInfo.column,
      );
    }
  }

  /// 格式化 JSON（带缩进）
  static JsonResult format(String input, {String indent = '  '}) {
    if (input.trim().isEmpty) {
      return const JsonResult(isValid: false);
    }

    try {
      final decoded = json.decode(input);
      final encoder = JsonEncoder.withIndent(indent);
      final formatted = encoder.convert(decoded);
      return JsonResult.success(formatted);
    } catch (e) {
      // 解析错误但仍然尝试展开显示并标记错误
      final errorInfo = _parseErrorInfo(e.toString(), input);
      final formattedWithError = _formatWithErrorMark(input, errorInfo);
      return JsonResult.errorWithData(
        errorInfo.message,
        formattedWithError,
        position: errorInfo.position,
        line: errorInfo.line,
        column: errorInfo.column,
      );
    }
  }

  /// 压缩 JSON（去除空白）
  static JsonResult compress(String input) {
    if (input.trim().isEmpty) {
      return const JsonResult(isValid: false);
    }

    try {
      final decoded = json.decode(input);
      final compressed = json.encode(decoded);
      return JsonResult.success(compressed);
    } catch (e) {
      final errorInfo = _parseErrorInfo(e.toString(), input);
      return JsonResult.error(
        errorInfo.message,
        position: errorInfo.position,
        line: errorInfo.line,
        column: errorInfo.column,
      );
    }
  }

  /// 错误信息结构
  static _ErrorInfo _parseErrorInfo(String error, String input) {
    int? position;
    int? line;
    int? column;
    String message = '无效的 JSON 格式';

    // 解析错误位置
    final charMatch = RegExp(r'at character (\d+)').firstMatch(error);
    if (charMatch != null) {
      position = int.tryParse(charMatch.group(1) ?? '');
    }
    
    final lineMatch = RegExp(r'at line (\d+)').firstMatch(error);
    if (lineMatch != null) {
      line = int.tryParse(lineMatch.group(1) ?? '');
    }
    
    final columnMatch = RegExp(r'column (\d+)').firstMatch(error);
    if (columnMatch != null) {
      column = int.tryParse(columnMatch.group(1) ?? '');
    }

    // 如果只有位置信息，计算行列
    if (position != null && line == null) {
      final lineInfo = _getLineAndColumn(input, position);
      line = lineInfo.$1;
      column = lineInfo.$2;
    }

    // 解析错误消息
    if (error.contains('Unexpected character')) {
      message = '语法错误：非法字符';
      if (position != null && position < input.length) {
        final char = input[position];
        message = '语法错误：非法字符 "$char"';
      }
    } else if (error.contains('Expected')) {
      if (error.contains("Expected ':'")) {
        message = '语法错误：缺少冒号 ":"';
      } else if (error.contains("Expected ','")) {
        message = '语法错误：缺少逗号 ","';
      } else if (error.contains("Expected '}'")) {
        message = '语法错误：缺少右花括号 "}"';
      } else if (error.contains("Expected ']'")) {
        message = '语法错误：缺少右方括号 "]"';
      } else {
        message = '语法错误：JSON 格式不正确';
      }
    } else if (error.contains('Unterminated string')) {
      message = '语法错误：字符串未正确闭合（缺少引号）';
    } else if (error.contains('Missing expected')) {
      message = '语法错误：缺少必要的符号';
    } else if (error.contains('Unexpected end of input')) {
      message = '语法错误：JSON 不完整';
    }

    // 添加位置信息到消息
    if (line != null && column != null) {
      message = '$message [第 $line 行, 第 $column 列]';
    } else if (position != null) {
      message = '$message [位置 $position]';
    }

    return _ErrorInfo(
      message: message,
      position: position,
      line: line,
      column: column,
    );
  }

  /// 根据字符位置计算行号和列号
  static (int, int) _getLineAndColumn(String input, int position) {
    if (position <= 0) return (1, 1);
    if (position >= input.length) position = input.length - 1;

    int line = 1;
    int column = 1;
    
    for (int i = 0; i < position && i < input.length; i++) {
      if (input[i] == '\n') {
        line++;
        column = 1;
      } else {
        column++;
      }
    }

    return (line, column);
  }

  /// 格式化并标记错误位置
  static String _formatWithErrorMark(String input, _ErrorInfo errorInfo) {
    // 尝试简单的格式化（添加换行和缩进）
    final formatted = _simpleFormat(input);
    
    // 在错误位置添加标记
    if (errorInfo.line != null) {
      final lines = formatted.split('\n');
      final errorLine = errorInfo.line! - 1;
      
      if (errorLine >= 0 && errorLine < lines.length) {
        // 添加错误标记行
        final errorColumn = errorInfo.column ?? 1;
        final marker = '${' ' * (errorColumn - 1)}↑↑↑ 错误位置';
        lines.insert(errorLine + 1, '▶ $marker');
        
        // 标记错误行
        lines[errorLine] = '▶ ${lines[errorLine]}';
        
        return lines.join('\n');
      }
    }

    return formatted;
  }

  /// 简单格式化（不依赖 JSON 解析）
  static String _simpleFormat(String input) {
    final buffer = StringBuffer();
    int indent = 0;
    bool inString = false;
    bool escaped = false;
    
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      
      if (escaped) {
        buffer.write(char);
        escaped = false;
        continue;
      }
      
      if (char == '\\' && inString) {
        buffer.write(char);
        escaped = true;
        continue;
      }
      
      if (char == '"') {
        inString = !inString;
        buffer.write(char);
        continue;
      }
      
      if (inString) {
        buffer.write(char);
        continue;
      }
      
      // 处理空白字符
      if (char == ' ' || char == '\t' || char == '\n' || char == '\r') {
        continue;
      }
      
      switch (char) {
        case '{':
        case '[':
          buffer.write(char);
          indent++;
          buffer.write('\n');
          buffer.write('  ' * indent);
          break;
        case '}':
        case ']':
          indent--;
          buffer.write('\n');
          buffer.write('  ' * indent);
          buffer.write(char);
          break;
        case ',':
          buffer.write(char);
          buffer.write('\n');
          buffer.write('  ' * indent);
          break;
        case ':':
          buffer.write(': ');
          break;
        default:
          buffer.write(char);
      }
    }
    
    return buffer.toString();
  }

  /// 解析错误信息，返回更友好的提示
  static String _parseError(String error) {
    if (error.contains('Unexpected character')) {
      final match = RegExp(r'at character (\d+)').firstMatch(error);
      if (match != null) {
        return '语法错误：第 ${match.group(1)} 个字符处有非法字符';
      }
    }
    if (error.contains('Expected')) {
      return '语法错误：JSON 格式不正确';
    }
    if (error.contains('Unterminated string')) {
      return '语法错误：字符串未正确闭合';
    }
    if (error.contains('Missing expected')) {
      return '语法错误：缺少必要的符号';
    }
    return '无效的 JSON 格式';
  }

  /// 美化 JSON（4空格缩进）
  static JsonResult beautify(String input) {
    return format(input, indent: '    ');
  }

  /// 检查是否为有效的 JSON
  static bool isValidJson(String input) {
    if (input.trim().isEmpty) return false;
    try {
      json.decode(input);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 获取 JSON 类型
  static String getJsonType(String input) {
    try {
      final decoded = json.decode(input);
      if (decoded is Map) return 'Object';
      if (decoded is List) return 'Array';
      if (decoded is String) return 'String';
      if (decoded is num) return 'Number';
      if (decoded is bool) return 'Boolean';
      if (decoded == null) return 'Null';
      return 'Unknown';
    } catch (_) {
      return 'Invalid';
    }
  }
}

/// 错误信息结构
class _ErrorInfo {
  final String message;
  final int? position;
  final int? line;
  final int? column;

  const _ErrorInfo({
    required this.message,
    this.position,
    this.line,
    this.column,
  });
}

