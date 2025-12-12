from fastapi import APIRouter, HTTPException
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

@router.get("/")
async def get_example():
    """Simple example endpoint without database"""
    return {
        "message": "Hello from the example endpoint!",
        "status": "ok",
        "data": [
            {"id": 1, "name": "Example 1"},
            {"id": 2, "name": "Example 2"}
        ]
    }

@router.get("/{item_id}")
async def get_example_by_id(item_id: int):
    """Get a specific example by ID"""
    if item_id < 1:
        raise HTTPException(status_code=400, detail="Invalid ID")
    
    return {
        "id": item_id,
        "name": f"Example {item_id}",
        "description": f"This is example number {item_id}"
    }

@router.post("/")
async def create_example(data: dict):
    """Create a new example (in-memory only)"""
    return {
        "message": "Example created (not persisted)",
        "data": data
    }