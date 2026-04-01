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

    dependents = user.get("dependents", [])
    dependent_names = []
    if dependents:
        dependent_names = [d.get("name", "Unknown") for d in dependents]

    return {
        "id": str(user.get("_id")),
        "username": user.get("username"),
        "role": user.get("role"),
        "email": user.get("email"),

        # Security fields
        "is_approved": user.get("is_approved", False),
        "verified": user.get("verified", False),

        # Device & session tracking
        "device_id": user.get("device_id"),
        "last_login": user.get("last_login"),
        "face_registered": user.get("face_registered", False),

        # Relationship
        "linked_personnel_id": (
            str(user.get("linked_personnel_id"))
            if user.get("linked_personnel_id") else None
        ),
        "dependent_count": len(dependents),
        "dependent_names": dependent_names
    }


# ==============================
# USER DB STRUCTURE (Creation)
# ==============================

def create_user_document(username: str, password: str, role: str, email: str = None):
    """
    Standard structure for new users
    """
    # Authority users are auto-approved
    is_approved = (role == "authority")

    return {
        "username": username,
        "email": email,
        "password": password,
        "role": role,

        # Security controls
        "is_approved": is_approved,
        "verified": False,
        "face_registered": False,

        # Device & session
        "device_id": None,
        "last_login": None,

        # Relationship mapping
        "linked_personnel_id": None,
        "dependents": [],  # For personnel to link dependents

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
        "receiver": str(message.get("receiver")) if message.get("receiver") else None,
        "group_id": str(message.get("group_id")) if message.get("group_id") else None,
        "message": message.get("message"),
        "timestamp": message.get("timestamp")
    }


# ==============================
# MESSAGE DB STRUCTURE (Creation)
# ==============================

def create_message_document(sender_id: str, encrypted_message: str, receiver_id: str = None, group_id: str = None):
    """
    Standard structure for messages (supports both 1-to-1 and group chats)
    """
    return {
        "sender": parse_object_id(sender_id),
        "receiver": parse_object_id(receiver_id) if receiver_id else None,
        "group_id": parse_object_id(group_id) if group_id else None,
        "message": encrypted_message,
        "timestamp": datetime.utcnow()
    }


# ==============================
# DEPENDENT MODEL (Serializer)
# ==============================

def dependent_model(dependent) -> dict:
    """
    Convert MongoDB dependent document to API-safe format
    """
    if not dependent:
        return None

    return {
        "id": str(dependent.get("_id")),
        "name": dependent.get("name"),
        "linked_personnel_id": str(dependent.get("linked_personnel_id")) if dependent.get("linked_personnel_id") else None,
        "face_data": dependent.get("face_data") is not None,
        "created_at": dependent.get("created_at")
    }


def create_dependent_document(name: str, personnel_id: str, face_data=None):
    """
    Standard structure for dependents
    """
    return {
        "name": name,
        "linked_personnel_id": parse_object_id(personnel_id),
        "face_data": face_data,
        "created_at": datetime.utcnow()
    }


# ==============================
# GROUP MODEL (Serializer)
# ==============================

def group_model(group) -> dict:
    """
    Convert MongoDB group document to API-safe format
    """
    if not group:
        return None

    return {
        "id": str(group.get("_id")),
        "name": group.get("name"),
        "type": group.get("type"),  # "official" or "family"
        "created_by": str(group.get("created_by")) if group.get("created_by") else None,
        "members": [str(m) for m in group.get("members", [])],
        "created_at": group.get("created_at")
    }


def create_group_document(name: str, group_type: str, created_by: str, members: list):
    """
    Standard structure for groups
    """
    return {
        "name": name,
        "type": group_type,  # "official" or "family"
        "created_by": parse_object_id(created_by),
        "members": [parse_object_id(m) for m in members],
        "created_at": datetime.utcnow()
    }


# ==============================
# QR/CONNECTION MODEL (Serializer)
# ==============================

def connection_model(connection) -> dict:
    """
    Convert MongoDB connection document to API-safe format
    """
    if not connection:
        return None

    return {
        "id": str(connection.get("_id")),
        "code": connection.get("code"),
        "requester_id": str(connection.get("requester_id")) if connection.get("requester_id") else None,
        "responder_id": str(connection.get("responder_id")) if connection.get("responder_id") else None,
        "status": connection.get("status"),  # "pending", "approved", "rejected"
        "created_at": connection.get("created_at"),
        "expires_at": connection.get("expires_at")
    }


def create_connection_document(code: str, requester_id: str, expires_in_minutes: int = 15):
    """
    Standard structure for connection requests
    """
    from datetime import timedelta
    return {
        "code": code,
        "requester_id": parse_object_id(requester_id),
        "responder_id": None,
        "status": "pending",
        "created_at": datetime.utcnow(),
        "expires_at": datetime.utcnow() + timedelta(minutes=expires_in_minutes)
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