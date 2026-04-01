from datetime import datetime
from bson import ObjectId

from app.database import db
from app.models import create_message_document, message_model
from app.services.encryption_service import encrypt_text, decrypt_text


# ==============================
# SAVE MESSAGE (ENCRYPTED)
# ==============================

def save_message(sender_id: str, receiver_id: str, plain_text: str):
    """
    Encrypt and store message securely
    """

    try:
        # --------------------------
        # Validate IDs
        # --------------------------
        sender_obj = ObjectId(sender_id)
        receiver_obj = ObjectId(receiver_id)

        # --------------------------
        # Encrypt message
        # --------------------------
        encrypted_message = encrypt_text(plain_text)

        # --------------------------
        # Create message document
        # --------------------------
        message_doc = create_message_document(
            sender_id,
            receiver_id,
            encrypted_message
        )

        # --------------------------
        # Insert into DB
        # --------------------------
        result = db.messages.insert_one(message_doc)

        return str(result.inserted_id)

    except Exception as e:
        raise Exception(f"Message saving failed: {e}")


# ==============================
# GET MESSAGES BETWEEN USERS
# ==============================

def get_messages(user1_id: str, user2_id: str):
    """
    Retrieve and decrypt messages between two users
    """

    try:
        user1_obj = ObjectId(user1_id)
        user2_obj = ObjectId(user2_id)

        # --------------------------
        # Query messages
        # --------------------------
        messages = messages_collection.find({
            "$or": [
                {"sender": user1_obj, "receiver": user2_obj},
                {"sender": user2_obj, "receiver": user1_obj}
            ]
        }).sort("timestamp", 1)

        result = []

        for msg in messages:
            try:
                decrypted = decrypt_text(msg["message"])
            except Exception:
                decrypted = "[DECRYPTION_FAILED]"

            result.append({
                "id": str(msg["_id"]),
                "sender": str(msg["sender"]),
                "receiver": str(msg["receiver"]),
                "message": decrypted,
                "timestamp": msg.get("timestamp")
            })

        return result

    except Exception as e:
        raise Exception(f"Fetching messages failed: {e}")


# ==============================
# GET LAST N MESSAGES (OPTIMIZED)
# ==============================

def get_recent_messages(user1_id: str, user2_id: str, limit: int = 50):
    """
    Get recent messages with limit (performance optimized)
    """

    try:
        user1_obj = ObjectId(user1_id)
        user2_obj = ObjectId(user2_id)

        messages = messages_collection.find({
            "$or": [
                {"sender": user1_obj, "receiver": user2_obj},
                {"sender": user2_obj, "receiver": user1_obj}
            ]
        }).sort("timestamp", -1).limit(limit)

        result = []

        for msg in reversed(list(messages)):
            try:
                decrypted = decrypt_text(msg["message"])
            except Exception:
                decrypted = "[DECRYPTION_FAILED]"

            result.append({
                "id": str(msg["_id"]),
                "sender": str(msg["sender"]),
                "receiver": str(msg["receiver"]),
                "message": decrypted,
                "timestamp": msg.get("timestamp")
            })

        return result

    except Exception as e:
        raise Exception(f"Fetching recent messages failed: {e}")


# ==============================
# DELETE MESSAGE (OPTIONAL CONTROL)
# ==============================

def delete_message(message_id: str, user_id: str):
    """
    Delete message only if user is sender
    """

    try:
        msg = db.messages.find_one({"_id": ObjectId(message_id)})

        if not msg:
            raise Exception("Message not found")

        if str(msg["sender"]) != user_id:
            raise Exception("Unauthorized delete attempt")

        db.messages.delete_one({"_id": ObjectId(message_id)})

        return True

    except Exception as e:
        raise Exception(f"Delete failed: {e}")