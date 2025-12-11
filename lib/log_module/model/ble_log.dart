
import 'package:intl/intl.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class BleLog {
  @Id()
  int id;

  String? bleName;
  String data;
  String? remark;  // 新增备注字段
  DateTime date;

  BleLog({
    this.id = 0,
    this.bleName,
    required this.data,
    this.remark,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  String get dateFormat => DateFormat('dd.MM.yyyy HH:mm:ss').format(date);
}
