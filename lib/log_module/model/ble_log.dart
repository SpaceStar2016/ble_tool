
import 'package:intl/intl.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class BleLog {
  @Id()
  int id;

  String? bleName;
  String data;
  DateTime date;

  BleLog({
    this.id = 0,
    this.bleName,
    required this.data,
    DateTime? date,
  }) : date = date ?? DateTime.now();  // 构造函数结束要加分号

  String get dateFormat => DateFormat('dd.MM.yyyy HH:mm:ss').format(date);
}