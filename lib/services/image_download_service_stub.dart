// 비웹 플랫폼용 스텁 파일
// 웹이 아닌 플랫폼에서는 이 파일이 import됩니다.

import 'dart:typed_data';

/// 웹이 아닌 플랫폼에서는 사용되지 않음
String downloadImageOnWeb(Uint8List imageBytes, String fileName) {
  throw UnsupportedError('downloadImageOnWeb is only available on web');
}
