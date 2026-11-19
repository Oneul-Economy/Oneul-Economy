import os
from pathlib import Path

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

# 1) Backend 폴더 위치: 이 파일(Backend/db/database.py)에서 두 단계 위
BACKEND_DIR = Path(__file__).resolve().parent.parent
DEFAULT_URL = f"sqlite:///{BACKEND_DIR / 'data' / 'oneul.db'}"


# 2) 환경 변수가 있으면 그 값, 없거나 비어 있으면 기본값
DATABASE_URL = os.getenv("DATABASE_URL") or DEFAULT_URL

# 3) DB 연결 (프로그램 전체에 하나)
engine = create_engine(DATABASE_URL)

# 4) 세션을 찍어내는 틀 (요청 하나 = 세션 하나 = 트랜잭션 하나)
SessionLocal = sessionmaker(bind=engine)

# 5) 모든 테이블 클래스의 부모
class Base(DeclarativeBase):
    pass