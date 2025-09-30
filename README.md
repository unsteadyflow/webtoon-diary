# 웹툰 다이어리 📖✨

AI를 활용해 사용자의 일상을 재미있는 4컷 만화로 자동 변환하는 혁신적인 다이어리 앱입니다.

## 🎯 프로젝트 개요

- **목표**: AI를 활용하여 사용자의 일상을 재미있는 4컷 만화로 만들어주는 혁신적인 다이어리 앱 개발
- **비전**: 모든 사람들이 쉽고 재미있게 자신의 일상을 기록하고 공유하며 소통하는 세상 만들기
- **타겟 사용자**: 10대 학생, 20-30대 여성

## 🚀 주요 기능

- 📝 **일기 작성 및 저장**: 텍스트로 일기를 작성하고 저장
- 🎨 **AI 기반 4컷 만화 생성**: 작성된 일기를 바탕으로 AI가 4컷 만화 이미지 생성
- 💾 **만화 이미지 다운로드**: 생성된 4컷 만화 이미지 다운로드
- 📱 **SNS 공유**: 생성된 4컷 만화 이미지를 SNS에 공유
- 📚 **일기 및 만화 보관**: 작성한 일기와 생성된 만화 이미지 보관 및 조회
- 🔔 **일기 알림**: 매일 일기를 쓰도록 알림 제공

## 🛠 기술 스택

### Frontend (Flutter)
- **플랫폼**: Flutter (iOS, Android, Web)
- **상태 관리**: Provider
- **백엔드 연동**: Supabase Flutter
- **HTTP 통신**: Dio, HTTP
- **이미지 처리**: Image Picker, Cached Network Image

### Backend
- **데이터베이스**: Supabase PostgreSQL
- **인증**: Supabase Auth
- **스토리지**: Supabase Storage
- **API**: Supabase REST API

### AI Server (Python)
- **프레임워크**: FastAPI
- **서버**: Uvicorn
- **AI 모델**: OpenAI API, DALL-E 3
- **이미지 처리**: Pillow

## 📁 프로젝트 구조

```
webtoon-diary/
├── lib/                          # Flutter 앱 소스코드
│   ├── core/                     # 공통 유틸리티, 상수, 타입 정의
│   │   ├── utils/
│   │   ├── constants/
│   │   └── models/
│   ├── features/                 # 기능별 모듈
│   │   ├── diary/                # 일기 관련 기능
│   │   ├── comic/                 # 만화 생성 관련 기능
│   │   └── auth/                  # 사용자 인증 관련 기능
│   ├── widgets/                  # 재사용 가능한 위젯
│   ├── services/                 # 외부 서비스 연동
│   └── main.dart                 # 앱 시작점
├── ai-server/                    # Python FastAPI AI 서버
│   ├── app/
│   │   ├── routers/              # API 라우터
│   │   ├── models/               # 데이터 모델
│   │   └── services/             # 비즈니스 로직
│   ├── requirements.txt          # Python 의존성
│   └── main.py                   # 서버 시작점
├── vooster-docs/                 # 프로젝트 문서
└── .github/workflows/            # CI/CD 설정
```

## 🚀 시작하기

### 사전 요구사항

- Flutter SDK (3.24.0 이상)
- Dart SDK (3.9.2 이상)
- Python 3.11+
- Git

### 설치 및 실행

1. **저장소 클론**
   ```bash
   git clone <repository-url>
   cd webtoon-diary
   ```

2. **Flutter 의존성 설치**
   ```bash
   flutter pub get
   ```

3. **Python AI 서버 설정**
   ```bash
   cd ai-server
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

4. **환경 변수 설정**
   - `config.env` 파일을 생성하고 필요한 환경 변수 설정
   - Supabase URL 및 API 키 설정
   - OpenAI API 키 설정

5. **앱 실행**
   ```bash
   # Flutter 앱 실행 (웹)
   flutter run -d chrome --web-port 5174
   
   # AI 서버 실행
   cd ai-server
   python main.py
   ```

## 🧪 테스트

### Flutter 테스트
```bash
flutter test
flutter analyze
```

### Python 테스트
```bash
cd ai-server
pytest tests/ -v
```

## 📦 빌드

### Flutter 빌드
```bash
# 웹 빌드
flutter build web --release

# Android 빌드
flutter build apk --release

# iOS 빌드
flutter build ios --release
```

### Python 빌드
```bash
cd ai-server
pip install -r requirements.txt
```

## 🔧 개발 모드

LOCAL_DEV 모드가 활성화되어 있어 개발 시 인증 우회 및 인메모리 스토리지를 사용할 수 있습니다.

- 웹 앱: `http://localhost:5174`
- AI 서버: `http://127.0.0.1:8000`
- API 문서: `http://127.0.0.1:8000/docs`

## 📋 TODO

- [ ] Supabase 프로젝트 설정
- [ ] OpenAI API 연동
- [ ] 실제 AI 만화 생성 로직 구현
- [ ] 사용자 인증 시스템 구현
- [ ] 이미지 업로드 및 저장 기능
- [ ] SNS 공유 기능
- [ ] 푸시 알림 설정

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 연락처

프로젝트 링크: [https://github.com/your-username/webtoon-diary](https://github.com/your-username/webtoon-diary)