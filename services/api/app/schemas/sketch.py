from pydantic import BaseModel, Field
from enum import Enum


class StepName(str, Enum):
    WIREFRAME = "wireframe"
    BASIC_OUTLINE = "basic_outline"
    DETAILED_OUTLINE = "detailed_outline"
    INK_SKETCH = "ink_sketch"
    FLAT_COLOR = "flat_color"
    FINAL_RENDER = "final_render"


class SketchStep(BaseModel):
    step: int = Field(..., ge=1, le=6)
    name: StepName
    label: str
    image_base64: str


class GenerateRequest(BaseModel):
    image_base64: str = Field(..., description="Base64 encoded input image (PNG/JPG)")
    size: int = Field(default=512, ge=256, le=1024, description="Output image size")
    subject: str = Field(default="a cartoon character", description="Subject description for prompts")
    seed: int = Field(default=42, ge=0, description="Random seed for reproducibility")


class GenerateResponse(BaseModel):
    success: bool
    steps: list[SketchStep]
    message: str | None = None
