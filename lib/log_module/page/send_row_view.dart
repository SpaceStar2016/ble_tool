import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ble_row_detail_view.dart';

class SendRowView extends StatefulWidget {
  final String data;
  final int index;
  const SendRowView({super.key, required this.index, required this.data});

  @override
  State<SendRowView> createState() => _SendRowViewState();
}

class _SendRowViewState extends State<SendRowView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            // color: Color(0xFFD6F7EB),
            // borderRadius: BorderRadius.circular(18),
          ),
          child: Text("第${widget.index}行：", style: TextStyle(fontSize: 18)),
        ),
        SizedBox(width: 10),
        Text("${this.widget.data}", style: TextStyle(fontSize: 18)),
        SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return BleRowDetailView();
                },
              ),
            );
          },
          child: Text("查看", style: TextStyle()),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
