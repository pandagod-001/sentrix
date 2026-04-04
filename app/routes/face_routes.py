from fastapi import APIRouter, Header
from pydantic import BaseModel
from bson import ObjectId

from datetime import datetime

from app.database import db, users_collection, face_scans_collection
from app.auth import verify_token
from app.services.face_service import register_face, verify_face, scan_face_database
from app.utils.response import success_response, error_response


router = APIRouter(prefix="/api/face", tags=["Face"])


# ==============================
# REQUEST MODEL
# ==============================

class FaceRequest(BaseModel):
    image: str


def _is_authority(payload: dict | None) -> bool:
    if not payload:
        return False
    role = (payload.get("role") or "").lower()
    return role in {"authority", "admin"}


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

        user_id = payload.get("user_id") or payload.get("id")
        if not user_id:
            return error_response("Invalid token payload")

        existing_user = users_collection.find_one({"_id": ObjectId(user_id)})
        if not existing_user:
            return error_response("User not found")

        encoding = register_face(data.image)

        result = users_collection.update_one(
            {"_id": ObjectId(user_id)},
            {
                "$set": {
                    "face_encoding": encoding,
                    "verified": True,
                    "face_registered": True
                }
            }
        )

        matched_count = getattr(result, "matched_count", None)
        modified_count = getattr(result, "modified_count", None)
        if matched_count == 0 or (matched_count is None and modified_count == 0):
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

        user_id = payload.get("user_id") or payload.get("id")
        if not user_id:
            return error_response("Invalid token payload")

        user = users_collection.find_one({"_id": ObjectId(user_id)})

        if not user:
            return error_response("User not found")

        if not user.get("face_encoding"):
            return error_response("Face not registered")

        result = verify_face(user["face_encoding"], data.image)

        if not result:
            return error_response("Face mismatch")

        users_collection.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": {"verified": True, "face_registered": True}}
        )

        return success_response(None, "Face verified")

    except Exception as e:
        return error_response(str(e))


@router.post("/scan")
def scan_face_route(data: FaceRequest, Authorization: str = Header(...)):
    try:
        token = Authorization.split(" ")[1]
        payload = verify_token(token)

        if not payload:
            return error_response("Invalid token")

        if not _is_authority(payload):
            return error_response("Only authority can scan faces")

        result = scan_face_database(data.image, users_collection)

        scan_log = {
            "scanned_by": ObjectId(payload.get("user_id") or payload.get("id")),
            "matched": result.get("matched", False),
            "matched_user_id": ObjectId(result["user_id"]) if result.get("matched") and result.get("user_id") else None,
            "matched_role": result.get("role"),
            "allowed": result.get("allowed", False),
            "created_at": datetime.utcnow(),
        }
        face_scans_collection.insert_one(scan_log)

        if result.get("matched"):
            if result.get("user_id"):
                users_collection.update_one(
                    {"_id": ObjectId(result["user_id"])},
                    {"$set": {"last_face_scanned_at": datetime.utcnow()}}
                )

            return success_response({
                "matched": True,
                "allowed": bool(result.get("allowed")),
                "user": {
                    "id": result.get("user_id"),
                    "name": result.get("name"),
                    "role": result.get("role"),
                },
                "accuracy": result.get("accuracy", 0.0),
            }, "Face matched")

        return error_response("No matching face found")

    except Exception as e:
        return error_response(str(e))


@router.get("/scans")
def list_face_scans(limit: int = 10, Authorization: str = Header(...)):
    try:
        token = Authorization.split(" ")[1]
        payload = verify_token(token)

        if not payload:
            return error_response("Invalid token")

        if not _is_authority(payload):
            return error_response("Only authority can view face scans")

        raw_scans = list(face_scans_collection.find({}))
        raw_scans = raw_scans[-limit:][::-1]

        scans = []
        for scan in raw_scans:
            scanned_by = users_collection.find_one({"_id": scan.get("scanned_by")}) if scan.get("scanned_by") else None
            matched_user = users_collection.find_one({"_id": scan.get("matched_user_id")}) if scan.get("matched_user_id") else None

            scans.append({
                "id": str(scan.get("_id")),
                "scanned_by": {
                    "id": str(scanned_by.get("_id")) if scanned_by else None,
                    "name": scanned_by.get("username") if scanned_by else None,
                    "role": scanned_by.get("role") if scanned_by else None,
                },
                "matched": bool(scan.get("matched", False)),
                "allowed": bool(scan.get("allowed", False)),
                "matched_user": {
                    "id": str(matched_user.get("_id")) if matched_user else None,
                    "name": matched_user.get("username") if matched_user else scan.get("matched_role"),
                    "role": matched_user.get("role") if matched_user else scan.get("matched_role"),
                },
                "created_at": scan.get("created_at").isoformat() if scan.get("created_at") else None,
            })

        return success_response({"scans": scans}, "Face scans loaded")

    except Exception as e:
        return error_response(str(e))