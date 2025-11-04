// 웹 전용 이미지 다운로드 함수
// 이 파일은 웹에서만 사용되며, 조건부 import로 처리됩니다.
// NOTE: dart:html은 deprecated되었지만, Flutter 웹에서 아직 널리 사용되므로
//       향후 package:web으로 마이그레이션 예정

// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:typed_data';

/// 웹에서 이미지 다운로드 (별도 파일로 분리)
String downloadImageOnWeb(Uint8List imageBytes, String fileName) {
  final blob = html.Blob([imageBytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName);
  anchor.click();
  html.Url.revokeObjectUrl(url);
  return fileName;
}
