"""
Quick test script for the sketch API.
Usage: python test_sketch.py <image_path>
"""
import sys
import base64
import requests
import json
from pathlib import Path


def test_generate(image_path: str, subject: str = "a cartoon character"):
    """Test the /v1/sketch/generate endpoint."""

    # Read and encode image
    with open(image_path, "rb") as f:
        image_base64 = base64.b64encode(f.read()).decode("utf-8")

    print(f"Image loaded: {image_path}")
    print(f"Subject: {subject}")
    print(f"Base64 length: {len(image_base64)} chars")

    # Send request
    url = "http://localhost:8001/v1/sketch/generate"
    payload = {
        "image_base64": image_base64,
        "size": 512,
        "subject": subject,
        "seed": 42
    }

    print(f"\nSending request to {url}...")
    print("(This may take a few minutes on first run while models download...)")
    response = requests.post(url, json=payload, timeout=600)  # 10 min timeout for SD

    print(f"Status: {response.status_code}")

    if response.status_code == 200:
        data = response.json()
        print(f"Success: {data['success']}")
        print(f"Message: {data['message']}")
        print(f"Steps received: {len(data['steps'])}")

        # Save output images
        output_dir = Path("test_output")
        output_dir.mkdir(exist_ok=True)

        for step in data['steps']:
            img_data = base64.b64decode(step['image_base64'])
            filename = output_dir / f"step{step['step']}_{step['name']}.png"
            with open(filename, "wb") as f:
                f.write(img_data)
            print(f"  Saved: {filename}")

        print(f"\nAll images saved to {output_dir}/")
    else:
        print(f"Error: {response.text}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python test_sketch.py <image_path> [subject]")
        print("\nExamples:")
        print("  python test_sketch.py cartoon.png")
        print("  python test_sketch.py mickey.png 'Mickey Mouse cartoon character'")
        sys.exit(1)

    image_path = sys.argv[1]
    subject = sys.argv[2] if len(sys.argv) > 2 else "a cartoon character"
    test_generate(image_path, subject)
