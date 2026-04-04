from fastapi import APIRouter, Depends, HTTPException, status
from bson import ObjectId
from datetime import datetime
from ..database import db
from ..config import verify_token, get_db
from ..services.dsie_service import DSIEEngine
from ..models import user_model, dependent_model, create_dependent_document

router = APIRouter(prefix="/api/users", tags=["Users"])


# ==============================
# USER MANAGEMENT ENDPOINTS
# ==============================

@router.get("/me")
def get_current_user_profile(token: str = Depends(verify_token)):
    """
    Get authenticated user's profile
    """
    try:
        user_id = token.get("user_id")
        from ..database import users_collection
        user = users_collection.find_one({"_id": ObjectId(user_id)})

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        return {
            "status": "success",
            "id": str(user["_id"]),
            "username": user.get("username"),
            "role": user.get("role"),
            "is_approved": user.get("is_approved"),
            "verified": user.get("verified"),
            "dependents_list": user.get("dependents_list", [])
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{user_id}")
def get_user_profile(user_id: str, token: str = Depends(verify_token), db=Depends(get_db)):
    """
    Get another user's profile (basic info only)
    """
    try:
        user = db.users.find_one({"_id": ObjectId(user_id)})

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        return {
            "status": "success",
            "data": user_model(user)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("")
def get_all_users(token: str = Depends(verify_token)):
    """
    Get all approved users for chat/user selection
    """
    try:
        from ..database import users_collection
        user_id = token.get("user_id")
        
        requester = users_collection.find_one({"_id": ObjectId(user_id)})

        if not requester:
            raise HTTPException(status_code=404, detail="User not found")

        if not requester.get("is_approved"):
            raise HTTPException(status_code=403, detail="User not approved")

        # Handle both real and fake collections
        result = users_collection.find({"is_approved": True})
        
        # Check if result has to_list method (fake collection) or is cursor (real MongoDB)
        if hasattr(result, 'to_list'):
            # Fake collection
            all_users = result.to_list(None)
        elif hasattr(result, '__iter__'):
            # Real cursor
            all_users = list(result)
        else:
            all_users = []
        
        user_list = [
            {
                "id": str(u.get("_id")),
                "username": u.get("username"),
                "role": u.get("role"),
                "is_approved": u.get("is_approved")
            }
            for u in all_users
            if str(u.get("_id")) != str(user_id) and u.get("is_approved")
        ]
        
        return {
            "status": "success",
            "users": user_list
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==============================
# APPROVAL SYSTEM
# ==============================

@router.post("/{user_id}/approve")
def approve_user(user_id: str, token: str = Depends(verify_token)):
    """
    Approve a user (authority only)

    Used to grant access to personnel and dependents after registration
    """
    try:
        from ..database import users_collection
        authority_id = token.get("user_id")
        authority = users_collection.find_one({"_id": ObjectId(authority_id)})

        if authority.get("role") != "authority":
            raise HTTPException(status_code=403, detail="Only authority can approve users")

        user_to_approve = users_collection.find_one({"_id": ObjectId(user_id)})

        if not user_to_approve:
            raise HTTPException(status_code=404, detail="User not found")

        if user_to_approve.get("is_approved"):
            raise HTTPException(status_code=400, detail="User already approved")

        # Approve user
        users_collection.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": {"is_approved": True}}
        )

        return {
            "status": "success",
            "message": f"User {user_to_approve.get('username')} approved successfully"
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/approve")
def approve_user_compat(request: dict, token: str = Depends(verify_token)):
    """
    Backward-compatible approval route.

    Accepts request body: {"user_id": "..."}
    """
    user_id = request.get("user_id")
    if not user_id:
        raise HTTPException(status_code=400, detail="user_id is required")
    return approve_user(user_id, token)


# ==============================
# DEPENDENT MANAGEMENT
@router.post("/{user_id}/reject")
def reject_user(user_id: str, request: dict, token: str = Depends(verify_token)):
    """
    Reject a user (authority only)
    """
    try:
        from ..database import users_collection
        authority_id = token.get("user_id")
        authority = users_collection.find_one({"_id": ObjectId(authority_id)})

        if authority.get("role") != "authority":
            raise HTTPException(status_code=403, detail="Only authority can reject users")

        user_to_reject = users_collection.find_one({"_id": ObjectId(user_id)})
        if not user_to_reject:
            raise HTTPException(status_code=404, detail="User not found")

        reason = request.get("reason", "Admin rejection")
        users_collection.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": {
                "is_approved": False,
                "rejection_reason": reason,
                "rejected_at": datetime.utcnow(),
                "rejected_by": ObjectId(authority_id)
            }}
        )

        return {
            "status": "success",
            "message": f"User {user_to_reject.get('username')} rejected"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ==============================

@router.post("/{personnel_id}/add-dependent")
def add_dependent(personnel_id: str, request: dict, token: str = Depends(verify_token), db=Depends(get_db)):
    """
    Add a dependent to a personnel (authority only)

    Request:
    {
        "dependent_name": "John Doe"
    }

    Returns:
    {
        "status": "success",
        "dependent_id": "..."
    }
    """
    try:
        authority_id = token.get("user_id")
        authority = db.users.find_one({"_id": ObjectId(authority_id)})

        if authority.get("role") != "authority":
            raise HTTPException(status_code=403, detail="Only authority can add dependents")

        personnel = db.users.find_one({"_id": ObjectId(personnel_id)})

        if not personnel or personnel.get("role") != "personnel":
            raise HTTPException(status_code=404, detail="Personnel not found")

        dependent_name = request.get("dependent_name")
        if not dependent_name:
            raise HTTPException(status_code=400, detail="Dependent name required")

        # Create dependent user
        dependent_doc = {
            "username": f"{dependent_name.lower().replace(' ', '_')}_dependent",
            "email": None,
            "password": None,
            "role": "dependent",
            "is_approved": True,  # Dependents auto-approved
            "verified": False,
            "face_registered": False,
            "device_id": None,
            "last_login": None,
            "linked_personnel_id": ObjectId(personnel_id),
            "dependents": [],
            "audit_logs": [],
            "created_at": datetime.utcnow()
        }

        result = db.users.insert_one(dependent_doc)
        dependent_id = result.inserted_id

        # Add to personnel's dependents list
        db.users.update_one(
            {"_id": ObjectId(personnel_id)},
            {
                "$push": {
                    "dependents": {
                        "user_id": dependent_id,
                        "name": dependent_name
                    }
                }
            }
        )

        # Log event
        dsie = DSIEEngine(db)
        dsie.log_security_event(
            authority_id,
            "dependent_created",
            f"Dependent '{dependent_name}' created for personnel {personnel_id}"
        )

        return {
            "status": "success",
            "dependent_id": str(dependent_id),
            "dependent_name": dependent_name
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{personnel_id}/dependents")
def get_dependents(personnel_id: str, token: str = Depends(verify_token), db=Depends(get_db)):
    """
    Get all dependents of a personnel

    Can be called by:
    - Authority (view any)
    - Personnel (view own)
    - Dependent (view own linked personnel's other dependents)
    """
    try:
        requester_id = token.get("user_id")
        requester = db.users.find_one({"_id": ObjectId(requester_id)})

        personnel = db.users.find_one({"_id": ObjectId(personnel_id)})

        if not personnel or personnel.get("role") != "personnel":
            raise HTTPException(status_code=404, detail="Personnel not found")

        # Authorization check
        if requester.get("role") == "authority":
            # Authority can view any
            pass
        elif str(requester_id) == str(personnel_id):
            # Personnel viewing own
            pass
        elif requester.get("role") == "dependent" and str(requester.get("linked_personnel_id")) == str(personnel_id):
            # Dependent viewing linked personnel's dependents
            pass
        else:
            raise HTTPException(status_code=403, detail="Access denied")

        dependents = personnel.get("dependents", [])

        return {
            "status": "success",
            "personnel_id": personnel_id,
            "personnel_name": personnel.get("username"),
            "dependent_count": len(dependents),
            "dependents": dependents
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{dependent_id}")
def remove_dependent(dependent_id: str, token: str = Depends(verify_token), db=Depends(get_db)):
    """
    Remove a dependent (authority only)
    """
    try:
        authority_id = token.get("user_id")
        authority = db.users.find_one({"_id": ObjectId(authority_id)})

        if authority.get("role") != "authority":
            raise HTTPException(status_code=403, detail="Only authority can remove dependents")

        dependent = db.users.find_one({"_id": ObjectId(dependent_id)})

        if not dependent or dependent.get("role") != "dependent":
            raise HTTPException(status_code=404, detail="Dependent not found")

        # Remove from personnel's dependents list
        personnel_id = dependent.get("linked_personnel_id")
        if personnel_id:
            db.users.update_one(
                {"_id": personnel_id},
                {
                    "$pull": {
                        "dependents": {"user_id": ObjectId(dependent_id)}
                    }
                }
            )

        # Delete dependent user
        db.users.delete_one({"_id": ObjectId(dependent_id)})

        # Log event
        dsie = DSIEEngine(db)
        dsie.log_security_event(
            authority_id,
            "dependent_removed",
            f"Dependent {dependent_id} removed"
        )

        return {
            "status": "success",
            "message": "Dependent removed successfully"
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
