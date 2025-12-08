import 'package:ble_tool/model/ble_log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'model.dart';
import 'objectbox.g.dart'; // created by `dart run build_runner build`

class ObjectBox {
  /// The Store of this app.
  late final Store _store;

  /// A Box of notes.
  late final Box<Note> _noteBox;

  late final Box<BleLog> _bleLogBox;

  ObjectBox._create(this._store) {
    _noteBox = Box<Note>(_store);
    _bleLogBox = Box<BleLog>(_store);
    if (_noteBox.isEmpty()) {
      _putDemoData();
    }
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final store = await openStore(
        directory:
            p.join((await getApplicationDocumentsDirectory()).path, "objectbox-cache"),
        macosApplicationGroup: "objectbox.ble");
    return ObjectBox._create(store);
  }

  void _putDemoData() {
    final demoNotes = [
      Note('Quickly add a note by writing text and pressing Enter'),
      Note('Delete notes by tapping on one'),
      Note('Write a demo app for ObjectBox')
    ];
    _noteBox.putManyAsync(demoNotes);
  }

  Stream<List<BleLog>> getBleLogs(){

    final builder = _bleLogBox.query().order(BleLog_.date, flags: Order.descending);
    // Build and watch the query,
    // set triggerImmediately to emit the query immediately on listen.
    return builder
        .watch(triggerImmediately: true)
    // Map it to a list of notes to be used by a StreamBuilder.
        .map((query) => query.find());
  }

  Stream<List<Note>> getNotes() {
    // Query for all notes, sorted by their date.
    // https://docs.objectbox.io/queries
    final builder = _noteBox.query().order(Note_.date, flags: Order.descending);
    // Build and watch the query,
    // set triggerImmediately to emit the query immediately on listen.
    return builder
        .watch(triggerImmediately: true)
        // Map it to a list of notes to be used by a StreamBuilder.
        .map((query) => query.find());
  }

  /// Add a note.
  ///
  /// To avoid frame drops, run ObjectBox operations that take longer than a
  /// few milliseconds, e.g. putting many objects, asynchronously.
  /// For this example only a single object is put which would also be fine if
  /// done using [Box.put].
  Future<void> addNote(String text) => _noteBox.putAsync(Note(text));

  Future<void> removeNote(int id) => _noteBox.removeAsync(id);
}
