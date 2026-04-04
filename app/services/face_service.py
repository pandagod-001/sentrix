import base64
import hashlib

# ==============================
# MOCK FACE SERVICE (For Testing)
# ==============================
# Note: Full deepface/cv2 implementation can be enabled later
# This stub allows server to run without heavy dependencies


# ==============================
# DECODE BASE64 IMAGE
# ==============================

def decode_image(base64_str: str):
    try:
        if not base64_str:
            raise Exception("Empty image input")

        # Validate base64
        image_bytes = base64.b64decode(base64_str)
        if len(image_bytes) == 0:
            raise Exception("Empty image bytes")

        return image_bytes

    except Exception as e:
        raise Exception(f"Invalid image data: {str(e)}")


# ==============================
# REGISTER FACE (MOCK)
# ==============================

def register_face(image_base64: str):
    """
    Mock face registration - returns hash of image as encoding
    In production, use deepface.DeepFace.represent()
    """
    try:
        image_bytes = decode_image(image_base64)
        
        # Create a deterministic hash as mock encoding
        # In real implementation, DeepFace creates a 128-dim embedding
        hash_value = hashlib.sha256(image_bytes).digest()
        mock_encoding = base64.b64encode(hash_value).decode()
        
        return mock_encoding

    except Exception as e:
        raise Exception(f"Face registration failed: {str(e)}")


# ==============================
# VERIFY FACE (MOCK)
# ==============================

def verify_face(stored_encoding_base64: str, image_base64: str):
    """
    Mock face verification - compares image hashes
    In production, use deepface.DeepFace.verify()
    """
    try:
        image_bytes = decode_image(image_base64)
        
        # Create hash of current image
        current_hash = hashlib.sha256(image_bytes).digest()
        current_encoding = base64.b64encode(current_hash).decode()
        
        if not stored_encoding_base64:
            return False

        # Mock comparison: use deterministic encoding equality.
        # This keeps the backend database-backed without external ML deps.
        try:
            base64.b64decode(stored_encoding_base64)
            base64.b64decode(current_encoding)
            return stored_encoding_base64 == current_encoding
        except:
            return False

    except Exception as e:
        raise Exception(f"Face verification failed: {str(e)}")


def scan_face_database(image_base64: str, users_collection):
    """
    Compare a captured face against stored encodings in the database.

    Returns a match payload if a registered user is found.
    """
    try:
        scanned_encoding = register_face(image_base64)
        for user in users_collection.find({}):
            stored_encoding = user.get("face_encoding")
            if not stored_encoding:
                continue

            if stored_encoding == scanned_encoding:
                return {
                    "matched": True,
                    "user_id": str(user.get("_id")),
                    "name": user.get("username"),
                    "role": user.get("role"),
                    "allowed": user.get("role") in ["personnel", "dependent", "authority"],
                    "accuracy": 1.0,
                }

        return {
            "matched": False,
            "allowed": False,
            "accuracy": 0.0,
        }

    except Exception as e:
        raise Exception(f"Face database scan failed: {str(e)}")
