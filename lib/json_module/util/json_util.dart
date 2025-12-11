import 'dart:convert';

/// JSON 处理结果
class JsonResult {
  final bool isValid;
  final String? data;
  final String? errorMessage;

  const JsonResult({
    required this.isValid,
    this.data,
    this.errorMessage,
  });

  factory JsonResult.success(String data) => JsonResult(
        isValid: true,
        data: data,
      );

  factory JsonResult.error(String message) => JsonResult(
        isValid: false,
        errorMessage: message,
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
      return JsonResult.error(_parseError(e.toString()));
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
      return JsonResult.error(_parseError(e.toString()));
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
      return JsonResult.error(_parseError(e.toString()));
    }
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

