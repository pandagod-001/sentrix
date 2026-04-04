"""
Group Management Service

Handles creation, management, and member operations for official and family groups
"""

from datetime import datetime
from bson import ObjectId


class GroupService:
    """
    Service for managing groups in SENTRIX
    """

    def __init__(self, db):
        self.db = db

    def create_official_group(self, name: str, created_by: str, members: list) -> dict:
        """
        Create an official group (personnel only)

        Args:
            name: Group name
            created_by: Authority user ID who creates the group
            members: List of personnel IDs to add to group

        Returns:
            group_id or error
        """
        try:
            creator = self.db.users.find_one({"_id": ObjectId(created_by)})
            if not creator or creator.get("role") != "authority":
                return {"status": "error", "message": "Only authority can create official groups"}

            # Verify all members are personnel
            invalid_members = []
            for member_id in members:
                member = self.db.users.find_one({"_id": ObjectId(member_id)})
                if not member or member.get("role") != "personnel":
                    invalid_members.append(member_id)

            if invalid_members:
                return {
                    "status": "error",
                    "message": f"Invalid members (must be personnel): {invalid_members}"
                }

            # Ensure group creator is always a member so the group appears in their list.
            member_ids = []
            for member_id in members:
                obj_id = ObjectId(member_id)
                if obj_id not in member_ids:
                    member_ids.append(obj_id)

            creator_id = ObjectId(created_by)
            if creator_id not in member_ids:
                member_ids.append(creator_id)

            group_doc = {
                "name": name,
                "type": "official",
                "created_by": creator_id,
                "members": member_ids,
                "created_at": datetime.utcnow()
            }

            result = self.db.groups.insert_one(group_doc)
            return {
                "status": "success",
                "group_id": str(result.inserted_id),
                "message": "Official group created"
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def create_family_group(self, authority_id: str, personnel_id: str) -> dict:
        """
        Create a family group for a personnel and their dependents

        Only authority can create family groups.
        A personnel can have only ONE family group.

        Args:
            personnel_id: Personnel user ID

        Returns:
            group_id or error
        """
        try:
            authority = self.db.users.find_one({"_id": ObjectId(authority_id)})
            if not authority or authority.get("role") != "authority":
                return {"status": "error", "message": "Only authority can create family groups"}

            personnel = self.db.users.find_one({"_id": ObjectId(personnel_id)})
            if not personnel or personnel.get("role") != "personnel":
                return {"status": "error", "message": "Only personnel can have family groups"}

            # Check if family group already exists
            existing = self.db.groups.find_one({
                "type": "family",
                "created_by": ObjectId(personnel_id)
            })

            if existing:
                return {"status": "error", "message": "Personnel already has a family group"}

            members = [ObjectId(personnel_id)]

            dependents = personnel.get("dependents", [])
            for dependent in dependents:
                dependent_user_id = dependent.get("user_id")
                if dependent_user_id:
                    dep_obj = ObjectId(dependent_user_id)
                    if dep_obj not in members:
                        members.append(dep_obj)

            group_doc = {
                "name": f"{personnel.get('username')}'s Family Group",
                "type": "family",
                "created_by": ObjectId(authority_id),
                "owner_personnel_id": ObjectId(personnel_id),
                "members": members,
                "created_at": datetime.utcnow()
            }

            result = self.db.groups.insert_one(group_doc)
            return {
                "status": "success",
                "group_id": str(result.inserted_id),
                "message": "Family group created"
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def list_groups_for_user(self, user_id: str) -> dict:
        """
        Get all groups a user is member of
        """
        try:
            groups = self.db.groups.find({"members": ObjectId(user_id)})
            group_list = []
            if hasattr(groups, 'to_list'):
                group_list = groups.to_list(None)
            else:
                group_list = groups if isinstance(groups, list) else [groups]

            return {
                "status": "success",
                "groups": [
                    {
                        "id": str(g.get("_id")),
                        "name": g.get("name"),
                        "type": g.get("type"),
                        "member_count": len(g.get("members", []))
                    }
                    for g in group_list if g
                ]
            }
        except Exception as e:
            return {"status": "error", "groups": []}

    def add_member_to_group(self, group_id: str, new_member_id: str, authorized_by: str) -> dict:
        """
        Add a member to a group

        Args:
            group_id: Group ID
            new_member_id: User to add
            authorized_by: User performing the operation (must be authority or group creator)
        """
        try:
            group = self.db.groups.find_one({"_id": ObjectId(group_id)})
            if not group:
                return {"status": "error", "message": "Group not found"}

            authorizer = self.db.users.find_one({"_id": ObjectId(authorized_by)})
            if not authorizer or authorizer.get("role") != "authority":
                return {"status": "error", "message": "Only authority can add members"}

            # For official groups: only add personnel
            if group.get("type") == "official":
                new_member = self.db.users.find_one({"_id": ObjectId(new_member_id)})
                if not new_member or new_member.get("role") != "personnel":
                    return {
                        "status": "error",
                        "message": "Only personnel can be added to official groups"
                    }

            # For family groups: only linked dependents can be added.
            if group.get("type") == "family":
                new_member = self.db.users.find_one({"_id": ObjectId(new_member_id)})
                if not new_member or new_member.get("role") != "dependent":
                    return {
                        "status": "error",
                        "message": "Only dependents can be added to family groups"
                    }

                linked = new_member.get("linked_personnel_id")
                if str(linked) != str(authorized_by):
                    return {
                        "status": "error",
                        "message": "Dependent is not linked to this personnel"
                    }

            # Add member
            if ObjectId(new_member_id) not in group.get("members", []):
                self.db.groups.update_one(
                    {"_id": ObjectId(group_id)},
                    {"$push": {"members": ObjectId(new_member_id)}}
                )

            return {
                "status": "success",
                "message": "Member added to group"
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def remove_member_from_group(self, group_id: str, member_id: str, authorized_by: str) -> dict:
        """
        Remove a member from a group
        """
        try:
            group = self.db.groups.find_one({"_id": ObjectId(group_id)})
            if not group:
                return {"status": "error", "message": "Group not found"}

            authorizer = self.db.users.find_one({"_id": ObjectId(authorized_by)})
            if not authorizer or authorizer.get("role") != "authority":
                return {"status": "error", "message": "Only authority can remove members"}

            # Do not allow removing group creator from members.
            if str(member_id) == str(group.get("created_by")):
                return {"status": "error", "message": "Cannot remove group creator"}

            self.db.groups.update_one(
                {"_id": ObjectId(group_id)},
                {"$pull": {"members": ObjectId(member_id)}}
            )

            return {
                "status": "success",
                "message": "Member removed from group"
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def delete_group(self, group_id: str, authorized_by: str) -> dict:
        """
        Delete a group
        """
        try:
            authorizer = self.db.users.find_one({"_id": ObjectId(authorized_by)})
            if not authorizer or authorizer.get("role") != "authority":
                return {"status": "error", "message": "Only authority can delete groups"}

            result = self.db.groups.delete_one({"_id": ObjectId(group_id)})
            if result.deleted_count == 0:
                return {"status": "error", "message": "Group not found"}

            return {
                "status": "success",
                "message": "Group deleted"
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def get_group_members(self, group_id: str) -> dict:
        """
        Get all members of a group with their details
        """
        try:
            group = self.db.groups.find_one({"_id": ObjectId(group_id)})
            if not group:
                return {"status": "error", "message": "Group not found"}

            members = []
            for member_id in group.get("members", []):
                member = self.db.users.find_one({"_id": member_id})
                if member:
                    members.append({
                        "id": str(member.get("_id")),
                        "username": member.get("username"),
                        "role": member.get("role")
                    })

            return {
                "status": "success",
                "group_id": str(group.get("_id")),
                "group_name": group.get("name"),
                "group_type": group.get("type"),
                "members": members
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}
