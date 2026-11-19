from db.database import BACKEND_DIR, Base, engine
from db import models


def main():
    (BACKEND_DIR / "data").mkdir(exist_ok=True)   # data/ 폴더가 없으면 만들기
    Base.metadata.create_all(engine)
    print("테이블:", list(Base.metadata.tables))


if __name__ == "__main__":
    main()