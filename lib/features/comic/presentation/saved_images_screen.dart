import 'dart:io';
import 'package:flutter/material.dart';
import '../../../services/image_download_service.dart';

/// 저장된 이미지 관리 화면
class SavedImagesScreen extends StatefulWidget {
  const SavedImagesScreen({super.key});

  @override
  State<SavedImagesScreen> createState() => _SavedImagesScreenState();
}

class _SavedImagesScreenState extends State<SavedImagesScreen> {
  final ImageDownloadService _imageDownloadService = ImageDownloadService.instance;
  List<File> _savedImages = [];
  bool _isLoading = true;
  int _storageUsage = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  /// 저장된 이미지 목록 로드
  Future<void> _loadSavedImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final images = await _imageDownloadService.getSavedImages();
      final usage = await _imageDownloadService.getStorageUsage();
      
      setState(() {
        _savedImages = images;
        _storageUsage = usage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 목록 로드 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 이미지 삭제
  Future<void> _deleteImage(File imageFile) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 삭제'),
        content: const Text('정말 이 이미지를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await _imageDownloadService.deleteSavedImage(imageFile.path);
        await _loadSavedImages(); // 목록 새로고침
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이미지가 삭제되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('이미지 삭제 실패: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 이미지 상세 보기
  void _viewImage(File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(imageFile: imageFile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('저장된 이미지'),
        backgroundColor: const Color(0xFF00D884),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSavedImages,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 저장 공간 사용량 표시
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '저장된 이미지: ${_savedImages.length}개',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '사용 공간: ${_imageDownloadService.formatStorageSize(_storageUsage)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                
                // 이미지 목록
                Expanded(
                  child: _savedImages.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '저장된 이미지가 없습니다',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '만화를 다운로드하면 여기에 표시됩니다',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                          ),
                          itemCount: _savedImages.length,
                          itemBuilder: (context, index) {
                            final imageFile = _savedImages[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => _viewImage(imageFile),
                                child: Stack(
                                  children: [
                                    // 이미지
                                    Image.file(
                                      imageFile,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 50,
                                          ),
                                        );
                                      },
                                    ),
                                    
                                    // 삭제 버튼
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () => _deleteImage(imageFile),
                                        ),
                                      ),
                                    ),
                                    
                                    // 파일명
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withValues(alpha: 0.7),
                                            ],
                                          ),
                                        ),
                                        child: Text(
                                          imageFile.path.split('/').last,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

/// 이미지 상세 보기 화면
class ImageViewerScreen extends StatelessWidget {
  final File imageFile;

  const ImageViewerScreen({
    super.key,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(imageFile.path.split('/').last),
        backgroundColor: const Color(0xFF00D884),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(
            imageFile,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 80,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '이미지를 불러올 수 없습니다',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
