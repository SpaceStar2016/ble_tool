import 'package:ble_tool/app_base_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'ble_action_bar.dart';
import 'send_row_view.dart';
import '../../ui_utils.dart';
import '../model/byte_item_model.dart';
import '../provider/log_provider.dart';

class LogListPage extends AppBaseStatefulPage {
  const LogListPage({super.key});

  @override
  State<LogListPage> createState() => _LogPageState();
}

class _LogPageState extends AppBaseStatefulPageState<LogListPage> {
  @override
  void initState() {
    super.initState();
    final logProvider = Provider.of<LogProvider>(context, listen: false);
    logProvider.fetchLog();
  }

  @override
  Widget body(BuildContext context) {
    return Consumer<LogProvider>(builder: (context, bleProvider, child) {
      final rawSendRows = bleProvider.rawSendRows;
      return bleProvider.logs.isEmpty
          ? _noDataView("没有数据")
          : ListView.builder(
              itemCount: bleProvider.logs.length,
              itemBuilder: (ctx, index) {
                final log = bleProvider.logs[index];
                return Text("${log.data}");
              });
    });
  }

  Widget _noDataView(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Png.name('course_empty_placeholder', width: 500 / 3),
          SizedBox(
            height: 12,
          ),
          Text(
            text,
            style: TextStyle(fontSize: 48 / 3, color: Color(0xFFABABAB)),
          ),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  @override
  void Function()? get onBackClick {
    return () {
      Navigator.pop(context);
    };
  }
}
