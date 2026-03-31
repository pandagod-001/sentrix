from fastapi import APIRouter, Header
from pydantic import BaseModel

from app.database import users_collection
from app.auth import verify_token
from app.services.face_service import register_face, verify_face
from app.utils.response import success_response, error_response


router = APIRouter(prefix="/api/face", tags=["Face"])


# ==============================
# REQUEST MODEL
# ==============================

class FaceRequest(BaseModel):
    image: str


# ==============================
# REGISTER FACE
# ==============================

@router.post("/register")
def register_face_route(data: FaceRequest, Authorization: str = Header(...)):
    try:
        token = Authorization.split(" ")[1]
        payload = verify_token(token)

        if not payload:
            return error_response("Invalid token")

        user_id = payload["id"]

        encoding = register_face(data.image)

        result = users_collection.update_one(
            {"_id": user_id},
            {
                "$set": {
                    "face_encoding": encoding,
                    "verified": True
                }
            }
        )

        if result.matched_count == 0:
            return error_response("User not found")

        return success_response(None, "Face registered")

    except Exception as e:
        return error_response(str(e))


# ==============================
# VERIFY FACE
# ==============================

@router.post("/verify")
def verify_face_route(data: FaceRequest, Authorization: str = Header(...)):
    try:
        token = Authorization.split(" ")[1]
        payload = verify_token(token)

        if not payload:
            return error_response("Invalid token")

        user_id = payload["id"]

        user = users_collection.find_one({"_id": user_id})

        if not user:
            return error_response("User not found")

        if not user.get("face_encoding"):
            return error_response("Face not registered")

        result = verify_face(user["face_encoding"], data.image)

        if not result:
            return error_response("Face mismatch")

        users_collection.update_one(
            {"_id": user_id},
            {"$set": {"verified": True}}
        )

        return success_response(None, "Face verified")

    except Exception as e:
        return error_response(str(e))