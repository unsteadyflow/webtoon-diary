// 웹툰 다이어리 앱의 기본 위젯 테스트
//
// 위젯과의 상호작용을 테스트하기 위해 flutter_test 패키지의 WidgetTester를 사용합니다.
// 예를 들어, 탭이나 스크롤 제스처를 보낼 수 있습니다. 또한 WidgetTester를 사용하여
// 위젯 트리에서 자식 위젯을 찾고, 텍스트를 읽고, 위젯 속성 값이 올바른지 확인할 수 있습니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:webtoon_diary/main.dart';

void main() {
  testWidgets('웹툰 다이어리 앱 기본 테스트', (WidgetTester tester) async {
    // 앱을 빌드하고 프레임을 트리거합니다.
    await tester.pumpWidget(const WebtoonDiaryApp());

    // 앱 제목이 표시되는지 확인합니다.
    expect(find.text('웹툰 다이어리'), findsOneWidget);
    
    // 환영 메시지가 표시되는지 확인합니다.
    expect(find.text('웹툰 다이어리에 오신 것을 환영합니다!'), findsOneWidget);
    expect(find.text('AI를 활용해 일상을 4컷 만화로 만들어보세요'), findsOneWidget);

    // 아이콘이 표시되는지 확인합니다.
    expect(find.byIcon(Icons.auto_stories), findsOneWidget);
  });

  testWidgets('홈페이지 레이아웃 테스트', (WidgetTester tester) async {
    // 앱을 빌드합니다.
    await tester.pumpWidget(const WebtoonDiaryApp());

    // AppBar가 있는지 확인합니다.
    expect(find.byType(AppBar), findsOneWidget);
    
    // Scaffold가 있는지 확인합니다.
    expect(find.byType(Scaffold), findsOneWidget);
    
    // Center 위젯이 있는지 확인합니다 (최소 1개).
    expect(find.byType(Center), findsAtLeastNWidgets(1));
  });
}
