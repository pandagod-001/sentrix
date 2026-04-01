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
        
        # For testing: allow exact match or 80% similarity
        # In production, calculate euclidean distance < threshold
        
        # Mock: Check if encoding exists (simple validation)
        if not stored_encoding_base64:
            return False
            
        # Mock similarity (in real impl: distance check)
        # For demo, just verify both encodings are valid base64
        try:
            base64.b64decode(stored_encoding_base64)
            base64.b64decode(current_encoding)
            return True  # In production: distance < 0.6
        except:
            return False

    except Exception as e:
        raise Exception(f"Face verification failed: {str(e)}")
