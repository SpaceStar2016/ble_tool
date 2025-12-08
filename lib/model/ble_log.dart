
import 'package:objectbox/objectbox.dart';

@Entity()
class BleLog {
  @Id()
  int id;
  String? bleName;
  String data;
  String time;

  BleLog({this.id = 0, required this.data, required this.time});
}