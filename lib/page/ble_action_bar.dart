// import 'package:ble_tool/data_base.dart';
import 'package:ble_tool/model/ble_log.dart';
import 'package:ble_tool/provider/ble_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:objectbox/objectbox.dart';
import 'package:provider/provider.dart';

// import '../objectbox.g.dart';

class BleActionBar extends StatefulWidget {

  const BleActionBar({super.key});

  @override
  State<BleActionBar> createState() => _BleActionBarState();
}

class _BleActionBarState extends State<BleActionBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            final provider = Provider.of<BleProvider>(context, listen: false);
            provider.updateRowData();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFFD6F7EB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text("生成行", style: TextStyle(fontSize: 24)),
          ),
        ),
        SizedBox(width: 20),
        GestureDetector(
          onTap: () async {
            // final db = Database();
            // var bb = BleLog(data: "123",time: "123123");
            // final id = db.put(bb);
            // final all =  db.getAll();
            // print("-------");

          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFFD6F7EB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text("保存", style: TextStyle(fontSize: 24)),
          ),
        ),
        Spacer(),
      ],
    );
  }
}
