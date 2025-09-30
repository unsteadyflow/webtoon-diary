# Supabase 설정 가이드

## 1. Supabase 프로젝트 생성

1. [Supabase 웹사이트](https://supabase.com)에 접속
2. "Start your project" 버튼 클릭
3. GitHub 계정으로 로그인
4. "New Project" 클릭
5. 프로젝트 정보 입력:
   - **Name**: `webtoon-diary`
   - **Database Password**: 안전한 비밀번호 설정 (기록해두세요!)
   - **Region**: `Northeast Asia (Seoul)` 선택
6. "Create new project" 클릭

## 2. 프로젝트 설정 정보 확인

프로젝트 생성 후 다음 정보를 확인하세요:

### API 설정
1. 좌측 메뉴에서 **Settings** > **API** 클릭
2. 다음 정보를 복사하세요:
   - **Project URL** (예: `https://abcdefgh.supabase.co`)
   - **anon public** 키 (예: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

### 데이터베이스 설정
1. 좌측 메뉴에서 **Settings** > **Database** 클릭
2. **Connection string** 섹션에서 **URI** 복사
3. 비밀번호 부분을 실제 비밀번호로 변경하세요

## 3. 환경 변수 설정

### config.env 파일 수정

프로젝트 루트의 `config.env` 파일을 다음과 같이 수정하세요:

```env
# Supabase 설정
SUPABASE_URL=https://your-project-url.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# AI 서버 설정
AI_SERVER_URL=http://127.0.0.1:8000

# 개발 모드 설정
LOCAL_DEV=true
DEBUG_MODE=true
```

### 실제 값 예시

```env
# Supabase 설정
SUPABASE_URL=https://abcdefgh.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NDg5NzI4MDAsImV4cCI6MTk2NDU0ODgwMH0.example-key

# AI 서버 설정
AI_SERVER_URL=http://127.0.0.1:8000

# 개발 모드 설정
LOCAL_DEV=true
DEBUG_MODE=true
```

## 4. 데이터베이스 테이블 생성

Supabase SQL Editor에서 다음 SQL을 실행하세요:

### 사용자 프로필 테이블

```sql
-- 사용자 프로필 테이블
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (id)
);

-- RLS (Row Level Security) 정책 설정
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 프로필만 볼 수 있음
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- 사용자는 자신의 프로필만 업데이트할 수 있음
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- 사용자는 자신의 프로필만 삽입할 수 있음
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
```

### 일기 테이블

```sql
-- 일기 테이블
CREATE TABLE diaries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  mood TEXT, -- 기분 상태
  weather TEXT, -- 날씨
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS 정책 설정
ALTER TABLE diaries ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 일기만 볼 수 있음
CREATE POLICY "Users can view own diaries" ON diaries
  FOR SELECT USING (auth.uid() = user_id);

-- 사용자는 자신의 일기만 생성할 수 있음
CREATE POLICY "Users can create own diaries" ON diaries
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 사용자는 자신의 일기만 업데이트할 수 있음
CREATE POLICY "Users can update own diaries" ON diaries
  FOR UPDATE USING (auth.uid() = user_id);

-- 사용자는 자신의 일기만 삭제할 수 있음
CREATE POLICY "Users can delete own diaries" ON diaries
  FOR DELETE USING (auth.uid() = user_id);
```

### 만화 테이블

```sql
-- 만화 테이블
CREATE TABLE comics (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  diary_id UUID REFERENCES diaries(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT, -- Supabase Storage URL
  style TEXT, -- 만화 스타일
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS 정책 설정
ALTER TABLE comics ENABLE ROW LEVEL SECURITY;

-- 사용자는 자신의 만화만 볼 수 있음
CREATE POLICY "Users can view own comics" ON comics
  FOR SELECT USING (auth.uid() = user_id);

-- 사용자는 자신의 만화만 생성할 수 있음
CREATE POLICY "Users can create own comics" ON comics
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 사용자는 자신의 만화만 업데이트할 수 있음
CREATE POLICY "Users can update own comics" ON comics
  FOR UPDATE USING (auth.uid() = user_id);

-- 사용자는 자신의 만화만 삭제할 수 있음
CREATE POLICY "Users can delete own comics" ON comics
  FOR DELETE USING (auth.uid() = user_id);
```

## 5. Storage 설정

### 버킷 생성

1. Supabase 대시보드에서 **Storage** 클릭
2. "Create a new bucket" 클릭
3. 버킷 정보 입력:
   - **Name**: `comic-images`
   - **Public**: ✅ 체크 (만화 이미지는 공개적으로 접근 가능)
4. "Create bucket" 클릭

### Storage 정책 설정

```sql
-- Storage 정책 설정
CREATE POLICY "Users can upload comic images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'comic-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can view comic images" ON storage.objects
  FOR SELECT USING (bucket_id = 'comic-images');

CREATE POLICY "Users can update own comic images" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'comic-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete own comic images" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'comic-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
```

## 6. 프로젝트 설정 완료 확인

### Flutter 앱 실행

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

### 로그 확인

앱 실행 시 다음과 같은 로그가 나타나야 합니다:

```
🔧 LOCAL_DEV 모드: Supabase 인메모리 클라이언트 사용
```

또는

```
🚀 프로덕션 모드: Supabase 클라이언트 초기화 완료
```

## 7. 개발 모드 vs 프로덕션 모드

### 개발 모드 (LOCAL_DEV=true)
- 실제 Supabase 연결 없이 앱 실행
- 인메모리 클라이언트 사용
- 빠른 개발 및 테스트 가능

### 프로덕션 모드 (LOCAL_DEV=false 또는 주석 처리)
- 실제 Supabase 프로젝트 연결
- 완전한 기능 테스트 가능
- 실제 데이터 저장 및 관리

## 8. 문제 해결

### 일반적인 오류들

1. **"Supabase 설정이 누락되었습니다"**
   - `config.env` 파일에 올바른 URL과 키가 설정되었는지 확인

2. **"Invalid API key"**
   - Supabase 대시보드에서 올바른 anon key를 복사했는지 확인

3. **"Connection refused"**
   - 인터넷 연결 상태 확인
   - Supabase 프로젝트가 활성화되어 있는지 확인

### 지원

문제가 지속되면 다음을 확인하세요:
- [Supabase 공식 문서](https://supabase.com/docs)
- [Flutter Supabase 문서](https://supabase.com/docs/guides/getting-started/flutter)
