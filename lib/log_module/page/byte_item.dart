import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/byte_item_model.dart';



class ByteItem extends StatefulWidget {

  final ByteItemModel item ;

  const ByteItem({super.key,required this.item});

  @override
  State<ByteItem> createState() => _ByteItemState();


}

class _ByteItemState extends State<ByteItem> {

  String hexText = "";
  String binaryText = "";
  bool isHex = true;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    hexText = widget.item.data;
    binaryText = hexToBinary(hexText);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 80,maxWidth: 120),
      child: GestureDetector(
        onTap: (){
          setState(() {
            isHex = !isHex;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4,vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFFD6F7EB),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Text(isHex ? hexText : binaryText),
              Divider(color: Colors.grey.withAlpha(50),),
              Text("${widget.item.index}"),
            ],
          ),
        ),
      ),
    );
  }

  String hexToBinary(String hex) {
    // 去掉空白
    hex = hex.replaceAll(RegExp(r'\s+'), '');
    final buffer = StringBuffer();
    for (var c in hex.split('')) {
      // 每个 hex 字符转 4bit
      final value = int.parse(c, radix: 16);
      buffer.write(value.toRadixString(2).padLeft(4, '0'));
    }

    return buffer.toString();
  }
}
