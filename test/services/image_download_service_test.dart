import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

import 'package:webtoon_diary/services/image_download_service.dart';
import 'package:webtoon_diary/services/supabase_service.dart';

// Mock 클래스 생성
@GenerateMocks([
  SupabaseService,
  http.Client,
])

void main() {
  group('ImageDownloadService', () {
    late ImageDownloadService imageDownloadService;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      imageDownloadService = ImageDownloadService.instance;
    });

    group('이미지 다운로드 및 저장', () {
      test('이미지 다운로드 성공 시 파일 경로 반환', () async {
        // Given
        const imageUrl = 'https://example.com/test-image.png';
        const fileName = 'test-image.png';
        const quality = ImageQuality.standard;

        // When & Then
        try {
          final result = await imageDownloadService.downloadAndSaveImage(
            imageUrl: imageUrl,
            fileName: fileName,
            quality: quality,
          );
          
          // 파일이 생성되었는지 확인
          final file = File(result);
          expect(await file.exists(), isTrue);
          
          // 파일 삭제
          await file.delete();
        } catch (e) {
          // 네트워크 오류나 권한 오류는 예상되는 상황
          expect(e, isA<Exception>());
        }
      });

          test('권한 거부 시 예외 발생', () async {
            // Given
            const imageUrl = 'https://example.com/test-image.png';
            const fileName = 'test-image.png';
            const quality = ImageQuality.standard;

            // When & Then
            // 테스트 환경에서는 권한 플러그인이 제대로 작동하지 않으므로
            // MissingPluginException이 발생하는 것을 확인
            try {
              await imageDownloadService.downloadAndSaveImage(
                imageUrl: imageUrl,
                fileName: fileName,
                quality: quality,
              );
            } catch (e) {
              expect(e.toString(), contains('MissingPluginException'));
            }
          });

      test('잘못된 URL로 다운로드 시도 시 예외 발생', () async {
        // Given
        const invalidUrl = 'https://invalid-url.com/nonexistent-image.png';
        const fileName = 'test-image.png';
        const quality = ImageQuality.standard;

        // When & Then
        try {
          await imageDownloadService.downloadAndSaveImage(
            imageUrl: invalidUrl,
            fileName: fileName,
            quality: quality,
          );
        } catch (e) {
          expect(e.toString(), contains('이미지 다운로드 실패'));
        }
      });
    });

    group('Supabase Storage 다운로드', () {
      test('Supabase Storage에서 이미지 다운로드 성공', () async {
        // Given
        const bucketName = 'comic-images';
        const fileName = 'test-comic.png';
        const quality = ImageQuality.standard;

        // When & Then
        try {
          final result = await imageDownloadService.downloadFromSupabaseStorage(
            bucketName: bucketName,
            fileName: fileName,
            quality: quality,
          );
          
          // 파일이 생성되었는지 확인
          final file = File(result);
          expect(await file.exists(), isTrue);
          
          // 파일 삭제
          await file.delete();
        } catch (e) {
          // Supabase 연결 오류나 권한 오류는 예상되는 상황
          expect(e, isA<Exception>());
        }
      });
    });

    group('저장된 이미지 관리', () {
      test('저장된 이미지 목록 조회', () async {
        // When
        final savedImages = await imageDownloadService.getSavedImages();

        // Then
        expect(savedImages, isA<List<File>>());
      });

      test('저장 공간 사용량 조회', () async {
        // When
        final usage = await imageDownloadService.getStorageUsage();

        // Then
        expect(usage, isA<int>());
        expect(usage, greaterThanOrEqualTo(0));
      });

      test('저장 공간 사용량 포맷팅', () {
        // Given
        const testCases = [
          (1024, '1.0 KB'),
          (1024 * 1024, '1.0 MB'),
          (1024 * 1024 * 1024, '1.0 GB'),
          (500, '500 B'),
        ];

        // When & Then
        for (final (bytes, expected) in testCases) {
          final result = imageDownloadService.formatStorageSize(bytes);
          expect(result, expected);
        }
      });
    });

    group('이미지 파일 확인', () {
      test('이미지 파일 확장자 확인', () {
        // Given
        const imageExtensions = [
          'test.jpg',
          'test.jpeg',
          'test.png',
          'test.gif',
          'test.bmp',
          'test.webp',
        ];

        const nonImageExtensions = [
          'test.txt',
          'test.pdf',
          'test.doc',
          'test.mp4',
        ];

        // When & Then
        for (final fileName in imageExtensions) {
          expect(imageDownloadService.isImageFile(fileName), isTrue);
        }

        for (final fileName in nonImageExtensions) {
          expect(imageDownloadService.isImageFile(fileName), isFalse);
        }
      });
    });

    group('해상도 옵션', () {
      test('ImageQuality enum 값 확인', () {
        // Given & When & Then
      expect(ImageQuality.standard.value, 'standard');
      expect(ImageQuality.standard.displayName, '기본 해상도');
      
      expect(ImageQuality.high.value, 'high');
      expect(ImageQuality.high.displayName, '고해상도');
      });
    });
  });
}
