from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.auth import verify_token
from app.database import users_collection
from app.dsie import dsie_check
from app.services.chat_service import save_message


router = APIRouter(prefix="/api/chat", tags=["Chat"])


# ==============================
# CONNECTION MANAGER
# ==============================

class ConnectionManager:
    def __init__(self):
        self.active_connections = {}

    async def connect(self, user_id: str, websocket: WebSocket):
        await websocket.accept()
        self.active_connections[user_id] = websocket

    def disconnect(self, user_id: str):
        self.active_connections.pop(user_id, None)

    def get(self, user_id: str):
        return self.active_connections.get(user_id)


manager = ConnectionManager()


# ==============================
# WEBSOCKET ENDPOINT
# ==============================

@router.websocket("/ws/{token}")
async def websocket_endpoint(websocket: WebSocket, token: str):

    # --------------------------
    # STEP 1: TOKEN VALIDATION
    # --------------------------
    payload = verify_token(token)

    if not payload:
        await websocket.close(code=1008)
        return

    user_id = payload.get("id")

    # ✅ FIX: NO ObjectId
    user = users_collection.find_one({"_id": user_id})

    if not user:
        await websocket.close(code=1008)
        return

    # --------------------------
    # STEP 2: FACE VERIFICATION
    # --------------------------
    if not user.get("verified", False):
        await websocket.accept()
        await websocket.send_json({
            "message": "REAUTH_REQUIRED"
        })
        await websocket.close()
        return

    # --------------------------
    # CONNECT USER
    # --------------------------
    await manager.connect(user_id, websocket)

    await websocket.send_json({
        "sender_id": user_id,
        "message": "connected"
    })

    try:
        while True:
            data = await websocket.receive_json()

            receiver_id = data.get("receiver_id")
            message = data.get("message")
            device_id = data.get("device_id")

            if not receiver_id or not message:
                continue

            # ✅ FIX: NO ObjectId
            receiver = users_collection.find_one({"_id": receiver_id})

            if not receiver:
                continue

            # --------------------------
            # STEP 3: DSIE CHECK
            # --------------------------
            decision = dsie_check(
                {
                    "id": user_id,
                    "role": user.get("role"),
                    "is_approved": user.get("is_approved"),
                    "verified": user.get("verified"),
                    "device_id": user.get("device_id"),
                    "last_login": user.get("last_login")
                },
                action="chat",
                target={
                    "id": receiver_id,
                    "role": receiver.get("role")
                },
                metadata={"device_id": device_id}
            )

            # --------------------------
            # HANDLE SECURITY
            # --------------------------
            if decision == "BLOCK":
                await websocket.send_json({
                    "message": "Blocked"
                })
                continue

            if decision == "REAUTH":
                await websocket.send_json({
                    "message": "REAUTH_REQUIRED"
                })
                await websocket.close()
                return

            # --------------------------
            # SAVE MESSAGE
            # --------------------------
            message_id = save_message(user_id, receiver_id, message)

            payload_message = {
                "sender_id": user_id,
                "receiver_id": receiver_id,
                "message": message
            }

            # SEND TO RECEIVER
            receiver_ws = manager.get(receiver_id)
            if receiver_ws:
                await receiver_ws.send_json(payload_message)

            # CONFIRM TO SENDER
            await websocket.send_json(payload_message)

    except WebSocketDisconnect:
        manager.disconnect(user_id)

    except Exception as e:
        print(f"WebSocket error: {e}")
        manager.disconnect(user_id)