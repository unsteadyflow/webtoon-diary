import 'dart:io';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'supabase_service.dart';

/// 이미지 다운로드 옵션
enum ImageQuality {
  standard('standard', '기본 해상도'),
  high('high', '고해상도');

  const ImageQuality(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// 이미지 다운로드 및 저장 서비스
class ImageDownloadService {
  static ImageDownloadService? _instance;
  static ImageDownloadService get instance =>
      _instance ??= ImageDownloadService._();

  ImageDownloadService._();

  final SupabaseService _supabaseService = SupabaseService.instance;

  /// 이미지 다운로드 및 저장
  Future<String> downloadAndSaveImage({
    required String imageUrl,
    required String fileName,
    ImageQuality quality = ImageQuality.standard,
  }) async {
    try {
      // 저장 권한 확인 및 요청
      await _requestStoragePermission();

      // 이미지 다운로드
      final imageBytes = await _downloadImage(imageUrl, quality);

      // 로컬 저장 경로 생성
      final savePath = await _getSavePath(fileName);

      // 파일 저장
      final file = File(savePath);
      await file.writeAsBytes(imageBytes);

      return savePath;
    } catch (e) {
      throw Exception('이미지 다운로드 실패: $e');
    }
  }

  /// Supabase Storage에서 이미지 다운로드
  Future<String> downloadFromSupabaseStorage({
    required String bucketName,
    required String fileName,
    ImageQuality quality = ImageQuality.standard,
  }) async {
    try {
      // 저장 권한 확인 및 요청
      await _requestStoragePermission();

      // Supabase Storage에서 다운로드
      final imageBytes = await _supabaseService.client.storage
          .from(bucketName)
          .download(fileName);

      // 로컬 저장 경로 생성
      final savePath = await _getSavePath(fileName);

      // 파일 저장
      final file = File(savePath);
      await file.writeAsBytes(imageBytes);

      return savePath;
    } catch (e) {
      throw Exception('Supabase Storage 다운로드 실패: $e');
    }
  }

  /// 저장 권한 요청
  Future<void> _requestStoragePermission() async {
    // Android에서는 storage 권한, iOS에서는 photos 권한 사용
    Permission permission =
        Platform.isAndroid ? Permission.storage : Permission.photos;

    final status = await permission.request();

    if (status != PermissionStatus.granted) {
      throw Exception('저장 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.');
    }
  }

  /// 이미지 다운로드
  Future<Uint8List> _downloadImage(
      String imageUrl, ImageQuality quality) async {
    try {
      // 해상도에 따른 URL 수정 (실제 구현에서는 서버에서 다른 해상도 제공)
      String downloadUrl = imageUrl;
      if (quality == ImageQuality.high) {
        // 고해상도 이미지 URL 생성 (실제 구현에서는 서버 API 사용)
        downloadUrl = imageUrl.replaceAll('.png', '_high.png');
      }

      final response = await http.get(Uri.parse(downloadUrl));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('이미지 다운로드 실패: HTTP ${response.statusCode}');
      }
    } catch (e) {
      // 고해상도 다운로드 실패 시 기본 해상도로 재시도
      if (quality == ImageQuality.high) {
        return await _downloadImage(imageUrl, ImageQuality.standard);
      }
      rethrow;
    }
  }

  /// 저장 경로 생성
  Future<String> _getSavePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory(path.join(directory.path, 'Downloads'));

    // Downloads 디렉토리가 없으면 생성
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    // 파일명에 타임스탬프 추가하여 중복 방지
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nameWithoutExt = path.basenameWithoutExtension(fileName);
    final extension = path.extension(fileName);
    final uniqueFileName = '${nameWithoutExt}_$timestamp$extension';

    return path.join(downloadsDir.path, uniqueFileName);
  }

  /// 저장된 이미지 목록 조회
  Future<List<File>> getSavedImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory(path.join(directory.path, 'Downloads'));

      if (!await downloadsDir.exists()) {
        return [];
      }

      final files = await downloadsDir.list().toList();
      return files
          .whereType<File>()
          .where((file) => isImageFile(file.path))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 이미지 파일 여부 확인
  bool isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
        .contains(extension);
  }

  /// 저장된 이미지 삭제
  Future<void> deleteSavedImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('이미지 삭제 실패: $e');
    }
  }

  /// 저장 공간 사용량 조회
  Future<int> getStorageUsage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory(path.join(directory.path, 'Downloads'));

      if (!await downloadsDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in downloadsDir.list(recursive: true)) {
        if (entity is File && isImageFile(entity.path)) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// 저장 공간 사용량을 사람이 읽기 쉬운 형태로 변환
  String formatStorageSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
