import 'package:ble_tool/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/byte_item_model.dart';

class ByteItem extends StatefulWidget {
  final ByteItemModel item;

  const ByteItem({super.key, required this.item});

  @override
  State<ByteItem> createState() => _ByteItemState();
}

class _ByteItemState extends State<ByteItem> {
  String hexText = "";
  String binaryText = "";
  bool isHex = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    hexText = widget.item.data;
    binaryText = hexToBinary(hexText);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 80, maxWidth: 120),
      child: GestureDetector(
        onTap: () {
          setState(() {
            isHex = !isHex;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: isHex 
                  ? AppTheme.primaryColor.withOpacity(0.5) 
                  : AppTheme.accentColor.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isHex ? AppTheme.primaryColor : AppTheme.accentColor)
                    .withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isHex ? Icons.hexagon_outlined : Icons.memory_rounded,
                    size: 12,
                    color: isHex ? AppTheme.primaryColor : AppTheme.accentColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isHex ? 'HEX' : 'BIN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isHex ? AppTheme.primaryColor : AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                isHex ? hexText : binaryText,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Divider(
                color: AppTheme.dividerColor.withOpacity(0.5),
                height: 12,
              ),
              Text(
                "${widget.item.index}",
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String hexToBinary(String hex) {
    // 去掉空白
    hex = hex.replaceAll(RegExp(r'\s+'), '');
    final buffer = StringBuffer();
    for (var c in hex.split('')) {
      // 每个 hex 字符转 4bit
      final value = int.parse(c, radix: 16);
      buffer.write(value.toRadixString(2).padLeft(4, '0'));
    }

    return buffer.toString();
  }
}
