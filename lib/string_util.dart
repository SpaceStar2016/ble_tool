
class StringUtil {

  static List<String> rawSendDataToList(String log) {
    List<String> result = [];

    const key = "发送";
    int index = 0;

    while (true) {
      // 找到 “发送”
      int start = log.indexOf(key, index);
      if (start == -1) break; // 没找到则结束

      // 找到 "<" 的真正起始位置
      start = log.indexOf("<", start);
      if (start == -1) break;

      // 找到对应的 ">"
      int end = log.indexOf(">", start);
      if (end == -1) break;

      // 截取 "<...>" 中间的内容
      String hexStr = log.substring(start + 1, end).trim();
      result.add(hexStr);

      // 更新搜索起点
      index = end + 1;
    }

    return result;
  }
}