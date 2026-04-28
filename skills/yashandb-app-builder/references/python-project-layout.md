# Python 项目布局

## 概述

本文档详细介绍基于 YashanDB 的 Python (FastAPI + SQLAlchemy) 项目标准布局。

## 项目结构

```
project-name/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI 应用入口
│   ├── config.py            # 配置管理
│   ├── database.py          # 数据库连接
│   ├── models/               # SQLAlchemy 模型
│   │   └── models.py
│   ├── schemas/              # Pydantic schemas
│   │   └── schemas.py
│   ├── routers/              # API 路由
│   │   └── routers.py
│   └── services/             # 业务逻辑
├── templates/                # HTML 模板
├── static/                   # 静态文件
├── tests/                    # 测试
├── requirements.txt
└── README.md
```

## 目录说明

### app/main.py

FastAPI 应用入口。

```python
from fastapi import FastAPI
from app.routers import routers

app = FastAPI(title="YashanDB API")

app.include_router(routers.router)

@app.get("/")
def root():
    return {"message": "YashanDB API"}
```

### app/config.py

配置管理。

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str = "yashandb+yaspy://sys:password@localhost:1688/test"

    class Config:
        env_file = ".env"

settings = Settings()
```

### app/database.py

数据库连接配置。

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.config import settings

engine = create_engine(settings.database_url)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

### app/models/

SQLAlchemy 模型定义。

```python
from sqlalchemy import Column, Integer, String, DateTime, Sequence
from sqlalchemy.orm import declarative_base
from datetime import datetime

Base = declarative_base()

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, Sequence('user_id_seq'), primary_key=True)
    name = Column(String(100), nullable=False)
    email = Column(String(255), unique=True, index=True)
    created_at = Column(DateTime, default=datetime.now)
```

### app/schemas/

Pydantic 模型定义（用于 API 请求/响应）。

```python
from pydantic import BaseModel
from datetime import datetime

class UserBase(BaseModel):
    name: str
    email: str

class UserCreate(UserBase):
    pass

class UserResponse(UserBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True
```

### app/routers/

API 路由定义。

```python
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas import UserCreate, UserResponse
from app.services import user_service

router = APIRouter()

@router.post("/users", response_model=UserResponse)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    return user_service.create_user(db, user)
```

### app/services/

业务逻辑层。

```python
from sqlalchemy.orm import Session
from app.models import User
from app.schemas import UserCreate

def create_user(db: Session, user: UserCreate):
    db_user = User(name=user.name, email=user.email)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user
```

## 分层架构

```
┌─────────────┐
│   Routers   │  ← API 路由
└──────┬──────┘
       │
┌──────▼──────┐
│  Services   │  ← 业务逻辑
└──────┬──────┘
       │
┌──────▼──────┐
│   Models    │  ← 数据模型
└──────┬──────┘
       │
┌──────▼──────┐
│  SQLAlchemy │  ← 数据库操作
└─────────────┘
```

## requirements.txt 示例

```
fastapi==0.109.0
uvicorn==0.27.0
sqlalchemy==1.4.5
yashandb-sqlalchemy
yaspy
pydantic==2.5.0
pydantic-settings==2.1.0
python-multipart==0.0.6
```

## 启动服务

```bash
# 安装依赖
pip install -r requirements.txt

# 启动开发服务器
uvicorn app.main:app --reload

# 或
python -m app.main
```

## 相关文档

- [Golang 项目布局](golang-project-layout.md)
- [部署指南](deployment.md)
- [前端开发指南](frontend-setup.md)
