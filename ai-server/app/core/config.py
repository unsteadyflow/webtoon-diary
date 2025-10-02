"""
AI 서버 설정 파일
"""

import os
from typing import Optional
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    """애플리케이션 설정"""
    
    # 서버 설정
    app_name: str = "웹툰 다이어리 AI 서버"
    debug: bool = True
    host: str = "127.0.0.1"
    port: int = 8000
    
    # OpenAI 설정
    openai_api_key: Optional[str] = None
    
    # Supabase 설정
    supabase_url: Optional[str] = None
    supabase_key: Optional[str] = None
    
    # 데이터베이스 설정
    database_url: Optional[str] = None
    
    # 보안 설정
    secret_key: str = "your-secret-key-here"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    class Config:
        env_file = ".env"
        case_sensitive = False

# 전역 설정 인스턴스
settings = Settings()
