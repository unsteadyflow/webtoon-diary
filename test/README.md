# 테스트 가이드

## 테스트 구조

```
test/
├── integration/          # 통합 테스트
│   ├── feed_flow_test.dart
│   └── error_handling_test.dart
├── widgets/             # 위젯 테스트
│   └── feed_screen_test.dart
├── services/            # 서비스 테스트
├── features/            # 기능별 테스트
└── *.dart               # 유닛 테스트
```

## 테스트 실행

### 모든 테스트 실행
```bash
flutter test
```

### 특정 테스트 파일 실행
```bash
flutter test test/integration/feed_flow_test.dart
```

### 커버리지 확인
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 테스트 커버리지 목표

- 전체 커버리지: 80% 이상
- 핵심 비즈니스 로직: 90% 이상
- UI 컴포넌트: 70% 이상

## 테스트 작성 가이드

### 유닛 테스트
- 모델, 서비스, 유틸리티 함수 테스트
- Mock 객체 사용으로 의존성 격리

### 위젯 테스트
- UI 컴포넌트 렌더링 테스트
- 사용자 인터랙션 테스트

### 통합 테스트
- 주요 플로우 테스트 (일기 작성 → 저장 → 피드 조회)
- 에러 핸들링 테스트
- 데이터 동기화 테스트

## 주요 테스트 시나리오

### 1. 일기 작성 플로우
- 일기 생성
- 데이터 검증
- 저장 확인

### 2. 피드 플로우
- 피드 조회
- 데이터 정렬
- 만화 표시

### 3. 에러 핸들링
- 네트워크 오류
- 권한 오류
- 데이터 검증 오류

