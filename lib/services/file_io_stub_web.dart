// 웹 플랫폼용 File, Directory, Platform 스텁
// 웹에서는 dart:io가 없으므로 빈 스텁을 제공합니다.

// 이 파일은 조건부 import로 사용되며, 웹에서는 실제로 사용되지 않습니다.
// 웹 빌드 시 타입 오류를 방지하기 위한 스텁입니다.

// 웹에서는 File, Directory, Platform을 사용하지 않으므로 빈 클래스 정의
class File {
  final String path;
  File(this.path);
  Future<bool> exists() async => false;
  Future<void> writeAsBytes(List<int> bytes) async {}
  Future<void> delete() async {}
  Future<int> length() async => 0;
}

class Directory {
  final String path;
  Directory(this.path);
  Future<bool> exists() async => false;
  Future<void> create({bool recursive = false}) async {}
  Stream<dynamic> list({bool recursive = false}) async* {}
}

class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
}

