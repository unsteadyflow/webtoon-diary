"""
만화 생성 라우터
"""

from fastapi import APIRouter, HTTPException, BackgroundTasks
from pydantic import BaseModel
from typing import List, Optional
import uuid
import asyncio
import os
from datetime import datetime
import openai
from supabase import create_client, Client
from app.core.config import settings

router = APIRouter()

# Supabase 클라이언트 초기화 (테스트 환경에서는 더미 값 사용)
if settings.supabase_url and settings.supabase_key:
    supabase: Client = create_client(settings.supabase_url, settings.supabase_key)
else:
    # 테스트 환경에서는 더미 클라이언트 사용
    supabase: Client = None

# OpenAI 클라이언트 초기화
openai.api_key = settings.openai_api_key

class ComicGenerationRequest(BaseModel):
    diary_id: str
    content: str
    title: Optional[str] = None
    mood: Optional[str] = None
    weather: Optional[str] = None
    location: Optional[str] = None
    style: str = "cute"  # cute, comic, emotional

class ComicGenerationResponse(BaseModel):
    comic_id: str
    status: str
    estimated_time_seconds: Optional[int] = None
    message: str

class ComicStatus(BaseModel):
    id: str
    diary_id: str
    user_id: str
    title: str
    description: Optional[str] = None
    image_url: str
    style: str
    status: str
    created_at: str
    completed_at: Optional[str] = None
    estimated_time_seconds: Optional[int] = None
    error_message: Optional[str] = None

# 메모리 내 작업 상태 저장 (실제 환경에서는 Redis 사용 권장)
comic_tasks = {}

@router.post("/comic/generate", response_model=ComicGenerationResponse)
async def generate_comic(request: ComicGenerationRequest, background_tasks: BackgroundTasks):
    """일기 내용을 기반으로 4컷 만화 생성 요청"""
    
    comic_id = str(uuid.uuid4())
    
    # 작업 상태 초기화
    comic_tasks[comic_id] = {
        "status": "pending",
        "created_at": datetime.now(),
        "estimated_time_seconds": 60,  # 기본 60초 추정
        "error_message": None
    }
    
    # 백그라운드에서 만화 생성 작업 시작
    background_tasks.add_task(process_comic_generation, comic_id, request)
    
    return ComicGenerationResponse(
        comic_id=comic_id,
        status="pending",
        estimated_time_seconds=60,
        message="만화 생성이 시작되었습니다."
    )

async def process_comic_generation(comic_id: str, request: ComicGenerationRequest):
    """백그라운드에서 만화 생성 처리"""
    try:
        # 작업 상태를 processing으로 변경
        comic_tasks[comic_id]["status"] = "processing"
        
        # 일기 내용을 만화 프롬프트로 변환
        comic_prompt = await generate_comic_prompt(request)
        
        # DALL-E 3를 사용하여 4컷 만화 생성
        image_url = await generate_comic_image(comic_prompt, request.style)
        
        # Supabase Storage에 이미지 업로드
        storage_url = await upload_to_supabase_storage(comic_id, image_url)
        
        # 데이터베이스에 만화 정보 저장
        await save_comic_to_database(comic_id, request, storage_url)
        
        # 작업 완료
        comic_tasks[comic_id]["status"] = "completed"
        comic_tasks[comic_id]["completed_at"] = datetime.now()
        
    except Exception as e:
        # 오류 발생 시 상태 업데이트
        comic_tasks[comic_id]["status"] = "failed"
        comic_tasks[comic_id]["error_message"] = str(e)

async def generate_comic_prompt(request: ComicGenerationRequest) -> str:
    """일기 내용을 만화 프롬프트로 변환"""
    
    # 스타일별 프롬프트 템플릿
    style_templates = {
        "cute": "Create a cute and adorable 4-panel comic strip in kawaii style",
        "comic": "Create a funny and humorous 4-panel comic strip in manga style",
        "emotional": "Create a touching and emotional 4-panel comic strip in soft watercolor style"
    }
    
    base_prompt = style_templates.get(request.style, style_templates["cute"])
    
    # 일기 내용을 바탕으로 프롬프트 생성
    prompt = f"""
    {base_prompt} based on this diary entry:
    
    Title: {request.title or "Daily Life"}
    Content: {request.content}
    Mood: {request.mood or "neutral"}
    Weather: {request.weather or "sunny"}
    Location: {request.location or "home"}
    
    The comic should tell a story across 4 panels with:
    - Clear character expressions
    - Appropriate backgrounds
    - Speech bubbles or captions
    - Consistent art style
    - Korean cultural elements if relevant
    
    Format: Single image with 4 panels arranged in a 2x2 grid
    """
    
    return prompt.strip()

async def generate_comic_image(prompt: str, style: str) -> str:
    """DALL-E 3를 사용하여 만화 이미지 생성"""
    
    try:
        response = await openai.Image.acreate(
            model="dall-e-3",
            prompt=prompt,
            size="1024x1024",
            quality="standard",
            n=1
        )
        
        return response.data[0].url
        
    except Exception as e:
        raise Exception(f"DALL-E 3 이미지 생성 실패: {str(e)}")

async def upload_to_supabase_storage(comic_id: str, image_url: str) -> str:
    """이미지를 Supabase Storage에 업로드"""
    
    if not supabase:
        # 테스트 환경에서는 더미 URL 반환
        return f"https://dummy-storage.com/comics/{comic_id}.png"
    
    try:
        import requests
        
        # 이미지 다운로드
        response = requests.get(image_url)
        response.raise_for_status()
        
        # Supabase Storage에 업로드
        file_name = f"comics/{comic_id}.png"
        
        upload_response = supabase.storage.from_("comic-images").upload(
            file_name,
            response.content,
            file_options={"content-type": "image/png"}
        )
        
        if upload_response:
            # 공개 URL 생성
            public_url = supabase.storage.from_("comic-images").get_public_url(file_name)
            return public_url
        else:
            raise Exception("Supabase Storage 업로드 실패")
            
    except Exception as e:
        raise Exception(f"이미지 업로드 실패: {str(e)}")

async def save_comic_to_database(comic_id: str, request: ComicGenerationRequest, image_url: str):
    """만화 정보를 데이터베이스에 저장"""
    
    if not supabase:
        # 테스트 환경에서는 더미 저장 성공
        return
    
    try:
        comic_data = {
            "id": comic_id,
            "diary_id": request.diary_id,
            "user_id": "anonymous",  # 실제로는 인증된 사용자 ID 사용
            "title": request.title or "Generated Comic",
            "description": f"Generated from diary: {request.content[:100]}...",
            "image_url": image_url,
            "style": request.style,
            "status": "completed",
            "created_at": datetime.now().isoformat(),
            "completed_at": datetime.now().isoformat()
        }
        
        result = supabase.table("comics").insert(comic_data).execute()
        
        if not result.data:
            raise Exception("데이터베이스 저장 실패")
            
    except Exception as e:
        raise Exception(f"데이터베이스 저장 실패: {str(e)}")

@router.get("/comic/{comic_id}", response_model=ComicStatus)
async def get_comic(comic_id: str):
    """생성된 만화 상태 조회"""
    
    # 메모리에서 작업 상태 확인
    if comic_id in comic_tasks:
        task_info = comic_tasks[comic_id]
        
        # 데이터베이스에서 만화 정보 조회
        try:
            if supabase:
                result = supabase.table("comics").select("*").eq("id", comic_id).execute()
                
                if result.data:
                    comic_data = result.data[0]
                    return ComicStatus(**comic_data)
            
            # 데이터베이스에 없거나 테스트 환경이면 메모리 상태만 반환
            return ComicStatus(
                id=comic_id,
                diary_id="",
                user_id="",
                title="",
                image_url="",
                style="",
                status=task_info["status"],
                created_at=task_info["created_at"].isoformat(),
                completed_at=task_info.get("completed_at").isoformat() if task_info.get("completed_at") else None,
                estimated_time_seconds=task_info.get("estimated_time_seconds"),
                error_message=task_info.get("error_message")
            )
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"만화 조회 실패: {str(e)}")
    else:
        raise HTTPException(status_code=404, detail="만화를 찾을 수 없습니다.")
