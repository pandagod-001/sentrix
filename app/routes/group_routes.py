"""
Group Management Routes

Official groups (authority-controlled)
Family groups (personnel with dependents)
"""

from fastapi import APIRouter, Depends, HTTPException, status
from bson import ObjectId
from ..services.group_service import GroupService
from ..services.dsie_service import DSIEEngine
from ..database import db
from ..config import verify_token, get_db

router = APIRouter(prefix="/api/groups", tags=["groups"])


@router.post("/create")
def create_group(request: dict, token: str = Depends(verify_token)):
    """
    Create an official group (authority only)

    Request:
    {
        "name": "Group Name",
        "members": ["user_id1", "user_id2"]  # Personnel only
    }
    """
    try:
        from ..database import db
        group_service = GroupService(db)
        user_id = token.get("user_id")

        result = group_service.create_official_group(
            name=request.get("name"),
            created_by=user_id,
            members=request.get("members", [])
        )

        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message"))

        return result

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/create-family")
def create_family_group(request: dict, token: str = Depends(verify_token)):
    """
    Create family group for a personnel (authority only)
    """
    try:
        from ..database import db
        group_service = GroupService(db)
        user_id = token.get("user_id")
        personnel_id = request.get("personnel_id")

        if not personnel_id:
            raise HTTPException(status_code=400, detail="personnel_id is required")

        result = group_service.create_family_group(
            authority_id=user_id,
            personnel_id=personnel_id
        )

        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message"))

        return result

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/list")
def list_user_groups(token: str = Depends(verify_token)):
    """
    Get all groups the authenticated user is member of
    """
    try:
        from ..database import db
        group_service = GroupService(db)
        user_id = token.get("user_id")

        result = group_service.list_groups_for_user(user_id)
        return result

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{group_id}/members")
def get_group_members(group_id: str, token: str = Depends(verify_token)):
    """
    Get all members of a group
    """
    try:
        from ..database import db
        group_service = GroupService(db)
        result = group_service.get_group_members(group_id)

        if result.get("status") == "error":
            raise HTTPException(status_code=404, detail=result.get("message"))

        return result

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/{group_id}/add-member")
def add_member_to_group(group_id: str, request: dict, token: str = Depends(verify_token)):
    """
    Add a member to a group (authority only)

    Request:
    {
        "member_id": "user_id"
    }
    """
    try:
        from ..database import db
        group_service = GroupService(db)
        user_id = token.get("user_id")

        result = group_service.add_member_to_group(
            group_id=group_id,
            new_member_id=request.get("member_id"),
            authorized_by=user_id
        )

        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message"))

        return result

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{group_id}/remove-member")
def remove_member_from_group(
    group_id: str,
    request: dict | None = None,
    member_id: str | None = None,
    token: str = Depends(verify_token)
):
    """
    Remove a member from a group (authority only)

    Request:
    {
        "member_id": "user_id"
    }
    """
    try:
        from ..database import db
        group_service = GroupService(db)
        user_id = token.get("user_id")
        target_member_id = member_id or (request or {}).get("member_id")

        if not target_member_id:
            raise HTTPException(status_code=400, detail="member_id is required")

        result = group_service.remove_member_from_group(
            group_id=group_id,
            member_id=target_member_id,
            authorized_by=user_id
        )

        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message"))

        return result

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{group_id}")
def delete_group(group_id: str, token: str = Depends(verify_token), db=Depends(get_db)):
    """
    Delete a group (authority only)
    """
    try:
        group_service = GroupService(db)
        user_id = token.get("user_id")

        result = group_service.delete_group(
            group_id=group_id,
            authorized_by=user_id
        )

        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message"))

        return result

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
