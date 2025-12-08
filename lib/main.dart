// import 'package:ble_tool/data_base.dart';
import 'package:ble_tool/objectbox.dart';
import 'package:ble_tool/page/app.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';


late ObjectBox objectBox;
void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  objectBox = await ObjectBox.create();

  runApp(const App());
}


