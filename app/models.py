from bson import ObjectId
from datetime import datetime


# ==============================
# ObjectId Safe Conversion
# ==============================

def parse_object_id(value):
    """
    Convert string to ObjectId safely
    """
    try:
        if isinstance(value, ObjectId):
            return value
        return ObjectId(value)
    except Exception:
        return None


# ==============================
# USER MODEL (Serializer)
# ==============================

def user_model(user) -> dict:
    """
    Convert MongoDB user document to API-safe format
    """
    if not user:
        return None

    return {
        "id": str(user.get("_id")),
        "username": user.get("username"),
        "role": user.get("role"),

        # Security fields
        "is_approved": user.get("is_approved", False),
        "verified": user.get("verified", False),

        # Device & session tracking
        "device_id": user.get("device_id"),
        "last_login": user.get("last_login"),

        # Relationship
        "linked_personnel_id": (
            str(user.get("linked_personnel_id"))
            if user.get("linked_personnel_id") else None
        )
    }


# ==============================
# USER DB STRUCTURE (Creation)
# ==============================

def create_user_document(username: str, password: str, role: str):
    """
    Standard structure for new users
    """
    return {
        "username": username,
        "password": password,
        "role": role,

        # Security controls
        "is_approved": False,
        "verified": False,

        # Device & session
        "device_id": None,
        "last_login": None,

        # Relationship mapping
        "linked_personnel_id": None,

        # Audit logs
        "audit_logs": [],

        # Metadata
        "created_at": datetime.utcnow()
    }


# ==============================
# MESSAGE MODEL (Serializer)
# ==============================

def message_model(message) -> dict:
    """
    Convert MongoDB message document to API-safe format
    """
    if not message:
        return None

    return {
        "id": str(message.get("_id")),
        "sender": str(message.get("sender")),
        "receiver": str(message.get("receiver")),
        "message": message.get("message"),
        "timestamp": message.get("timestamp")
    }


# ==============================
# MESSAGE DB STRUCTURE (Creation)
# ==============================

def create_message_document(sender_id: str, receiver_id: str, encrypted_message: str):
    """
    Standard structure for messages
    """
    return {
        "sender": parse_object_id(sender_id),
        "receiver": parse_object_id(receiver_id),
        "message": encrypted_message,
        "timestamp": datetime.utcnow()
    }


# ==============================
# SAFE RESPONSE HELPERS
# ==============================

def success_response(data=None, message="Success"):
    return {
        "status": "success",
        "message": message,
        "data": data
    }


def error_response(message="Error"):
    return {
        "status": "error",
        "message": message
    }