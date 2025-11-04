// 웹 전용 이미지 다운로드 함수
// 이 파일은 웹에서만 사용되며, 조건부 import로 처리됩니다.

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

