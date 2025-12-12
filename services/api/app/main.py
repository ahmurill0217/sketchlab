from fastapi import FastAPI, APIRouter
from starlette.middleware.cors import CORSMiddleware
from app.core.config import settings
from sqlmodel import Session
from app.core.db import engine, init_db

from app.routes import example, sketch

with Session(engine) as session:
    init_db(session)

app = FastAPI(
    title=settings.app_name,
    openapi_url="/v1/openapi.json",
    docs_url=settings.DOCS_URL,
)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

api_router = APIRouter()

api_router.include_router(sketch.router, prefix="/sketch", tags=["Sketch"])
api_router.include_router(example.router, prefix="/example", tags=["Example"])

app.include_router(api_router, prefix="/v1")


@app.get("/")
async def root():
    return {"app_name": settings.app_name, "status": "ok"}


@app.get("/health")
async def health():
    return {"status": "ok"}
