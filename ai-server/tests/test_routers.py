"""
AI 서버 라우터 테스트
"""
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_auth_router():
    """인증 라우터 테스트"""
    # 로그인 엔드포인트
    response = client.post("/api/v1/auth/login")
    assert response.status_code in [200, 422]
    
    # 로그아웃 엔드포인트
    response = client.post("/api/v1/auth/logout")
    assert response.status_code == 200


def test_comic_router():
    """만화 라우터 테스트"""
    # 만화 생성 엔드포인트
    response = client.post("/api/v1/comic/generate")
    assert response.status_code in [200, 422]
    
    # 만화 조회 엔드포인트
    response = client.get("/api/v1/comic/1")
    assert response.status_code in [200, 404]


def test_health_router():
    """헬스 체크 라우터 테스트"""
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
