import 'dart:io';

import 'package:ble_tool/app_base_page.dart';
import 'package:ble_tool/log_module/model/ble_log.dart';
import 'package:ble_tool/log_module/util/image_storage_util.dart';
import 'package:ble_tool/main.dart';
import 'package:ble_tool/theme/app_theme.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class BleLogEditPage extends AppBaseStatefulPage {
  final BleLog? bleLog;  // 可选参数，传入时为编辑模式

  const BleLogEditPage({super.key, this.bleLog});

  @override
  State<BleLogEditPage> createState() => _BleLogEditPageState();
}

class _BleLogEditPageState extends AppBaseStatefulPageState<BleLogEditPage> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();
  final FocusNode _remarkFocusNode = FocusNode();

  // 图片路径列表（最多4张）
  List<String> _imagePaths = [];
  // 待删除的原有图片（编辑模式下）
  List<String> _imagesToDelete = [];
  // 是否正在拖拽
  bool _isDragging = false;

  // 最大图片大小：1MB
  static const int maxImageSizeBytes = 1 * 1024 * 1024;

  bool get isEditMode => widget.bleLog != null;
  bool get canAddMoreImages => _imagePaths.length < 4;

  @override
  String get pageTitle => isEditMode ? '编辑日志' : '新增日志';

  @override
  List<Widget>? get navigatorRightWidget => [
        TextButton(
          onPressed: _saveLog,
          child: const Text(
            '保存',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ];

  @override
  void Function()? get onBackClick {
    return () {
      Navigator.pop(context);
    };
  }

  @override
  void initState() {
    super.initState();
    // 如果是编辑模式，填充已有数据
    if (isEditMode) {
      _contentController.text = widget.bleLog!.data;
      _remarkController.text = widget.bleLog!.remark ?? '';
      _imagePaths = List.from(widget.bleLog!.images);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _remarkController.dispose();
    _contentFocusNode.dispose();
    _remarkFocusNode.dispose();
    super.dispose();
  }

  /// 获取友好的文件大小显示
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// 检查是否为图片文件
  bool _isImageFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png') ||
        ext.endsWith('.gif') ||
        ext.endsWith('.webp') ||
        ext.endsWith('.bmp');
  }

  /// 添加单个图片文件
  Future<bool> _addImageFile(File file) async {
    if (!canAddMoreImages) {
      _showError('最多只能添加4张图片');
      return false;
    }

    // 检查文件大小
    final fileSize = await file.length();
    if (fileSize > maxImageSizeBytes) {
      _showError('图片大小不能超过1MB，当前大小: ${_formatFileSize(fileSize)}');
      return false;
    }

    // 保存图片到应用目录
    final savedPath = await ImageStorageUtil.saveImage(file);
    if (savedPath != null) {
      setState(() {
        _imagePaths.add(savedPath);
      });
      return true;
    }
    return false;
  }

  /// 使用文件选择器选择图片
  Future<void> _pickImageFromFile() async {
    if (!canAddMoreImages) {
      _showError('最多只能添加4张图片');
      return;
    }

    const XTypeGroup imageTypeGroup = XTypeGroup(
      label: '图片',
      extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'],
    );

    try {
      final List<XFile> files = await openFiles(
        acceptedTypeGroups: [imageTypeGroup],
      );

      if (files.isEmpty) return;

      int addedCount = 0;
      int skippedCount = 0;

      for (final xFile in files) {
        if (!canAddMoreImages) {
          skippedCount += files.length - addedCount - skippedCount;
          break;
        }

        final file = File(xFile.path);
        final fileSize = await file.length();

        if (fileSize > maxImageSizeBytes) {
          skippedCount++;
          continue;
        }

        final savedPath = await ImageStorageUtil.saveImage(file);
        if (savedPath != null) {
          setState(() {
            _imagePaths.add(savedPath);
          });
          addedCount++;
        }
      }

      // 显示结果
      if (addedCount > 0 && skippedCount == 0) {
        _showSuccess('成功添加 $addedCount 张图片');
      } else if (addedCount > 0 && skippedCount > 0) {
        _showError('添加了 $addedCount 张图片，$skippedCount 张超过1MB被跳过');
      } else if (skippedCount > 0) {
        _showError('所有图片都超过1MB限制');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('选择图片失败: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  /// 处理拖拽的文件
  Future<void> _handleDroppedFiles(DropDoneDetails details) async {
    final files = details.files;
    
    if (files.isEmpty) return;

    int addedCount = 0;
    int skippedCount = 0;
    String? errorMessage;

    for (final droppedFile in files) {
      if (!canAddMoreImages) {
        skippedCount += files.length - addedCount - skippedCount;
        errorMessage = '已达到图片数量上限';
        break;
      }

      final filePath = droppedFile.path;

      // 检查是否为图片文件
      if (!_isImageFile(filePath)) {
        skippedCount++;
        continue;
      }

      final file = File(filePath);

      // 检查文件是否存在
      if (!await file.exists()) {
        skippedCount++;
        continue;
      }

      // 检查文件大小
      final fileSize = await file.length();
      if (fileSize > maxImageSizeBytes) {
        skippedCount++;
        errorMessage = '部分图片大小超过1MB限制';
        continue;
      }

      // 保存图片
      final savedPath = await ImageStorageUtil.saveImage(file);
      if (savedPath != null) {
        setState(() {
          _imagePaths.add(savedPath);
        });
        addedCount++;
      }
    }

    // 显示结果
    if (addedCount > 0 && skippedCount == 0) {
      _showSuccess('成功添加 $addedCount 张图片');
    } else if (addedCount > 0 && skippedCount > 0) {
      _showError('添加了 $addedCount 张图片，$skippedCount 张被跳过${errorMessage != null ? "（$errorMessage）" : ""}');
    } else if (skippedCount > 0) {
      _showError(errorMessage ?? '没有有效的图片文件');
    }
  }

  void _removeImage(int index) {
    setState(() {
      final removedPath = _imagePaths.removeAt(index);
      // 如果是编辑模式且删除的是原有图片，记录下来后续删除
      if (isEditMode && widget.bleLog!.images.contains(removedPath)) {
        _imagesToDelete.add(removedPath);
      } else {
        // 新添加的图片直接删除文件
        ImageStorageUtil.deleteImage(removedPath);
      }
    });
  }

  void _showImagePreview(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ImagePreviewPage(
          imagePaths: _imagePaths,
          initialIndex: index,
        ),
      ),
    );
  }

  void _saveLog() async {
    final content = _contentController.text.trim();
    final remark = _remarkController.text.trim();

    if (content.isEmpty) {
      _showError('请输入日志内容');
      return;
    }

    // 删除标记为删除的图片
    if (_imagesToDelete.isNotEmpty) {
      await ImageStorageUtil.deleteImages(_imagesToDelete);
    }

    // 创建或更新 BleLog 对象
    final bleLog = BleLog(
      id: isEditMode ? widget.bleLog!.id : 0,  // 编辑模式保留原 id
      data: content,
      remark: remark.isNotEmpty ? remark : null,
      date: isEditMode ? widget.bleLog!.date : null,  // 编辑模式保留原日期
    );
    bleLog.images = _imagePaths;

    // 保存到数据库
    await objectBox.addBleLog(bleLog);

    if (!mounted) return;

    _showSuccess(isEditMode ? '更新成功' : '保存成功');

    Navigator.pop(context, true);  // 返回 true 表示有数据变更
  }

  @override
  Widget body(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击空白区域收起键盘
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 编辑模式显示日志信息
            if (isEditMode) ...[
              _buildInfoCard(),
              const SizedBox(height: AppTheme.spacingLarge),
            ],

            // 内容输入区域
            _buildSectionTitle('日志内容', icon: Icons.edit_note_rounded, required: true),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildContentInput(),
            const SizedBox(height: AppTheme.spacingLarge),

            // 备注输入区域
            _buildSectionTitle('备注', icon: Icons.sticky_note_2_outlined),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildRemarkInput(),
            const SizedBox(height: AppTheme.spacingLarge),

            // 图片区域
            _buildSectionTitle(
              '图片 (${_imagePaths.length}/4)',
              icon: Icons.image_rounded,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildImageSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '创建时间',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.bleLog!.dateFormat,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required IconData icon, bool required = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              color: AppTheme.errorColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildContentInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _contentController,
        focusNode: _contentFocusNode,
        maxLines: 8,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
        decoration: const InputDecoration(
          hintText: '请输入日志内容...',
          hintStyle: TextStyle(
            color: AppTheme.textHint,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppTheme.spacingMedium),
        ),
        onSubmitted: (_) {
          _remarkFocusNode.requestFocus();
        },
      ),
    );
  }

  Widget _buildRemarkInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _remarkController,
        focusNode: _remarkFocusNode,
        maxLines: 4,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
        decoration: const InputDecoration(
          hintText: '添加备注信息（可选）...',
          hintStyle: TextStyle(
            color: AppTheme.textHint,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppTheme.spacingMedium),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return DropTarget(
      onDragDone: _handleDroppedFiles,
      onDragEntered: (details) {
        setState(() {
          _isDragging = true;
        });
      },
      onDragExited: (details) {
        setState(() {
          _isDragging = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: _isDragging 
              ? AppTheme.primaryColor.withOpacity(0.1) 
              : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: _isDragging 
                ? AppTheme.primaryColor 
                : AppTheme.borderColor.withOpacity(0.5),
            width: _isDragging ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // 图片网格
            if (_imagePaths.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _imagePaths.length,
                itemBuilder: (context, index) => _buildImageItem(index),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
            ],

            // 拖拽提示或添加按钮
            if (canAddMoreImages)
              _buildDropZone()
            else
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '已达到图片数量上限',
                      style: TextStyle(
                        color: AppTheme.textHint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZone() {
    return GestureDetector(
      onTap: _pickImageFromFile,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: _isDragging 
                ? AppTheme.primaryColor.withOpacity(0.15) 
                : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: _isDragging 
                  ? AppTheme.primaryColor 
                  : AppTheme.primaryColor.withOpacity(0.3),
              width: _isDragging ? 2 : 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isDragging 
                    ? Icons.file_download_rounded 
                    : Icons.add_photo_alternate_rounded,
                color: AppTheme.primaryColor,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                _isDragging ? '松开以添加图片' : '拖拽图片到此处',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '或点击选择图片（最大 1MB）',
                style: TextStyle(
                  color: AppTheme.textHint,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '支持 JPG、PNG、GIF、WebP 格式',
                style: TextStyle(
                  color: AppTheme.textHint.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    final imagePath = _imagePaths[index];

    return GestureDetector(
      onTap: () => _showImagePreview(index),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          children: [
            // 图片
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.surfaceColor,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: AppTheme.textHint,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
            // 删除按钮
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 图片预览页面
class _ImagePreviewPage extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const _ImagePreviewPage({
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  State<_ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<_ImagePreviewPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.imagePaths.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imagePaths.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.file(
                File(widget.imagePaths[index]),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_rounded,
                        color: Colors.white54,
                        size: 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '图片加载失败',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
