"""
Sketch generation service - Phase 2 (Stable Diffusion).

Generates 6 progressive drawing tutorial steps:
1. Shapes - Basic geometric construction
2. Volume - Guide lines and form
3. Lines - Clean outline
4. Details - Features and fine lines
5. Shadow - Shading and depth
6. Shine - Final colored version
"""
import base64
import io
import logging
from dataclasses import dataclass

import torch
from PIL import Image

from app.schemas import SketchStep, StepName

logger = logging.getLogger(__name__)

# Lazy-loaded models
_pipe = None
_controlnet = None
_lineart_detector = None


@dataclass
class StepConfig:
    """Configuration for each tutorial step."""
    step: int
    name: StepName
    label: str
    prompt_suffix: str
    strength: float  # Higher = more creative/different from input
    guidance_scale: float
    controlnet_scale: float


STEP_CONFIGS = [
    StepConfig(
        step=1,
        name=StepName.WIREFRAME,
        label="Shapes",
        prompt_suffix="simple geometric shapes, basic circles and ovals, minimal construction sketch, very simple, white background",
        strength=0.95,
        guidance_scale=7.0,
        controlnet_scale=0.3,
    ),
    StepConfig(
        step=2,
        name=StepName.BASIC_OUTLINE,
        label="Volume",
        prompt_suffix="rough sketch with construction lines, basic 3d form, guide lines, simple shapes, white background",
        strength=0.88,
        guidance_scale=7.5,
        controlnet_scale=0.4,
    ),
    StepConfig(
        step=3,
        name=StepName.DETAILED_OUTLINE,
        label="Lines",
        prompt_suffix="clean line drawing, simple outline, black lines on white, no shading, cartoon style",
        strength=0.75,
        guidance_scale=8.0,
        controlnet_scale=0.6,
    ),
    StepConfig(
        step=4,
        name=StepName.INK_SKETCH,
        label="Details",
        prompt_suffix="detailed line art, clear features, clean ink drawing, black and white, fine details",
        strength=0.60,
        guidance_scale=8.5,
        controlnet_scale=0.7,
    ),
    StepConfig(
        step=5,
        name=StepName.FLAT_COLOR,
        label="Shadow",
        prompt_suffix="pencil sketch with soft shading, shadows and depth, grayscale tones, detailed shading",
        strength=0.50,
        guidance_scale=8.0,
        controlnet_scale=0.75,
    ),
    StepConfig(
        step=6,
        name=StepName.FINAL_RENDER,
        label="Shine",
        prompt_suffix="fully colored cartoon illustration, vibrant colors, complete artwork, polished finish",
        strength=0.35,
        guidance_scale=7.5,
        controlnet_scale=0.8,
    ),
]


def _get_device() -> str:
    """Detect best available device."""
    if torch.cuda.is_available():
        return "cuda"
    elif torch.backends.mps.is_available():
        return "mps"
    return "cpu"


def _get_dtype():
    """Get appropriate dtype for device."""
    device = _get_device()
    if device == "cuda":
        return torch.float16
    return torch.float32  # MPS and CPU need float32


def _load_pipeline():
    """Lazy load the Stable Diffusion + ControlNet pipeline."""
    global _pipe, _controlnet

    if _pipe is not None:
        return _pipe

    from diffusers import (
        ControlNetModel,
        StableDiffusionControlNetImg2ImgPipeline,
        UniPCMultistepScheduler,
    )

    device = _get_device()
    dtype = _get_dtype()

    logger.info(f"Loading models on device: {device}, dtype: {dtype}")

    # Load ControlNet for lineart
    logger.info("Loading ControlNet lineart model...")
    _controlnet = ControlNetModel.from_pretrained(
        "lllyasviel/control_v11p_sd15_lineart",
        torch_dtype=dtype,
    )

    # Load SD pipeline with ControlNet
    logger.info("Loading Stable Diffusion pipeline...")
    _pipe = StableDiffusionControlNetImg2ImgPipeline.from_pretrained(
        "stable-diffusion-v1-5/stable-diffusion-v1-5",
        controlnet=_controlnet,
        torch_dtype=dtype,
        safety_checker=None,
    )

    # Use efficient scheduler
    _pipe.scheduler = UniPCMultistepScheduler.from_config(_pipe.scheduler.config)

    # Move to device
    _pipe.to(device)

    # Enable memory optimizations
    if device == "cuda":
        _pipe.enable_model_cpu_offload()

    logger.info("Pipeline loaded successfully")
    return _pipe


def _get_lineart_detector():
    """Lazy load LineArt detector."""
    global _lineart_detector

    if _lineart_detector is None:
        from controlnet_aux import LineartDetector
        logger.info("Loading LineArt detector...")
        _lineart_detector = LineartDetector.from_pretrained("lllyasviel/Annotators")

    return _lineart_detector


class SketchService:
    """Service for generating step-by-step drawing tutorials."""

    @staticmethod
    def decode_image(base64_string: str) -> Image.Image:
        """Decode base64 string to PIL Image."""
        if "," in base64_string:
            base64_string = base64_string.split(",")[1]
        image_data = base64.b64decode(base64_string)
        return Image.open(io.BytesIO(image_data)).convert("RGB")

    @staticmethod
    def encode_image(image: Image.Image) -> str:
        """Encode PIL Image to base64 string."""
        buffer = io.BytesIO()
        image.save(buffer, format="PNG")
        return base64.b64encode(buffer.getvalue()).decode("utf-8")

    @staticmethod
    def resize_image(image: Image.Image, size: int) -> Image.Image:
        """Resize image to square dimensions."""
        return image.resize((size, size), Image.Resampling.LANCZOS)

    def _extract_lineart(self, image: Image.Image) -> Image.Image:
        """Extract lineart from image for ControlNet conditioning."""
        import numpy as np
        detector = _get_lineart_detector()
        arr = np.array(image)
        lineart = detector(arr, coarse=False)
        if isinstance(lineart, Image.Image):
            return lineart.convert("RGB")
        return Image.fromarray(lineart).convert("RGB")

    def _generate_step(
        self,
        pipe,
        image: Image.Image,
        control_image: Image.Image,
        config: StepConfig,
        subject: str,
        seed: int,
    ) -> Image.Image:
        """Generate a single tutorial step."""
        prompt = f"{subject}, {config.prompt_suffix}"
        negative_prompt = "blurry, low quality, artifacts, watermark, text, signature, ugly, deformed"

        generator = torch.Generator(device=_get_device()).manual_seed(seed)

        result = pipe(
            prompt=prompt,
            negative_prompt=negative_prompt,
            image=image,
            control_image=control_image,
            num_inference_steps=25,
            strength=config.strength,
            guidance_scale=config.guidance_scale,
            controlnet_conditioning_scale=config.controlnet_scale,
            generator=generator,
        )

        return result.images[0]

    def generate(
        self,
        image: Image.Image,
        subject: str = "a cartoon character",
        seed: int = 42,
    ) -> list[SketchStep]:
        """
        Generate 6 tutorial steps from input image.

        Args:
            image: Input PIL Image (already resized)
            subject: Description of the subject for prompts
            seed: Random seed for reproducibility

        Returns:
            List of SketchStep objects with base64 encoded images
        """
        logger.info(f"Generating sketch steps for image size {image.size}")

        # Load pipeline
        pipe = _load_pipeline()

        # Extract lineart for ControlNet conditioning
        logger.info("Extracting lineart...")
        control_image = self._extract_lineart(image)

        # Generate each step
        results = []
        for config in STEP_CONFIGS:
            logger.info(f"Generating step {config.step}: {config.label}")

            step_image = self._generate_step(
                pipe=pipe,
                image=image,
                control_image=control_image,
                config=config,
                subject=subject,
                seed=seed + config.step,  # Vary seed slightly per step
            )

            results.append(
                SketchStep(
                    step=config.step,
                    name=config.name,
                    label=config.label,
                    image_base64=self.encode_image(step_image),
                )
            )

        logger.info("Successfully generated all 6 steps")
        return results


# Singleton instance
sketch_service = SketchService()
