from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, HTTPException, status
from bson import ObjectId
from datetime import datetime
from ..database import db
from ..config import verify_token, get_db
from ..services.dsie_service import DSIEEngine, DSIEDecision
from ..models import create_message_document, message_model

router = APIRouter(prefix="/api/chat", tags=["Chat"])


# ==============================
# CONNECTION MANAGER (for WebSocket)
# ==============================

class ConnectionManager:
    def __init__(self):
        self.active_connections = {}  # user_id -> websocket

    async def connect(self, user_id: str, websocket: WebSocket):
        await websocket.accept()
        self.active_connections[user_id] = websocket

    def disconnect(self, user_id: str):
        self.active_connections.pop(user_id, None)

    def get(self, user_id: str):
        return self.active_connections.get(user_id)

    def get_all(self, user_ids: list):
        """Get all websockets for a list of user IDs"""
        return [
            self.active_connections[uid]
            for uid in user_ids
            if uid in self.active_connections
        ]


manager = ConnectionManager()


# ==============================
# CHAT CREATION ENDPOINT
# ==============================

@router.post("/create")
def create_chat(request: dict, token: str = Depends(verify_token)):
    """
    Create a new 1-to-1 chat with another user
    
    Request:
    {
        "recipient_id": "user_id"
    }
    """
    try:
        from ..database import chats_collection, users_collection
        user_id = ObjectId(token.get("user_id"))
        recipient_id = request.get("recipient_id")
        
        if not recipient_id:
            raise HTTPException(status_code=400, detail="Recipient ID required")
        
        recipient_id = ObjectId(recipient_id)
        
        # Verify recipient exists
        recipient = users_collection.find_one({"_id": recipient_id})
        if not recipient:
            raise HTTPException(status_code=404, detail="Recipient not found")
        
        # Check if chat already exists
        existing_chat = chats_collection.find_one({
            "type": "personal",
            "participants": {"$all": [user_id, recipient_id]}
        })
        
        if existing_chat:
            return {
                "status": "success",
                "id": str(existing_chat["_id"]),
                "message": "Chat already exists"
            }
        
        # Create new chat
        chat_doc = {
            "type": "personal",
            "participants": [user_id, recipient_id],
            "created_at": datetime.utcnow(),
            "messages_count": 0
        }
        
        result = chats_collection.insert_one(chat_doc)
        
        return {
            "status": "success",
            "id": str(result.inserted_id),
            "message": "Chat created successfully"
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==============================
# REST API ENDPOINTS
# ==============================

@router.get("/list")
def get_chats(token: str = Depends(verify_token)):
    """
    Get all chats for authenticated user (1-to-1 and group)
    """
    try:
        from ..database import chats_collection, users_collection
        user_id = ObjectId(token.get("user_id"))
        
        chats = list(chats_collection.find({
            "participants": user_id
        }))

        chat_list = []
        for chat in chats:
            participants = chat.get("participants", [])
            chat_type = chat.get("type", "personal")
            
            if chat_type == "personal":
                # Get other participant
                other_id = [p for p in participants if p != user_id][0] if len(participants) > 1 else None
                if other_id:
                    other_user = users_collection.find_one({"_id": other_id})
                    name = other_user.get("username") if other_user else "Unknown"
                else:
                    name = "Unknown"
            else:
                name = chat.get("name", "Group Chat")

            chat_list.append({
                "id": str(chat.get("_id")),
                "name": name,
                "type": chat_type,
                "last_message": "No messages",
                "last_message_time": None
            })

        return {
            "status": "success",
            "chats": chat_list
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{chat_id}/messages")
async def get_chat_messages(
    chat_id: str,
    token: str = Depends(verify_token),
    db=Depends(get_db),
    limit: int = 50
):
    """
    Get messages from a chat (historical chat loading)

    Query params:
    - limit: Number of messages to return (default: 50)
    """
    try:
        user_id = ObjectId(token.get("user_id"))
        chat_id = ObjectId(chat_id)

        # Verify user is in chat
        chat = await db.chats.find_one({"_id": chat_id})
        if not chat or user_id not in chat.get("participants", []):
            raise HTTPException(status_code=403, detail="Access denied")

        messages = await db.messages.find({
            "$or": [
                {"receiver": user_id, "sender": {"$in": chat.get("participants", [])}},
                {"group_id": chat_id}
            ]
        }).sort("_id", -1).limit(limit).to_list(None)

        messages.reverse()  # Reverse to show chronological order

        return {
            "status": "success",
            "messages": [
                {
                    "id": str(m.get("_id")),
                    "sender": str(m.get("sender")),
                    "message": m.get("message"),
                    "timestamp": m.get("timestamp")
                }
                for m in messages
            ]
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/send")
def send_message(request: dict, token: str = Depends(verify_token)):
    """
    Send a message (HTTP - for non-real-time)

    Request:
    {
        "receiver_id": "user_id",  # For 1-to-1
        "chat_id": "chat_id",      # For any chat
        "message": "encrypted_message_content"
    }
    """
    try:
        from ..database import messages_collection
        sender_id = token.get("user_id")
        chat_id = request.get("chat_id")
        receiver_id = request.get("receiver_id")
        message_text = request.get("message")

        if not message_text:
            raise HTTPException(status_code=400, detail="Message cannot be empty")

        # Create message document
        msg_doc = {
            "sender": ObjectId(sender_id),
            "receiver": ObjectId(receiver_id) if receiver_id else None,
            "group_id": ObjectId(chat_id) if chat_id else None,
            "message": message_text,
            "timestamp": datetime.utcnow(),
            "is_encrypted": True
        }

        result = messages_collection.insert_one(msg_doc)

        return {
            "status": "success",
            "message_id": str(result.inserted_id),
            "timestamp": msg_doc.get("timestamp").isoformat()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==============================
# WEBSOCKET ENDPOINT (Real-time)
# ==============================

@router.websocket("/ws/{token}")
async def websocket_chat(websocket: WebSocket, token: str, db=Depends(get_db)):
    """
    WebSocket for real-time messaging

    Client sends:
    {
        "receiver_id": "...",  // For 1-to-1
        "group_id": "...",     // For group
        "message": "..."
    }
    """
    try:
        # Verify token
        payload = verify_token(token)
        if not payload:
            await websocket.close(code=1008, reason="Invalid token")
            return

        user_id = payload.get("user_id")
        user = await db.users.find_one({"_id": ObjectId(user_id)})

        if not user:
            await websocket.close(code=1008, reason="User not found")
            return

        # Check face verification status
        if not user.get("face_registered"):
            await websocket.accept()
            await websocket.send_json({
                "error": "Face authentication required"
            })
            await websocket.close(code=1008, reason="Face not registered")
            return

        # Connect
        await manager.connect(user_id, websocket)

        await websocket.send_json({
            "status": "connected",
            "user_id": user_id
        })

        # Message loop
        while True:
            data = await websocket.receive_json()

            receiver_id = data.get("receiver_id")
            group_id = data.get("group_id")
            message_text = data.get("message")

            if not message_text or (not receiver_id and not group_id):
                continue

            # DSIE Check
            dsie = DSIEEngine(db)
            decision = await dsie.check_communication(user_id, receiver_id, group_id)

            if decision.get("decision") != DSIEDecision.ALLOW:
                await websocket.send_json({
                    "error": decision.get("reason"),
                    "type": "blocked"
                })
                await dsie.log_security_event(
                    user_id,
                    "message_blocked",
                    decision.get("reason")
                )
                continue

            # Save message
            msg_doc = create_message_document(
                sender_id=user_id,
                encrypted_message=message_text,
                receiver_id=receiver_id,
                group_id=group_id
            )
            msg_result = await db.messages.insert_one(msg_doc)

            # Prepare response
            response = {
                "message_id": str(msg_result.inserted_id),
                "sender_id": user_id,
                "receiver_id": receiver_id,
                "group_id": group_id,
                "message": message_text,
                "timestamp": msg_doc.get("timestamp").isoformat()
            }

            # Send to receiver(s)
            if receiver_id:
                # 1-to-1 chat
                receiver_ws = manager.get(receiver_id)
                if receiver_ws:
                    await receiver_ws.send_json(response)

            elif group_id:
                # Group chat
                group = await db.groups.find_one({"_id": ObjectId(group_id)})
                if group:
                    for member_id in group.get("members", []):
                        if str(member_id) != user_id:
                            member_ws = manager.get(str(member_id))
                            if member_ws:
                                await member_ws.send_json(response)

            # Confirm to sender
            await websocket.send_json(response)

            # Log
            await dsie.log_security_event(
                user_id,
                "message_sent",
                f"Target: {receiver_id or group_id}"
            )

    except WebSocketDisconnect:
        manager.disconnect(user_id)

    except Exception as e:
        print(f"WebSocket error: {e}")
        try:
            await websocket.close(code=1011, reason=str(e))
        except:
            pass
        if 'user_id' in locals():
            manager.disconnect(user_id)
