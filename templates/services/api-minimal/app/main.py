from fastapi import FastAPI, APIRouter
from starlette.middleware.cors import CORSMiddleware
from app.core.config import settings

from app.routes import (
    example,
)

app = FastAPI(
    title=settings.app_name, 
    openapi_url=f"/v1/openapi.json", 
    docs_url=settings.DOCS_URL
)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

api_router = APIRouter()

api_router.include_router(example.router, prefix="/example", tags=["Example"])
app.include_router(api_router, prefix="/v1")

@app.get("/")
async def root():
    return {
        "app name": settings.app_name,
        "status": 200,
        "message": "API is running (no database configured)"
    }

@app.get("/health")
async def health():
    return {"status": 200}