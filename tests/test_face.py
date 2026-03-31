import base64
from app.services.face_service import register_face, verify_face


# ==============================
# LOAD IMAGE AS BASE64
# ==============================

def load_image(path: str):
    with open(path, "rb") as f:
        return base64.b64encode(f.read()).decode()


# ==============================
# FACE TEST
# ==============================

def run():
    print("\n=== FACE TEST ===")

    try:
        # --------------------------
        # LOAD IMAGE
        # --------------------------
        image_base64 = load_image("tests/face.jpg")  

        # --------------------------
        # REGISTER FACE
        # --------------------------
        print("Registering face...")
        encoding = register_face(image_base64)

        print("Encoding generated ")

        # --------------------------
        # VERIFY FACE
        # --------------------------
        print("Verifying face...")
        result = verify_face(encoding, image_base64)

        print("FACE MATCH:", result)

        if result:
            print("FACE TEST PASSED")
        else:
            print("FACE TEST FAILED")

    except Exception as e:
        print("FACE TEST ERROR:", str(e))