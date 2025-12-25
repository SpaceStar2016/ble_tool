/// 进制转换结果
class RadixResult {
  final bool isSuccess;
  final String? data;
  final String? errorMessage;

  const RadixResult({
    required this.isSuccess,
    this.data,
    this.errorMessage,
  });

  factory RadixResult.success(String data) => RadixResult(
        isSuccess: true,
        data: data,
      );

  factory RadixResult.error(String message) => RadixResult(
        isSuccess: false,
        errorMessage: message,
      );
}

/// 进制类型
enum RadixType {
  binary(2, '二进制', 'BIN'),
  octal(8, '八进制', 'OCT'),
  decimal(10, '十进制', 'DEC'),
  hexadecimal(16, '十六进制', 'HEX');

  final int value;
  final String label;
  final String shortLabel;

  const RadixType(this.value, this.label, this.shortLabel);
}

/// 进制转换工具类
class RadixConvertUtil {
  RadixConvertUtil._();

  /// 通用进制转换
  static RadixResult convert({
    required String input,
    required RadixType fromRadix,
    required RadixType toRadix,
  }) {
    if (input.trim().isEmpty) {
      return const RadixResult(isSuccess: false);
    }

    try {
      // 清理输入：移除空格和前缀
      String cleanInput = input.trim().toUpperCase();
      cleanInput = _removePrefix(cleanInput, fromRadix);
      cleanInput = cleanInput.replaceAll(RegExp(r'\s+'), '');

      // 验证输入是否合法
      if (!_isValidInput(cleanInput, fromRadix)) {
        return RadixResult.error('输入包含非法字符（${fromRadix.label}）');
      }

      // 转换为十进制
      final decimalValue = int.parse(cleanInput, radix: fromRadix.value);

      // 从十进制转换为目标进制
      String result = decimalValue.toRadixString(toRadix.value);

      // 格式化输出
      result = _formatOutput(result, toRadix);

      return RadixResult.success(result);
    } catch (e) {
      return RadixResult.error('转换失败：输入格式错误');
    }
  }

  /// 移除进制前缀
  static String _removePrefix(String input, RadixType radix) {
    switch (radix) {
      case RadixType.binary:
        if (input.startsWith('0B')) return input.substring(2);
        break;
      case RadixType.octal:
        if (input.startsWith('0O')) return input.substring(2);
        if (input.startsWith('0') && input.length > 1 && !input.startsWith('0X')) {
          return input.substring(1);
        }
        break;
      case RadixType.hexadecimal:
        if (input.startsWith('0X')) return input.substring(2);
        break;
      default:
        break;
    }
    return input;
  }

  /// 验证输入是否合法
  static bool _isValidInput(String input, RadixType radix) {
    if (input.isEmpty) return false;

    final validChars = switch (radix) {
      RadixType.binary => RegExp(r'^[01]+$'),
      RadixType.octal => RegExp(r'^[0-7]+$'),
      RadixType.decimal => RegExp(r'^[0-9]+$'),
      RadixType.hexadecimal => RegExp(r'^[0-9A-F]+$'),
    };

    return validChars.hasMatch(input);
  }

  /// 格式化输出
  static String _formatOutput(String output, RadixType radix) {
    switch (radix) {
      case RadixType.binary:
        // 每4位加空格
        return _addSeparator(output.toUpperCase(), 4);
      case RadixType.hexadecimal:
        // 每2位加空格
        return _addSeparator(output.toUpperCase(), 2);
      default:
        return output.toUpperCase();
    }
  }

  /// 添加分隔符
  static String _addSeparator(String input, int groupSize) {
    final buffer = StringBuffer();
    final remainder = input.length % groupSize;

    if (remainder > 0) {
      buffer.write(input.substring(0, remainder));
      if (input.length > remainder) buffer.write(' ');
    }

    for (var i = remainder; i < input.length; i += groupSize) {
      buffer.write(input.substring(i, i + groupSize));
      if (i + groupSize < input.length) buffer.write(' ');
    }

    return buffer.toString();
  }

  // ============ 快捷转换方法 ============

  /// 十进制转二进制
  static RadixResult decToBin(String input) {
    return convert(
      input: input,
      fromRadix: RadixType.decimal,
      toRadix: RadixType.binary,
    );
  }

  /// 十进制转八进制
  static RadixResult decToOct(String input) {
    return convert(
      input: input,
      fromRadix: RadixType.decimal,
      toRadix: RadixType.octal,
    );
  }

  /// 十进制转十六进制
  static RadixResult decToHex(String input) {
    return convert(
      input: input,
      fromRadix: RadixType.decimal,
      toRadix: RadixType.hexadecimal,
    );
  }

  /// 二进制转十进制
  static RadixResult binToDec(String input) {
    return convert(
      input: input,
      fromRadix: RadixType.binary,
      toRadix: RadixType.decimal,
    );
  }

  /// 十六进制转十进制
  static RadixResult hexToDec(String input) {
    return convert(
      input: input,
      fromRadix: RadixType.hexadecimal,
      toRadix: RadixType.decimal,
    );
  }

  /// 十六进制转二进制
  static RadixResult hexToBin(String input) {
    return convert(
      input: input,
      fromRadix: RadixType.hexadecimal,
      toRadix: RadixType.binary,
    );
  }

  /// 二进制转十六进制
  static RadixResult binToHex(String input) {
    return convert(
      input: input,
      fromRadix: RadixType.binary,
      toRadix: RadixType.hexadecimal,
    );
  }
}



