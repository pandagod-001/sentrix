from datetime import datetime, timedelta
from app.database import db


# ==============================
# ROLE POLICY DEFINITIONS
# ==============================

ROLE_RULES = {
    "dependent": {
        "can_chat_with": ["personnel"],
        "can_create_group": False,
        "restricted": True
    },
    "personnel": {
        "can_chat_with": ["personnel", "dependent"],
        "can_create_group": False,
        "restricted": False
    },
    "authority": {
        "can_chat_with": ["personnel", "dependent", "authority"],
        "can_create_group": True,
        "restricted": False
    }
}


# ==============================
# AUDIT LOGGING (CRITICAL)
# ==============================

def audit_log(user_id: str, action: str, status: str, reason: str = ""):
    try:
        from bson import ObjectId
        # Convert user_id to ObjectId if needed
        if isinstance(user_id, str):
            try:
                query_id = ObjectId(user_id)
            except:
                query_id = user_id
        else:
            query_id = user_id
            
        db.users.update_one(
            {"_id": query_id},
            {
                "$push": {
                    "audit_logs": {
                        "timestamp": datetime.utcnow(),
                        "action": action,
                        "status": status,
                        "reason": reason
                    }
                }
            }
        )
    except Exception as e:
        print(f"[AUDIT ERROR] {e}")


# ==============================
# DEVICE VALIDATION
# ==============================

def check_device(user: dict, device_id: str):
    registered_device = user.get("device_id")

    # No device registered → force reauth
    if not registered_device:
        return "REAUTH"

    # Device mismatch → hard block
    if registered_device != device_id:
        return "BLOCK"

    return "ALLOW"


# ==============================
# SESSION / BEHAVIOR CHECK
# ==============================

def check_activity(user: dict):
    last_login = user.get("last_login")

    if not last_login:
        return "ALLOW"

    if not isinstance(last_login, datetime):
        return "ALLOW"

    now = datetime.utcnow()

    # Rapid repeated access → suspicious
    if now - last_login < timedelta(seconds=1):
        return "REAUTH"

    return "ALLOW"


# ==============================
# MAIN DSIE ENGINE
# ==============================

def dsie_check(user: dict, action: str, target: dict = None, metadata: dict = None):
    """
    Central security engine

    Returns:
        ALLOW / BLOCK / REAUTH
    """

    try:
        # --------------------------
        # SAFE EXTRACTION
        # --------------------------
        user_id = user.get("id") or user.get("_id")
        role = user.get("role")

        if not user_id or not role:
            return "BLOCK"

        # --------------------------
        # 1. APPROVAL CHECK
        # --------------------------
        if not user.get("is_approved", False):
            audit_log(user_id, action, "BLOCK", "User not approved")
            return "BLOCK"

        # --------------------------
        # 2. FACE VERIFICATION CHECK
        # --------------------------
        if not user.get("verified", False):
            audit_log(user_id, action, "REAUTH", "User not face verified")
            return "REAUTH"

        # --------------------------
        # 3. ROLE VALIDATION
        # --------------------------
        rules = ROLE_RULES.get(role)

        if not rules:
            audit_log(user_id, action, "BLOCK", "Invalid role")
            return "BLOCK"

        # --------------------------
        # 4. CHAT PERMISSION
        # --------------------------
        if action == "chat" and target:
            target_role = target.get("role")

            if not target_role or target_role not in rules["can_chat_with"]:
                audit_log(user_id, action, "BLOCK", "Unauthorized communication")
                return "BLOCK"

        # --------------------------
        # 5. GROUP CREATION CONTROL
        # --------------------------
        if action == "create_group":
            if not rules["can_create_group"]:
                audit_log(user_id, action, "BLOCK", "Group creation denied")
                return "BLOCK"

        # --------------------------
        # 6. DEVICE VALIDATION
        # --------------------------
        if metadata and "device_id" in metadata:
            device_status = check_device(user, metadata["device_id"])

            if device_status != "ALLOW":
                audit_log(user_id, action, device_status, "Device validation failed")
                return device_status

        # --------------------------
        # 7. BEHAVIOR CHECK
        # --------------------------
        activity_status = check_activity(user)

        if activity_status != "ALLOW":
            audit_log(user_id, action, activity_status, "Suspicious activity")
            return activity_status

        # --------------------------
        # 8. CLOSED SYSTEM ENFORCEMENT
        # --------------------------
        if target and target.get("external", False):
            audit_log(user_id, action, "BLOCK", "External communication blocked")
            return "BLOCK"

        # --------------------------
        # FINAL DECISION
        # --------------------------
        audit_log(user_id, action, "ALLOW", "Passed all checks")
        return "ALLOW"

    except Exception as e:
        print(f"[DSIE ERROR] {e}")
        return "BLOCK"