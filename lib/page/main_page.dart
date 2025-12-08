import 'package:ble_tool/page/send_row_view.dart';
import 'package:ble_tool/provider/ble_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/byte_item_model.dart';
import '../ora_dialog.dart';
import '../string_util.dart';
import '../ui_utils.dart';
import 'ble_action_bar.dart';
import 'byte_item.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  List<ByteItemModel> models = [];

  final _accountController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Consumer<BleProvider>(
      builder: (context, bleProvider, child) {
        final rawSendRows = bleProvider.rawSendRows;
        return Row(
          children: [
            Container(
              width: 100,
              color: Colors.yellow,
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, w) {
                  return Text("Hello, ble_tool");
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    SizedBox(height: 20,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                      decoration: BoxDecoration(
                        color: Color(0xFFD6F7EB),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TextField(
                        onChanged: (text) {
                          bleProvider.rawData = _accountController.text;
                        },
                        style: TextStyle(
                          fontSize: 18
                        ),
                        controller: _accountController,
                        maxLines: 8,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: "请输入",
                          suffixIcon: Offstage(
                            offstage: _accountController.text.isEmpty,
                            child: IconButton(
                              constraints: const BoxConstraints(minWidth: 36),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _accountController.text = '';
                                models = [];
                                setState(() {});
                              },
                              icon: SizedBox(
                                width: 16,
                                height: 16,
                                child: Png.name('mine_input_clean'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                        decoration: BoxDecoration(
                          color: Color(0xFFD6F7EB),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListView.builder(
                          itemCount: rawSendRows.length,
                            itemBuilder: (context,index){
                            final data = rawSendRows[index];
                            return SendRowView(index: index,data: data);
                        }),
                      ),
                    ),
                    SizedBox(height: 10),
                    BleActionBar(),
                    SizedBox(height: 10),
                    // Divider(color: Colors.grey.withAlpha(100),),
                    // SizedBox(height: 10),
                    // Wrap(
                    //   spacing: 10,
                    //   runSpacing: 20,
                    //   children: [
                    //     ...models.map((e){
                    //       return ByteItem(item: e);
                    //     }).toList()
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }



  String extractLastBrackets(String input) {
    if (input.isEmpty){
      return "";
    }
    final start = input.lastIndexOf('<');
    if(start == -1){
      showDialog(
        barrierDismissible: true,
        useSafeArea: false,
        context: context,
        builder: (context) {
          return OraDialog.simpleText(
            "格式化错误",
          );
        },
      );
      return "";
    }
    final end = input.lastIndexOf('>');
    if(end == -1){
      showDialog(
        barrierDismissible: true,
        useSafeArea: false,
        context: context,
        builder: (context) {
          return OraDialog.simpleText(
            "格式化错误",
          );
        },
      );
      return "";
    }
    if (start == -1 || end == -1 || end <= start) {
      return '';
    }
    return input.substring(start + 1, end).trim();
  }

  List<ByteItemModel> formatHexToModels(String input) {
    // 去掉空白
    String s = input.replaceAll(RegExp(r'\s+'), '');

    final result = <ByteItemModel>[];
    int idx = 0;

    for (int i = 0; i < s.length; i += 2) {
      String part;

      if (i + 2 > s.length) {
        // 剩余 1 位
        part = s.substring(i);
      } else {
        part = s.substring(i, i + 2);
      }

      result.add(ByteItemModel(
        data: part,
        index: idx.toString(),
      ));

      idx += 1;
    }
    return result;
  }
}
