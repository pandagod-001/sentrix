"""
DSIE - Defence Security Intelligent Engine

Enforces zero-trust security decisions based on:
- Face authentication
- Device verification
- Authority approval
- Role validation
- Communication boundaries
"""

from datetime import datetime
from enum import Enum
from bson import ObjectId


class DSIEDecision(str, Enum):
    ALLOW = "allow"
    RE_AUTHENTICATE = "re-authenticate"
    BLOCK = "block"


class DSIEEngine:
    """
    Security decision engine for SENTRIX
    """

    def __init__(self, db):
        self.db = db

    def check_communication(self, sender_id: str, receiver_id: str = None, group_id: str = None) -> dict:
        """
        Validate if communication is allowed between two users or in a group

        Args:
            sender_id: User initiating communication
            receiver_id: Target user (for 1-to-1 chat)
            group_id: Target group (for group chat)

        Returns:
            {
                "decision": "allow"|"re-authenticate"|"block",
                "reason": str,
                "requires_face": bool
            }
        """
        try:
            sender = self.db.users.find_one({"_id": ObjectId(sender_id)})
            if not sender:
                return {
                    "decision": DSIEDecision.BLOCK,
                    "reason": "Sender not found",
                    "requires_face": False
                }

            # Check if sender is approved
            if not sender.get("is_approved"):
                return {
                    "decision": DSIEDecision.BLOCK,
                    "reason": "Sender not approved by authority",
                    "requires_face": False
                }

            # Check role-based restrictions
            sender_role = sender.get("role")

            # 1-to-1 Communication
            if receiver_id:
                receiver = self.db.users.find_one({"_id": ObjectId(receiver_id)})
                if not receiver:
                    return {
                        "decision": DSIEDecision.BLOCK,
                        "reason": "Receiver not found",
                        "requires_face": False
                    }

                # Check boundary rules
                boundary_check = self._check_communication_boundary(sender, receiver)
                if not boundary_check["allowed"]:
                    return {
                        "decision": DSIEDecision.BLOCK,
                        "reason": boundary_check["reason"],
                        "requires_face": False
                    }

            # Group Communication
            if group_id:
                group = self.db.groups.find_one({"_id": ObjectId(group_id)})
                if not group:
                    return {
                        "decision": DSIEDecision.BLOCK,
                        "reason": "Group not found",
                        "requires_face": False
                    }

                # Check if user is member of group
                if ObjectId(sender_id) not in group.get("members", []):
                    return {
                        "decision": DSIEDecision.BLOCK,
                        "reason": "User not a member of this group",
                        "requires_face": False
                    }

                # Official groups: only personnel
                if group.get("type") == "official" and sender_role != "personnel":
                    return {
                        "decision": DSIEDecision.BLOCK,
                        "reason": "Only personnel can access official groups",
                        "requires_face": False
                    }

            # All checks passed
            return {
                "decision": DSIEDecision.ALLOW,
                "reason": "Communication authorized",
                "requires_face": not sender.get("face_registered", False)
            }
        except Exception as e:
            return {
                "decision": DSIEDecision.BLOCK,
                "reason": f"Security check error: {str(e)}",
                "requires_face": False
            }

    def _check_communication_boundary(self, sender: dict, receiver: dict) -> dict:
        """
        Validate role-based communication boundaries

        Allowed patterns:
        - Any approved user ↔ any approved user
        """
        if sender.get("is_approved") and receiver.get("is_approved"):
            return {"allowed": True, "reason": "Approved user communication allowed"}

        return {"allowed": False, "reason": "User not approved"}

    def check_device_verification(self, user_id: str, device_id: str) -> dict:
        """
        Verify device against registered device for user
        """
        try:
            user = self.db.users.find_one({"_id": ObjectId(user_id)})
            if not user:
                return {
                    "decision": DSIEDecision.BLOCK,
                    "reason": "User not found",
                    "verified": False
                }

            registered_device = user.get("device_id")

            if not registered_device:
                # First login - register device
                return {
                    "decision": DSIEDecision.ALLOW,
                    "reason": "Device registered",
                    "verified": False,
                    "is_first_login": True
                }

            if registered_device == device_id:
                return {
                    "decision": DSIEDecision.ALLOW,
                    "reason": "Device verified",
                    "verified": True,
                    "is_first_login": False
                }

            # Device mismatch - require re-authentication
            return {
                "decision": DSIEDecision.RE_AUTHENTICATE,
                "reason": "Device mismatch - re-authentication required",
                "verified": False,
                "is_first_login": False
            }
        except Exception as e:
            return {
                "decision": DSIEDecision.BLOCK,
                "reason": f"Device check error: {str(e)}",
                "verified": False
            }

    def check_face_authentication(self, user_id: str, face_match: bool) -> dict:
        """
        Validate face authentication status
        """
        try:
            user = self.db.users.find_one({"_id": ObjectId(user_id)})
            if not user:
                return {
                    "decision": DSIEDecision.BLOCK,
                    "reason": "User not found"
                }

            if not user.get("face_registered"):
                return {
                    "decision": DSIEDecision.RE_AUTHENTICATE,
                    "reason": "Face recognition not registered"
                }

            if not face_match:
                return {
                    "decision": DSIEDecision.BLOCK,
                    "reason": "Face authentication failed"
                }

            return {
                "decision": DSIEDecision.ALLOW,
                "reason": "Face authentication successful"
            }
        except Exception as e:
            return {
                "decision": DSIEDecision.BLOCK,
                "reason": f"Face check error: {str(e)}"
            }

    def check_role_access(self, user_id: str, required_role: str) -> dict:
        """
        Validate role-based access control
        """
        try:
            user = self.db.users.find_one({"_id": ObjectId(user_id)})
            if not user:
                return {
                    "decision": DSIEDecision.BLOCK,
                    "reason": "User not found"
                }

            user_role = user.get("role")

            if user_role == required_role or user_role == "authority":
                return {
                    "decision": DSIEDecision.ALLOW,
                    "reason": f"Role '{user_role}' has access"
                }

            return {
                "decision": DSIEDecision.BLOCK,
                "reason": f"Role '{user_role}' does not have access (requires '{required_role}')"
            }
        except Exception as e:
            return {
                "decision": DSIEDecision.BLOCK,
                "reason": f"Role check error: {str(e)}"
            }

    def get_security_audit(self, user_id: str) -> dict:
        """
        Get security audit log for a user
        """
        try:
            user = self.db.users.find_one({"_id": ObjectId(user_id)})
            if not user:
                return {"status": "error", "data": []}

            return {
                "status": "success",
                "data": user.get("audit_logs", []),
                "user_id": str(user.get("_id")),
                "role": user.get("role"),
                "is_approved": user.get("is_approved"),
                "face_registered": user.get("face_registered")
            }
        except Exception as e:
            return {"status": "error", "data": [], "error": str(e)}

    def log_security_event(self, user_id: str, event_type: str, details: str):
        """
        Log a security event in user's audit trail
        """
        try:
            self.db.users.update_one(
                {"_id": ObjectId(user_id)},
                {
                    "$push": {
                        "audit_logs": {
                            "event": event_type,
                            "details": details,
                            "timestamp": datetime.utcnow()
                        }
                    }
                }
            )
        except Exception as e:
            print(f"Error logging security event: {e}")
