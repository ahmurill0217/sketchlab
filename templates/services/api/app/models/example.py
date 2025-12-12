from typing import Dict, List
from app.models import Base
from sqlmodel import Field

class Example(Base, table=True):
    name: str = Field(nullable=False)