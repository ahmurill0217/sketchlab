from fastapi import APIRouter, Depends, HTTPException
from app import crud
from app.core import db
from sqlmodel import Session
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

@router.get("/")
async def get_example(*, db: Session = Depends(db.get_db)):
    try:
        examples = crud.example.get_all(db)
        return examples
    
    except ValueError as ve:
        logger.error(f"Value error: {ve}")
        raise HTTPException(status_code=400, detail=str(ve))
    
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")