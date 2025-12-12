from fastapi import APIRouter, HTTPException
import logging

from app.schemas import GenerateRequest, GenerateResponse
from app.services.sketch import sketch_service

router = APIRouter()
logger = logging.getLogger(__name__)


@router.post("/generate", response_model=GenerateResponse)
async def generate_sketch(request: GenerateRequest) -> GenerateResponse:
    """
    Generate a 6-step drawing tutorial from an input image.

    - **image_base64**: Base64 encoded PNG or JPG image
    - **size**: Output image size (256-1024, default 512)
    - **subject**: Description of the subject (e.g., "Mickey Mouse", "a cute cat")
    - **seed**: Random seed for reproducibility

    Returns 6 progressive steps: shapes → volume → lines → details → shadow → shine
    """
    try:
        # Decode and resize input
        image = sketch_service.decode_image(request.image_base64)
        image = sketch_service.resize_image(image, request.size)

        # Generate steps
        steps = sketch_service.generate(
            image=image,
            subject=request.subject,
            seed=request.seed,
        )

        return GenerateResponse(
            success=True,
            steps=steps,
            message="Successfully generated 6-step tutorial",
        )

    except ValueError as e:
        logger.error(f"Invalid input: {e}")
        raise HTTPException(status_code=400, detail=str(e))

    except Exception as e:
        logger.exception("Sketch generation failed")
        raise HTTPException(status_code=500, detail="Failed to generate sketch tutorial")
