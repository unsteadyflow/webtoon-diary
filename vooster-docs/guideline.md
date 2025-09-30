# Webtoon Diary App - Code Guidelines

## 1. Project Overview

This project is a mobile diary application that leverages Flutter for the frontend, Supabase for the backend (including authentication, database, and storage), and Python (FastAPI) for the AI-powered comic generation. The app allows users to create diary entries, which are then transformed into 4-panel comic strips using AI.

Key Architectural Decisions:

*   **Flutter**: Cross-platform mobile development for iOS and Android.
*   **Supabase**: Backend-as-a-Service (BaaS) for authentication, database, and storage.
*   **Python FastAPI**: API framework for the AI comic generation service.
*   **Domain-Driven Design**: Organization around core business domains.

## 2. Core Principles

*   **Maintainability**: Code should be easy to understand, modify, and extend.
*   **Readability**: Code should be clear and self-documenting.
*   **Testability**: Code should be designed to be easily tested (unit, integration, and UI).
*   **Performance**: Code should be efficient and optimized for speed and resource usage.
*   **Security**: Code should be secure and protect user data.

## 3. Language-Specific Guidelines

### 3.1. Flutter (Dart)

#### File Organization and Directory Structure

Follow the Feature-Based Modules structure, as outlined in the TRD:

```
/lib
├── core/                      # 공통 유틸리티, 상수, 타입 정의
│   ├── utils/
│   ├── constants/
│   └── models/
├── features/                 # 기능별 모듈
│   ├── diary/                 # 일기 관련 기능
│   │   ├── presentation/     # UI 컴포넌트
│   │   ├── domain/           # 비즈니스 로직
│   │   ├── data/             # 데이터 접근 및 관리
│   │   └── models/           # 일기 관련 데이터 모델
│   ├── comic/                 # 만화 생성 관련 기능
│   │   ├── presentation/
│   │   ├── domain/
│   │   ├── data/
│   │   └── models/
│   ├── auth/                  # 사용자 인증 관련 기능
│   │   ├── presentation/
│   │   ├── domain/
│   │   ├── data/
│   │   └── models/
│   └── ...
├── widgets/                   # 재사용 가능한 위젯
├── services/                  # 외부 서비스 연동
│   ├── supabase_service.dart
│   ├── ai_server_service.dart
│   └── ...
└── app.dart                   # 앱 시작점
```

#### Import/Dependency Management

*   **MUST** use explicit imports.
*   **MUST** group imports into: Dart SDK, Flutter packages, third-party packages, and project-local files.
*   **MUST** sort imports alphabetically within each group.

```dart
// Dart SDK imports
import 'dart:async';

// Flutter package imports
import 'package:flutter/material.dart';

// Third-party package imports
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports
import 'package:webtoon_diary/core/utils/string_utils.dart';
import 'package:webtoon_diary/features/auth/domain/user_repository.dart';
```

#### Error Handling Patterns

*   **MUST** use `try-catch` blocks for handling potential exceptions.
*   **MUST** provide informative error messages.
*   **MUST** use `FutureBuilder` or `StreamBuilder` to handle asynchronous operations and display appropriate loading/error states.

```dart
Future<void> fetchData() async {
  try {
    final response = await Supabase.instance.client.from('diaries').select('*');
    // Process data
  } catch (e) {
    print('Error fetching data: $e');
    // Display error message to the user
  }
}
```

### 3.2. Python (FastAPI)

#### File Organization and Directory Structure

```
/app
├── main.py          # FastAPI application entry point
├── api/             # API route definitions
│   ├── endpoints/
│   │   ├── comic.py   # Comic generation API endpoints
│   │   └── ...
│   ├── models/
│   │   ├── diary.py   # Diary data models
│   │   └── ...
│   └── utils.py     # Utility functions for API routes
├── services/        # Business logic and external service integrations
│   ├── ai_service.py   # AI model interaction
│   └── supabase_service.py # Supabase interaction
├── core/            # Core utilities and configurations
│   ├── config.py     # Application configuration
│   └── security.py   # Security-related functions
└── tests/           # Unit and integration tests
    ├── api/
    ├── services/
    └── ...
```

#### Import/Dependency Management

*   **MUST** use explicit imports.
*   **MUST** follow PEP 8 guidelines for import ordering.
*   **MUST** use a virtual environment (e.g., `venv`) to manage dependencies.
*   **MUST** use `requirements.txt` to track dependencies.

```python
# Standard library imports
import os

# Third-party library imports
from fastapi import FastAPI, HTTPException
from supabase import create_client, Client

# Local application imports
from app.api.models import DiaryEntry
from app.services.ai_service import generate_comic
from app.core.config import settings
```

#### Error Handling Patterns

*   **MUST** use `try-except` blocks for handling potential exceptions.
*   **MUST** raise appropriate HTTP exceptions using `fastapi.HTTPException`.
*   **MUST** log errors using a logging library (e.g., `logging`).

```python
from fastapi import FastAPI, HTTPException
import logging

logger = logging.getLogger(__name__)

async def get_diary_entry(diary_id: int):
    try:
        # Attempt to retrieve diary entry from database
        diary_entry = await database.fetch_one("SELECT * FROM diaries WHERE id = :diary_id", {"diary_id": diary_id})
        if diary_entry is None:
            raise HTTPException(status_code=404, detail="Diary entry not found")
        return diary_entry
    except Exception as e:
        logger.error(f"Error retrieving diary entry: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")
```

### 3.3. Supabase

*   **MUST** use the Supabase client libraries for Dart and Python.
*   **MUST** handle authentication securely using Supabase Auth.
*   **MUST** use Row Level Security (RLS) policies to control data access.
*   **MUST** validate data on the client-side and server-side before storing it in the database.

## 4. Code Style Rules

### MUST Follow:

*   **Naming Conventions**:
    *   **Classes**: Use `PascalCase`. (e.g., `DiaryEntry`, `ComicGenerator`)
    *   **Functions/Methods**: Use `camelCase`. (e.g., `fetchData`, `generateComic`)
    *   **Variables**: Use `camelCase`. (e.g., `diaryText`, `comicImageURL`)
    *   **Constants**: Use `UPPER_SNAKE_CASE`. (e.g., `DEFAULT_IMAGE_SIZE`, `API_ENDPOINT`)
    *   **Files**: Use `snake_case`. (e.g., `diary_service.dart`, `comic_api.py`)
    *   **Rationale**: Consistency improves readability and predictability.
*   **Comments**:
    *   **MUST** comment complex logic and algorithms.
    *   **MUST** use docstrings for classes, functions, and methods.
    *   **MUST** keep comments up-to-date with the code.
    *   **Rationale**: Comments aid in understanding the code's purpose and functionality.
*   **Code Formatting**:
    *   **MUST** use the official Dart formatter (`dart format`) and Python formatter (`black`) to ensure consistent code formatting.
    *   **MUST** configure IDEs to automatically format code on save.
    *   **Rationale**: Consistent formatting enhances readability and reduces visual noise.
*   **Error Handling**:
    *   **MUST** handle potential errors gracefully and provide informative error messages to the user.
    *   **MUST** log errors for debugging and monitoring purposes.
    *   **Rationale**: Robust error handling prevents crashes and improves the user experience.
*   **Testing**:
    *   **MUST** write unit tests for all critical components and functions.
    *   **MUST** write integration tests to verify the interaction between different modules.
    *   **MUST** use mock objects and test doubles to isolate units under test.
    *   **Rationale**: Testing ensures code correctness and prevents regressions.
*   **Security**:
    *   **MUST** sanitize user inputs to prevent injection attacks.
    *   **MUST** use secure authentication and authorization mechanisms.
    *   **MUST** protect sensitive data using encryption.
    *   **Rationale**: Security is paramount to protect user data and prevent unauthorized access.
*   **State Management (Flutter)**:
    *   **MUST** use a suitable state management solution (e.g., Provider, Riverpod, BLoC) for managing application state.
    *   **MUST** separate UI logic from business logic.
    *   **Rationale**: Proper state management improves code organization, testability, and maintainability.
*   **API Design (Python FastAPI)**:
    *   **MUST** follow RESTful principles for API design.
    *   **MUST** use appropriate HTTP methods (GET, POST, PUT, DELETE).
    *   **MUST** use JSON for data serialization and deserialization.
    *   **MUST** use OpenAPI (Swagger) for API documentation.
    *   **Rationale**: Consistent API design improves usability and maintainability.

### MUST NOT Do:

*   **Global Variables**:
    *   **MUST NOT** use global variables except for truly constant values.
    *   **Rationale**: Global variables introduce state and make code harder to reason about and test.
*   **Nested Callbacks (Callback Hell)**:
    *   **MUST NOT** create deeply nested callbacks.
    *   **MUST** use `async/await` or `Future.then` to handle asynchronous operations in a more readable way.
    *   **Rationale**: Callback hell makes code difficult to read and maintain.
*   **Hardcoded Values**:
    *   **MUST NOT** hardcode values directly in the code.
    *   **MUST** use constants or configuration files to store values that may change.
    *   **Rationale**: Hardcoded values make code less flexible and harder to maintain.
*   **Ignoring Errors**:
    *   **MUST NOT** ignore errors or exceptions.
    *   **MUST** handle errors appropriately and log them for debugging purposes.
    *   **Rationale**: Ignoring errors can lead to unexpected behavior and make it difficult to diagnose problems.
*   **Over-Engineering**:
    *   **MUST NOT** over-engineer solutions or introduce unnecessary complexity.
    *   **MUST** keep the code simple and focused on the problem at hand.
    *   **Rationale**: Over-engineering makes code harder to understand and maintain.
*   **Unnecessary Comments**:
    *   **MUST NOT** write comments that simply restate the code.
    *   **MUST** focus on explaining the *why* rather than the *what*.
    *   **Rationale**: Unnecessary comments clutter the code and make it harder to read.
*   **Complex State Management (Flutter)**:
    *   **MUST NOT** implement overly complex state management solutions for simple UI elements. Use `StatefulWidget` for simple UI state.
    *   **Rationale**: Simplicity is a virtue.

## 5. Architecture Patterns

*   **Component/module structure guidelines**:  As defined in the TRD use Domain-Driven Organization Strategy.
*   **Data flow patterns**: Flutter App -> Supabase Backend (API) or Flutter App -> Python FastAPI AI Server -> Supabase Backend (API).
*   **State management conventions**: Use Provider, Riverpod, or BLoC for managing application state.
*   **API design standards**: RESTful API principles, JSON for data serialization, OpenAPI documentation.

## Example Code Snippets

```dart
// MUST: Using async/await for asynchronous operations
Future<String> fetchComicImage(String diaryText) async {
  try {
    final response = await aiService.generateComic(diaryText);
    return response.imageUrl;
  } catch (e) {
    print('Error generating comic: $e');
    return null;
  }
}
```

```dart
// MUST NOT: Callback hell
void fetchData() {
  api.getData(
    (data) {
      processData(
        data,
        (result) {
          updateUI(result);
        },
      );
    },
  );
}

// MUST: Refactor using async/await
Future<void> fetchDataAsync() async {
  final data = await api.getDataAsync();
  final result = await processDataAsync(data);
  updateUI(result);
}
```

```python
# MUST: Handling exceptions in FastAPI
from fastapi import FastAPI, HTTPException

app = FastAPI()

@app.get("/items/{item_id}")
async def read_item(item_id: int):
    try:
        # Simulate database lookup
        if item_id > 100:
            raise ValueError("Item ID too large")
        return {"item_id": item_id}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal server error")
```

```python
# MUST NOT: Ignoring exceptions
def process_data(data):
    try:
        result = 10 / len(data)  # Potential ZeroDivisionError
        return result
    except:  # Bare except clause - AVOID!
        return None

# MUST: Handle specific exceptions
def process_data(data):
    try:
        result = 10 / len(data)
        return result
    except ZeroDivisionError:
        print("Error: Data list is empty")
        return None
    except TypeError:
        print("Error: Invalid data type")
        return None
```
