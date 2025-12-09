import 'package:ble_tool/log_module/model/ble_log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'model.dart';
import 'objectbox.g.dart'; // created by `dart run build_runner build`

class ObjectBox {
  static ObjectBox? _instance;
  static Future<ObjectBox> create() async {
    if (_instance != null) return _instance!;

    final store = await openStore(
      directory: p.join(
        (await getApplicationDocumentsDirectory()).path,
        "objectbox-cache",
      ),
      macosApplicationGroup: "objectbox.ble",
    );

    final instance = ObjectBox._create(store);
    _instance = instance;
    return instance;
  }

  /// The Store
  final Store store;

  late final Box<Note> noteBox;
  late final Box<BleLog> bleLogBox;

  ObjectBox._create(this.store) {
    noteBox = Box<Note>(store);
    bleLogBox = Box<BleLog>(store);

    if (noteBox.isEmpty()) {
      _putDemoData();
    }
  }

  void _putDemoData() {
    final demoNotes = [
      Note('Quickly add a note by writing text and pressing Enter'),
      Note('Delete notes by tapping on one'),
      Note('Write a demo app for ObjectBox')
    ];
    noteBox.putMany(demoNotes);
  }

  // ---- APIs ----

  Future<List<BleLog>> getBleLogs() {
    final builder = bleLogBox.query()
      ..order(BleLog_.date, flags: Order.descending);
    return builder.build().findAsync();
  }

  Future<int> addBleLog(BleLog log) async {
    final id = await bleLogBox.putAsync(log);
    
    // 淘汰策略：如果超过100条，删除最旧的10条
    final count = bleLogBox.count();
    if (count > 100) {
      // 按时间升序排列（最旧的在前），取前10条删除
      final oldestLogs = bleLogBox
          .query()
          .order(BleLog_.date) // 默认升序，最旧的在前
          .build()
          .find()
          .take(10)
          .map((log) => log.id)
          .toList();
      bleLogBox.removeMany(oldestLogs);
    }
    
    return id;
  }

  Future<void> removeBleLog(int id) => bleLogBox.removeAsync(id);

  Future<void> addNote(String text) => noteBox.putAsync(Note(text));
  Future<void> removeNote(int id) => noteBox.removeAsync(id);

  //todo 添加清空所有记录的API

  /// Important: close on app exit
  void close() {
    store.close();
    _instance = null;
  }
}

