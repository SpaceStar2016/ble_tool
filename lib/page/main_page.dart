import 'package:ble_tool/log_module/page/log_list_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LogListPage();
                  },
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFD6F7EB),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text("日志记录"),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFD6F7EB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text("其他工具"),
          ),
        ],
      ),
    );
  }
}
