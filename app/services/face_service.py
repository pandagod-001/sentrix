import base64
import numpy as np
import cv2
from deepface import DeepFace


# ==============================
# CONSTANTS
# ==============================

MAX_IMAGE_SIZE = 1024


# ==============================
# DECODE BASE64 IMAGE
# ==============================

def decode_image(base64_str: str):
    try:
        if not base64_str:
            raise Exception("Empty image input")

        image_bytes = base64.b64decode(base64_str)
        np_arr = np.frombuffer(image_bytes, np.uint8)

        image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

        if image is None:
            raise Exception("Image decoding failed")

        # Resize for stability
        h, w = image.shape[:2]
        if max(h, w) > MAX_IMAGE_SIZE:
            scale = MAX_IMAGE_SIZE / max(h, w)
            image = cv2.resize(image, (int(w * scale), int(h * scale)))

        return image

    except Exception as e:
        raise Exception(f"Invalid image data: {str(e)}")


# ==============================
# REGISTER FACE
# ==============================

def register_face(image_base64: str):
    try:
        image = decode_image(image_base64)

        # Extract embedding
        embedding = DeepFace.represent(
            img_path=image,
            model_name="Facenet",
            enforce_detection=True
        )[0]["embedding"]

        return base64.b64encode(np.array(embedding).tobytes()).decode()

    except Exception as e:
        raise Exception(f"Face registration failed: {str(e)}")


# ==============================
# VERIFY FACE
# ==============================

def verify_face(stored_encoding_base64: str, image_base64: str):
    try:
        image = decode_image(image_base64)

        # Current embedding
        current_embedding = DeepFace.represent(
            img_path=image,
            model_name="Facenet",
            enforce_detection=True
        )[0]["embedding"]

        current_embedding = np.array(current_embedding)

        # Stored embedding
        stored_bytes = base64.b64decode(stored_encoding_base64)
        stored_embedding = np.frombuffer(stored_bytes, dtype=np.float64)

        # Distance check
        distance = np.linalg.norm(stored_embedding - current_embedding)

        # Threshold (tuned)
        return distance < 10

    except Exception as e:
        raise Exception(f"Face verification failed: {str(e)}")