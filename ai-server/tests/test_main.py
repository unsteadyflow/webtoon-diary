"""
AI 서버 기본 테스트
"""
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_health_check():
    """헬스 체크 엔드포인트 테스트"""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_root_endpoint():
    """루트 엔드포인트 테스트"""
    response = client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()


def test_auth_endpoints():
    """인증 관련 엔드포인트 테스트"""
    # 로그인 엔드포인트 테스트 (실제 구현 전까지는 기본 응답 확인)
    response = client.post("/api/v1/auth/login")
    assert response.status_code in [200, 422]  # 422는 validation error


def test_comic_endpoints():
    """만화 생성 관련 엔드포인트 테스트"""
    # 만화 생성 엔드포인트 테스트 (실제 구현 전까지는 기본 응답 확인)
    response = client.post("/api/v1/comic/generate")
    assert response.status_code in [200, 422]  # 422는 validation error
