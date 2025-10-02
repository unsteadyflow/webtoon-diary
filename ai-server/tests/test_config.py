"""
AI 서버 설정 테스트
"""
import pytest
from app.core.config import Settings


def test_settings_creation():
    """설정 객체 생성 테스트"""
    settings = Settings()
    assert settings is not None


def test_default_values():
    """기본값 테스트"""
    settings = Settings()
    # 기본값들이 올바르게 설정되어 있는지 확인
    assert hasattr(settings, 'app_name')
    assert hasattr(settings, 'debug')
