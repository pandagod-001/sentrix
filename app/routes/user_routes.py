from fastapi import APIRouter, Header
from pydantic import BaseModel

from app.database import users_collection
from app.auth import verify_token
from app.dsie import dsie_check
from app.utils.response import success_response, error_response


router = APIRouter(prefix="/api/users", tags=["Users"])


# ==============================
# REQUEST MODELS
# ==============================

class ApproveRequest(BaseModel):
    user_id: str


class LinkDependentRequest(BaseModel):
    dependent_id: str
    personnel_id: str


# ==============================
# HELPER: AUTHENTICATE USER
# ==============================

def get_current_user(token: str):
    payload = verify_token(token)

    if not payload:
        return None

    return users_collection.find_one({"_id": payload["id"]})


# ==============================
# APPROVE USER
# ==============================

@router.post("/approve")
def approve_user(data: ApproveRequest, Authorization: str = Header(...)):
    try:
        token = Authorization.replace("Bearer ", "")
        admin = get_current_user(token)

        if not admin:
            return error_response("Invalid token")

        if admin.get("role") != "authority":
            return error_response("Only authority can approve users")

        target_user = users_collection.find_one({"_id": data.user_id})

        if not target_user:
            return error_response("User not found")

        decision = dsie_check(
            {
                "id": admin["_id"],
                "role": admin["role"],
                "is_approved": admin.get("is_approved"),
                "verified": True
            },
            action="approve_user"
        )

        if decision != "ALLOW":
            return error_response("Blocked by security policy")

        users_collection.update_one(
            {"_id": data.user_id},
            {"$set": {"is_approved": True}}
        )

        return success_response(None, "User approved successfully")

    except Exception as e:
        return error_response(str(e))


# ==============================
# LINK DEPENDENT
# ==============================

@router.post("/link-dependent")
def link_dependent(data: LinkDependentRequest, Authorization: str = Header(...)):
    try:
        token = Authorization.replace("Bearer ", "")
        admin = get_current_user(token)

        if not admin:
            return error_response("Invalid token")

        if admin.get("role") != "authority":
            return error_response("Only authority can link dependents")

        dependent = users_collection.find_one({"_id": data.dependent_id})
        personnel = users_collection.find_one({"_id": data.personnel_id})

        if not dependent or not personnel:
            return error_response("User not found")

        if dependent.get("role") != "dependent":
            return error_response("Target is not a dependent")

        if personnel.get("role") != "personnel":
            return error_response("Target is not personnel")

        decision = dsie_check(
            {
                "id": admin["_id"],
                "role": admin["role"],
                "is_approved": admin.get("is_approved"),
                "verified": True
            },
            action="link_dependent"
        )

        if decision != "ALLOW":
            return error_response("Blocked by security policy")

        users_collection.update_one(
            {"_id": data.dependent_id},
            {"$set": {"linked_personnel_id": data.personnel_id}}
        )

        return success_response(None, "Dependent linked successfully")

    except Exception as e:
        return error_response(str(e))


# ==============================
# GET ALL USERS
# ==============================

@router.get("/all")
def get_all_users(Authorization: str = Header(...)):
    try:
        token = Authorization.replace("Bearer ", "")
        admin = get_current_user(token)

        if not admin:
            return error_response("Invalid token")

        if admin.get("role") != "authority":
            return error_response("Only authority can view all users")

        users = users_collection.find()

        formatted = [
            {
                "id": u["_id"],
                "name": u["username"],
                "role": u["role"]
            }
            for u in users
        ]

        return success_response(formatted)

    except Exception as e:
        return error_response(str(e))


# ==============================
# GET MY PROFILE
# ==============================

@router.get("/me")
def get_my_profile(Authorization: str = Header(...)):
    try:
        token = Authorization.replace("Bearer ", "")
        user = get_current_user(token)

        if not user:
            return error_response("Invalid token")

        return success_response({
            "id": user["_id"],
            "name": user["username"],
            "role": user["role"]
        })

    except Exception as e:
        return error_response(str(e))