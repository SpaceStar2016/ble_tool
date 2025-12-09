import 'package:ble_tool/log_module/page/send_row_view.dart';
import 'package:flutter/material.dart';
import 'package:ble_tool/app_base_page.dart';

import '../../ui_utils.dart';
import '../model/byte_item_model.dart';
import 'ble_action_bar.dart';

class LogRecordPage extends AppBaseStatefulPage {
  const LogRecordPage({super.key});

  @override
  State<LogRecordPage> createState() => _LogRecordPageState();
}

class _LogRecordPageState extends AppBaseStatefulPageState<LogRecordPage> {

  List<ByteItemModel> models = [];

  final canSave = ValueNotifier<bool>(false);

  final _accountController = TextEditingController();

  @override
  Widget body(BuildContext context) {
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
                      // bleProvider.rawData = _accountController.text;
                      // canSave.value = bleProvider.rawData.isNotEmpty;
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
                        itemCount: 10,
                        itemBuilder: (context,index){
                          // final data = rawSendRows[index];
                          // return SendRowView(index: index,data: data);
                        }),
                  ),
                ),
                SizedBox(height: 10),
                BleActionBar(canSave: canSave,),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
