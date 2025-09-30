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
    expect(find.text('안녕하세요! 👋'), findsOneWidget);
    expect(find.text('오늘의 일상을 재미있는 4컷 만화로 만들어보세요!'), findsOneWidget);

    // LOCAL_DEV 모드 표시가 있는지 확인합니다.
    expect(find.text('LOCAL_DEV'), findsOneWidget);

    // 플로팅 액션 버튼이 있는지 확인합니다.
    expect(find.byType(FloatingActionButton), findsOneWidget);
    
    // 카드들이 있는지 확인합니다 (최소 2개 이상).
    expect(find.byType(Card), findsAtLeastNWidgets(2));
  });

  testWidgets('일기 작성 카드 탭 테스트', (WidgetTester tester) async {
    // 앱을 빌드합니다.
    await tester.pumpWidget(const WebtoonDiaryApp());

    // 일기 작성 카드를 찾아 탭합니다.
    await tester.tap(find.text('일기 작성').first);
    await tester.pump();

    // 다이얼로그가 표시되는지 확인합니다.
    expect(find.text('일기 작성 기능이 곧 추가될 예정입니다!'), findsOneWidget);
  });

  testWidgets('만화 생성 카드 탭 테스트', (WidgetTester tester) async {
    // 앱을 빌드합니다.
    await tester.pumpWidget(const WebtoonDiaryApp());

    // 만화 생성 카드를 찾아 탭합니다.
    await tester.tap(find.text('만화 생성').first);
    await tester.pump();

    // 다이얼로그가 표시되는지 확인합니다.
    expect(find.text('AI 만화 생성 기능이 곧 추가될 예정입니다!'), findsOneWidget);
  });
}
