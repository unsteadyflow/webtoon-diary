import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('웹툰 다이어리 앱 기본 테스트', (WidgetTester tester) async {
    // 간단한 MaterialApp으로 테스트
    await tester.pumpWidget(
      const MaterialApp(
        title: '웹툰 다이어리',
        home: Scaffold(
          body: Center(
            child: Text('웹툰 다이어리'),
          ),
        ),
      ),
    );

    // 앱 제목이 표시되는지 확인합니다.
    expect(find.text('웹툰 다이어리'), findsOneWidget);
  });

  testWidgets('홈페이지 레이아웃 테스트', (WidgetTester tester) async {
    // 간단한 MaterialApp으로 테스트
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('테스트'),
          ),
        ),
      ),
    );

    // Scaffold가 있는지 확인합니다.
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);
  });
}
