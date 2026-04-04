"""
Connection Service

Handles QR code generation, connection requests, and secure user pairing
"""

import secrets
from datetime import datetime, timedelta
from bson import ObjectId


class ConnectionService:
    """
    Manages connection requests and QR-based pairing in SENTRIX
    """

    def __init__(self, db):
        self.db = db

    def generate_connection_code(self, requester_id: str, expires_in_minutes: int = 15) -> dict:
        """
        Generate a unique connection code for a user (personnel only)

        The code can be shared via QR or directly with another personnel to establish connection

        Args:
            requester_id: Personnel user creating the code
            expires_in_minutes: Code expiration time

        Returns:
            code or error
        """
        try:
            # Handle both string IDs and ObjectId
            if isinstance(requester_id, str):
                try:
                    user_id = ObjectId(requester_id)
                except:
                    user_id = requester_id
            else:
                user_id = requester_id
            
            print(f"[DEBUG] Looking for user with _id={user_id} (type={type(user_id).__name__})")
            print(f"[DEBUG] Users in database: {len(self.db.users.data)}")
            for i, user in enumerate(self.db.users.data):
                print(f"  User {i}: _id={user.get('_id')} (type={type(user.get('_id')).__name__}), username={user.get('username')}")
                
            requester = self.db.users.find_one({"_id": user_id})
            
            print(f"[DEBUG] Found user: {requester is not None}")

            if not requester:
                return {"status": "error", "message": "User not found"}

            if requester.get("role") != "personnel":
                return {"status": "error", "message": "Only personnel can generate connection codes"}

            # Generate unique code
            code = secrets.token_urlsafe(16)

            # Create connection document
            connection_doc = {
                "code": code,
                "requester_id": ObjectId(requester_id) if isinstance(requester_id, str) else requester_id,
                "responder_id": None,
                "status": "pending",
                "created_at": datetime.utcnow(),
                "expires_at": datetime.utcnow() + timedelta(minutes=expires_in_minutes)
            }

            result = self.db.connections.insert_one(connection_doc)

            return {
                "status": "success",
                "code": code,
                "expires_in_minutes": expires_in_minutes,
                "message": "Connection code generated"
            }
        except Exception as e:
            import traceback
            print(f"[ERROR] Exception in generate_connection_code: {e}")
            traceback.print_exc()
            return {"status": "error", "message": str(e)}

    def verify_and_connect(self, responder_id: str, code: str) -> dict:
        """
        Accept a connection request using the code

        Personnel scans QR/enters code to establish connection with another personnel

        Args:
            responder_id: Personnel accepting the connection
            code: Connection code

        Returns:
            result with chat creation or error
        """
        try:
            responder = self.db.users.find_one({"_id": ObjectId(responder_id)})

            if not responder:
                return {"status": "error", "message": "User not found"}

            if responder.get("role") != "personnel":
                return {"status": "error", "message": "Only personnel can accept connections"}

            # Find the connection
            connection = self.db.connections.find_one({"code": code})

            if not connection:
                return {"status": "error", "message": "Invalid connection code"}

            # Check if expired
            if datetime.utcnow() > connection.get("expires_at"):
                return {"status": "error", "message": "Connection code expired"}

            if connection.get("status") != "pending":
                return {"status": "error", "message": "Connection already processed"}

            requester_id = connection.get("requester_id")

            if str(requester_id) == str(responder_id):
                return {"status": "error", "message": "Cannot connect with yourself"}

            # Update connection status
            self.db.connections.update_one(
                {"_id": connection.get("_id")},
                {
                    "$set": {
                        "responder_id": ObjectId(responder_id),
                        "status": "approved"
                    }
                }
            )

            # Create chat between the two personnel
            chat_doc = {
                "participants": [ObjectId(requester_id), ObjectId(responder_id)],
                "type": "personal",
                "created_at": datetime.utcnow()
            }

            chat_result = self.db.chats.insert_one(chat_doc)

            return {
                "status": "success", 
                "chat_id": str(chat_result.inserted_id),
                "connected_with": str(requester_id),
                "message": "Connection established"
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def get_pending_connections(self, user_id: str) -> dict:
        """
        Get all pending connection requests for a user
        """
        try:
            connections = self.db.connections.find({
                "requester_id": ObjectId(user_id),
                "status": "pending"
            })
            
            conn_list = []
            if hasattr(connections, 'to_list'):
                conn_list = connections.to_list(None)
            else:
                conn_list = connections if isinstance(connections, list) else [connections]

            return {
                "status": "success",
                "pending_connections": [
                    {
                        "code": c.get("code"),
                        "created_at": c.get("created_at"),
                        "expires_at": c.get("expires_at")
                    }
                    for c in conn_list if c
                ]
            }
        except Exception as e:
            return {"status": "error", "pending_connections": []}

    def cancel_connection_request(self, code: str, user_id: str) -> dict:
        """
        Cancel a pending connection request
        """
        try:
            connection = self.db.connections.find_one({"code": code})

            if not connection:
                return {"status": "error", "message": "Connection not found"}

            if str(connection.get("requester_id")) != str(user_id):
                return {"status": "error", "message": "You can only cancel your own connection requests"}

            self.db.connections.update_one(
                {"_id": connection.get("_id")},
                {"$set": {"status": "cancelled"}}
            )

            return {
                "status": "success",
                "message": "Connection request cancelled"
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def cleanup_expired_connections(self) -> dict:
        """
        Remove expired connection codes (maintenance task)
        """
        try:
            result = self.db.connections.delete_many({
                "expires_at": {"$lt": datetime.utcnow()},
                "status": "pending"
            })

            return {
                "status": "success",
                "deleted_count": result.deleted_count if result else 0
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def get_connection_qr_data(self, code: str) -> dict:
        """
        Get QR-encodable data for a connection code

        Returns the code and requester info for QR generation
        """
        try:
            connection = self.db.connections.find_one({"code": code})

            if not connection:
                return {"status": "error", "message": "Connection not found"}

            requester = self.db.users.find_one(
                {"_id": connection.get("requester_id")}
            )

            qr_data = {
                "code": code,
                "requester_name": requester.get("username") if requester else "Unknown",
                "created_at": connection.get("created_at").isoformat() if connection.get("created_at") else None,
                "expires_at": connection.get("expires_at").isoformat() if connection.get("expires_at") else None
            }

            return {
                "status": "success",
                "qr_data": qr_data
            }
        except Exception as e:
            return {"status": "error", "message": str(e)}
