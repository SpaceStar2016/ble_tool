import 'dart:convert';

/// Base64 转换结果
class Base64Result {
  final bool isSuccess;
  final String? data;
  final String? errorMessage;

  const Base64Result({
    required this.isSuccess,
    this.data,
    this.errorMessage,
  });

  factory Base64Result.success(String data) => Base64Result(
        isSuccess: true,
        data: data,
      );

  factory Base64Result.error(String message) => Base64Result(
        isSuccess: false,
        errorMessage: message,
      );
}

/// Base64 工具类
class Base64Util {
  Base64Util._();

  /// Base64 解码为 Hex 字符串
  /// 输出格式：每字节空格分隔，大写（如：48 65 6C 6C 6F）
  static Base64Result base64ToHex(String input) {
    if (input.trim().isEmpty) {
      return const Base64Result(isSuccess: false);
    }

    try {
      final bytes = base64Decode(input.trim());
      final hex = bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
          .join(' ');
      return Base64Result.success(hex);
    } catch (e) {
      return Base64Result.error('无效的 Base64 字符串');
    }
  }

  /// Hex 字符串编码为 Base64
  /// 支持输入格式：带空格或不带空格（如：48 65 6C 6C 6F 或 48656C6C6F）
  static Base64Result hexToBase64(String input) {
    if (input.trim().isEmpty) {
      return const Base64Result(isSuccess: false);
    }

    try {
      // 移除所有空白字符
      final hexString = input.replaceAll(RegExp(r'\s+'), '');
      
      // 检查长度是否为偶数
      if (hexString.length % 2 != 0) {
        return Base64Result.error('Hex 长度必须为偶数');
      }
      
      // 检查是否为有效的十六进制字符
      if (!RegExp(r'^[0-9A-Fa-f]+$').hasMatch(hexString)) {
        return Base64Result.error('包含非法的十六进制字符');
      }

      // 转换为字节数组
      final bytes = <int>[];
      for (var i = 0; i < hexString.length; i += 2) {
        bytes.add(int.parse(hexString.substring(i, i + 2), radix: 16));
      }
      
      final base64Str = base64Encode(bytes);
      return Base64Result.success(base64Str);
    } catch (e) {
      return Base64Result.error('无效的 Hex 字符串');
    }
  }

  /// Base64 解码为普通字符串（UTF-8）
  static Base64Result base64ToString(String input) {
    if (input.trim().isEmpty) {
      return const Base64Result(isSuccess: false);
    }

    try {
      final bytes = base64Decode(input.trim());
      final str = utf8.decode(bytes);
      return Base64Result.success(str);
    } catch (e) {
      return Base64Result.error('无效的 Base64 字符串或无法解码为 UTF-8');
    }
  }

  /// 普通字符串编码为 Base64
  static Base64Result stringToBase64(String input) {
    if (input.isEmpty) {
      return const Base64Result(isSuccess: false);
    }

    try {
      final bytes = utf8.encode(input);
      final base64Str = base64Encode(bytes);
      return Base64Result.success(base64Str);
    } catch (e) {
      return Base64Result.error('编码失败');
    }
  }

  /// Base64 解码为字节数组
  static List<int>? base64ToBytes(String input) {
    try {
      return base64Decode(input.trim());
    } catch (_) {
      return null;
    }
  }

  /// 字节数组编码为 Base64
  static String bytesToBase64(List<int> bytes) {
    return base64Encode(bytes);
  }

  /// 检查是否为有效的 Base64 字符串
  static bool isValidBase64(String input) {
    if (input.trim().isEmpty) return false;
    try {
      base64Decode(input.trim());
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 检查是否为有效的 Hex 字符串
  static bool isValidHex(String input) {
    final hexString = input.replaceAll(RegExp(r'\s+'), '');
    if (hexString.isEmpty) return false;
    if (hexString.length % 2 != 0) return false;
    return RegExp(r'^[0-9A-Fa-f]+$').hasMatch(hexString);
  }

  /// Hex 字符串转字节数组
  static List<int>? hexToBytes(String input) {
    try {
      final hexString = input.replaceAll(RegExp(r'\s+'), '');
      if (hexString.length % 2 != 0) return null;
      
      final bytes = <int>[];
      for (var i = 0; i < hexString.length; i += 2) {
        bytes.add(int.parse(hexString.substring(i, i + 2), radix: 16));
      }
      return bytes;
    } catch (_) {
      return null;
    }
  }

  /// 字节数组转 Hex 字符串
  static String bytesToHex(List<int> bytes, {bool uppercase = true, String separator = ' '}) {
    return bytes
        .map((b) {
          final hex = b.toRadixString(16).padLeft(2, '0');
          return uppercase ? hex.toUpperCase() : hex;
        })
        .join(separator);
  }
}



