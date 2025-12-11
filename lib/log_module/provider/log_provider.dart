
import 'package:ble_tool/log_module/model/ble_log.dart';
import 'package:ble_tool/main.dart';
import 'package:flutter/cupertino.dart';
import '../../string_util.dart';

class LogProvider with ChangeNotifier {

  List<BleLog> logs = [];

  String rawData = '';

  List<String> rawSendRows = [];

  List<String> rawReceiveRow = [];


  void fetchLog() async {
     logs = await objectBox.getBleLogs();
     notifyListeners();
  }

  Future<void> deleteLog(int id) async {
    await objectBox.removeBleLog(id);
    logs.removeWhere((log) => log.id == id);
    notifyListeners();
  }

  void setRawData(String data){
    rawData = data;
  }

  void updateRowData(){
    rawSendRows = StringUtil.rawSendDataToList(rawData);
    notifyListeners();
  }




}