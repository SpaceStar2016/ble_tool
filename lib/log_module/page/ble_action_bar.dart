import 'package:ble_tool/main.dart';
import 'package:ble_tool/log_module/model/ble_log.dart';
import 'package:ble_tool/log_module/provider/log_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class BleActionBar extends StatefulWidget {

  final ValueNotifier<bool> canSave;

  const BleActionBar({super.key, required this.canSave});

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
            final provider = Provider.of<LogProvider>(context, listen: false);
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
          },
          child: ValueListenableBuilder(
            valueListenable: widget.canSave,
            builder: (context, value, child) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFD6F7EB),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text("保存", style: value ? TextStyle(fontSize: 24) : TextStyle(fontSize: 24, color: Colors.grey)),
              );
            },
          ),
        ),
        Spacer(),
      ],
    );
  }
}
