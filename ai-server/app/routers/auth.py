"""
인증 라우터
"""

from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional

router = APIRouter()

class LoginRequest(BaseModel):
    email: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str

@router.post("/auth/login", response_model=TokenResponse)
async def login(request: LoginRequest):
    """사용자 로그인"""
    # TODO: 실제 인증 로직 구현
    if request.email == "test@example.com" and request.password == "password":
        return TokenResponse(
            access_token="dummy-token",
            token_type="bearer"
        )
    raise HTTPException(status_code=401, detail="Invalid credentials")

@router.post("/auth/logout")
async def logout():
    """사용자 로그아웃"""
    return {"message": "Successfully logged out"}
