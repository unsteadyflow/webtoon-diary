import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/comic.dart';
import '../../../services/image_download_service.dart';

/// 만화 결과 화면
class ComicResultScreen extends StatelessWidget {
  final Comic comic;

  const ComicResultScreen({
    super.key,
    required this.comic,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(comic.title),
        backgroundColor: const Color(0xFF00D884),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareComic(context),
            tooltip: '공유',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadComic(context),
            tooltip: '다운로드',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 만화 이미지
            _buildComicImage(),

            const SizedBox(height: 24),

            // 만화 정보
            _buildComicInfo(),

            const SizedBox(height: 32),

            // 액션 버튼들
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildComicImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: comic.imageUrl,
          placeholder: (context, url) => Container(
            height: 400,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00D884),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 400,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.error,
                size: 50,
                color: Colors.red,
              ),
            ),
          ),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildComicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comic.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (comic.description != null) ...[
              const SizedBox(height: 8),
              Text(
                comic.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip('스타일', comic.style),
                const SizedBox(width: 8),
                _buildInfoChip(
                    '완성일', _formatDate(comic.completedAt ?? comic.createdAt)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF00D884).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF00D884),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _shareComic(context),
            icon: const Icon(Icons.share),
            label: const Text('공유하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D884),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _downloadComic(context),
            icon: const Icon(Icons.download),
            label: const Text('다운로드'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF00D884),
              side: const BorderSide(color: Color(0xFF00D884)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _shareComic(BuildContext context) {
    // TODO: SNS 공유 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('공유 기능은 추후 구현 예정입니다.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _downloadComic(BuildContext context) async {
    final imageDownloadService = ImageDownloadService.instance;
    
    // 해상도 선택 다이얼로그 표시
    final quality = await showDialog<ImageQuality>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('다운로드 해상도 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('기본 해상도'),
              subtitle: const Text('빠른 다운로드, 적은 용량'),
              leading: const Icon(Icons.image),
              onTap: () => Navigator.pop(context, ImageQuality.standard),
            ),
            ListTile(
              title: const Text('고해상도'),
              subtitle: const Text('느린 다운로드, 큰 용량'),
              leading: const Icon(Icons.high_quality),
              onTap: () => Navigator.pop(context, ImageQuality.high),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (quality == null) return;

    // 로딩 다이얼로그 표시
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('다운로드 중...'),
          ],
        ),
      ),
    );

    try {
      final fileName = '${comic.title}_${DateTime.now().millisecondsSinceEpoch}.png';
      final savePath = await imageDownloadService.downloadAndSaveImage(
        imageUrl: comic.imageUrl,
        fileName: fileName,
        quality: quality,
      );

      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        Navigator.pop(context);
        
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('다운로드 완료!\n저장 위치: $savePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '확인',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      if (context.mounted) {
        Navigator.pop(context);
        
        // 오류 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('다운로드 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '재시도',
              textColor: Colors.white,
              onPressed: () => _downloadComic(context),
            ),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
