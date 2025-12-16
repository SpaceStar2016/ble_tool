
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class BleLog {
  @Id()
  int id;

  String? bleName;
  String data;
  String? remark;  // 备注字段
  String? imagesJson;  // 图片路径JSON数组，最多4张
  DateTime date;

  BleLog({
    this.id = 0,
    this.bleName,
    required this.data,
    this.remark,
    this.imagesJson,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  String get dateFormat => DateFormat('yyyy.MM.dd HH:mm:ss').format(date);

  /// 获取图片路径列表
  List<String> get images {
    if (imagesJson == null || imagesJson!.isEmpty) return [];
    try {
      return List<String>.from(jsonDecode(imagesJson!));
    } catch (e) {
      return [];
    }
  }

  /// 设置图片路径列表
  set images(List<String> paths) {
    if (paths.isEmpty) {
      imagesJson = null;
    } else {
      // 最多保存4张图片
      final limitedPaths = paths.take(4).toList();
      imagesJson = jsonEncode(limitedPaths);
    }
  }

  /// 图片数量
  int get imageCount => images.length;

  /// 是否还能添加图片
  bool get canAddMoreImages => imageCount < 4;
}
