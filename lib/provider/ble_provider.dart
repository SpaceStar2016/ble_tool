
import 'package:ble_tool/model/ble_log.dart';
import 'package:flutter/cupertino.dart';
import '../string_util.dart';

class BleProvider with ChangeNotifier {

  List<BleLog> logs = [];

  String rawData = '';

  List<String> rawSendRows = [];

  List<String> rawReceiveRow = [];

  void setRawData(String data){
    rawData = data;
  }

  void updateRowData(){
    rawSendRows = StringUtil.rawSendDataToList(rawData);
    notifyListeners();
  }




}