import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 图片存储工具类
class ImageStorageUtil {
  ImageStorageUtil._();

  static const String _imageFolder = 'log_images';

  /// 获取图片存储目录
  static Future<Directory> getImageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(path.join(appDir.path, _imageFolder));
    
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    
    return imageDir;
  }

  /// 保存图片到应用目录
  /// 返回保存后的图片路径
  static Future<String?> saveImage(File sourceFile) async {
    try {
      final imageDir = await getImageDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(sourceFile.path)}';
      final targetPath = path.join(imageDir.path, fileName);
      
      // 复制文件到应用目录
      await sourceFile.copy(targetPath);
      
      return targetPath;
    } catch (e) {
      print('保存图片失败: $e');
      return null;
    }
  }

  /// 从字节数据保存图片到应用目录（用于剪切板粘贴）
  /// 返回保存后的图片路径
  static Future<String?> saveImageFromBytes(Uint8List bytes, String fileName) async {
    try {
      final imageDir = await getImageDirectory();
      final targetPath = path.join(imageDir.path, fileName);
      
      // 写入文件
      final file = File(targetPath);
      await file.writeAsBytes(bytes);
      
      return targetPath;
    } catch (e) {
      print('保存图片失败: $e');
      return null;
    }
  }

  /// 删除图片
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('删除图片失败: $e');
      return false;
    }
  }

  /// 批量删除图片
  static Future<void> deleteImages(List<String> imagePaths) async {
    for (final imagePath in imagePaths) {
      await deleteImage(imagePath);
    }
  }

  /// 检查图片是否存在
  static Future<bool> imageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}


