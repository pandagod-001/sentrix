from fastapi import APIRouter
from pydantic import BaseModel

from app.database import db
from app.auth import hash_password, verify_password, create_token, verify_token
from app.utils.response import success_response, error_response


router = APIRouter(prefix="/api/auth", tags=["Auth"])


# ==============================
# REQUEST MODELS
# ==============================

class RegisterRequest(BaseModel):
    username: str
    password: str
    role: str


class LoginRequest(BaseModel):
    username: str
    password: str
    device_id: str


# ==============================
# REGISTER USER
# ==============================

@router.post("/register")
def register(data: RegisterRequest):
    try:
        existing = db.users.find_one({"username": data.username})

        if existing:
            return error_response("Username already exists")

        hashed_password = hash_password(data.password)

        # auto approve authority
        is_approved = True if data.role == "authority" else False

        user = {
            "username": data.username,
            "password": hashed_password,
            "role": data.role,
            "is_approved": is_approved,
            "verified": False,
            "device_id": None,
            "face_encoding": None
        }

        result = db.users.insert_one(user)

        return success_response({
            "user_id": str(result.inserted_id)
        })

    except Exception as e:
        return error_response(str(e))


# ==============================
# LOGIN USER
# ==============================

@router.post("/login")
def login(data: LoginRequest):
    try:
        user = db.users.find_one({"username": data.username})

        if not user:
            return error_response("User not found")

        if not verify_password(data.password, user["password"]):
            return error_response("Invalid credentials")

        if not user.get("is_approved"):
            return error_response("User not approved")

        # -----------------------------
        # DEVICE BINDING
        # -----------------------------
        if user.get("device_id") is None:
            db.users.update_one(
                {"_id": user["_id"]},
                {"$set": {"device_id": data.device_id}}
            )
        elif user["device_id"] != data.device_id:
            # Demo-friendly behavior: if a user logs in from a new device,
            # rebind instead of hard-failing with "Device mismatch".
            db.users.update_one(
                {"_id": user["_id"]},
                {"$set": {"device_id": data.device_id}}
            )

        # -----------------------------
        # CREATE TOKEN
        # -----------------------------
        token = create_token({
            "id": str(user["_id"]),
            "role": user["role"]
        })

        return success_response({
            "access_token": token,
            "token": token,
            "user_id": str(user["_id"]),
            "role": user["role"],
            "user": {
                "id": str(user["_id"]),
                "name": user["username"],
                "role": user["role"],
                "linked_personnel_id": None
            }
        })

    except Exception as e:
        return error_response(str(e))


@router.post("/logout")
def logout():
    """
    Stateless JWT logout.
    Client-side token disposal is sufficient for current architecture.
    """
    return success_response(message="Logged out successfully")


@router.post("/refresh")
def refresh_token(request: dict):
    """
    Refresh token endpoint for frontend compatibility.
    Expects: {"token": "<jwt>"}
    """
    try:
        old_token = request.get("token")
        if not old_token:
            return error_response("Token is required")

        payload = verify_token(old_token)
        if not payload:
            return error_response("Invalid or expired token")

        new_token = create_token({
            "id": payload.get("user_id") or payload.get("id"),
            "role": payload.get("role")
        })

        return success_response({
            "access_token": new_token,
            "token": new_token
        })
    except Exception as e:
        return error_response(str(e))