import os
from pathlib import Path

import firebase_admin
from dotenv import load_dotenv
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from firebase_admin import auth, credentials
from pydantic import BaseModel

BACKEND_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BACKEND_DIR / ".env")

router = APIRouter()
bearer = HTTPBearer(auto_error=False)


class CurrentUser(BaseModel):
    uid: str
    email: str | None = None


def _init_firebase():
    """처음 토큰을 확인할 때 한 번만 Firebase에 연결 (키가 없어도 /news는 동작하도록)"""
    try:
        firebase_admin.get_app()
        return  # 이미 연결됨
    except ValueError:
        pass

    path = os.getenv("FIREBASE_CREDENTIALS")
    if not path:
        raise HTTPException(status_code=500, detail="firebase not configured")
    cred_path = Path(path)
    if not cred_path.is_absolute():
        cred_path = BACKEND_DIR / cred_path  # Backend 폴더 기준
    try:
        firebase_admin.initialize_app(credentials.Certificate(cred_path))
    except (OSError, ValueError) as e:
        print("Firebase 연결 실패:", e)
        raise HTTPException(status_code=500, detail="firebase not configured")


def verify_token(token: str) -> dict:
    """Firebase ID 토큰 확인. 테스트에서는 이 함수를 가짜로 바꿔 끼운다"""
    _init_firebase()
    return auth.verify_id_token(token)


def get_current_user(cred: HTTPAuthorizationCredentials | None = Depends(bearer)) -> CurrentUser:
    if cred is None:
        raise HTTPException(status_code=401, detail="login required")
    try:
        decoded = verify_token(cred.credentials)
    except (auth.InvalidIdTokenError, ValueError):
        raise HTTPException(status_code=401, detail="invalid token")
    return CurrentUser(uid=decoded["uid"], email=decoded.get("email"))


@router.get("/me", response_model=CurrentUser)
def read_me(user: CurrentUser = Depends(get_current_user)):
    return user