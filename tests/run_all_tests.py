import base64
import json
import os
import requests
import asyncio
import websockets
from datetime import datetime, UTC


BASE = os.getenv("SENTRIX_TEST_BASE", "http://127.0.0.1:8001/api")
DEVICE = "testDevice"   


def _is_success(payload: dict) -> bool:
    return payload.get("success") is True or payload.get("status") == "success"


# ==============================
# LOAD TEST IMAGE
# ==============================

def load_image():
    with open("tests/face.jpg", "rb") as f:
        return base64.b64encode(f.read()).decode()


# ==============================
# AUTH TEST
# ==============================

def auth_run():
    print("\n=== AUTH TEST ===")

    suffix = datetime.now(UTC).strftime("%Y%m%d%H%M%S")
    admin_username = f"admin_{suffix}"
    soldier_username = f"soldier_{suffix}"
    soldier2_username = f"soldier2_{suffix}"

    users = [
        {"username": admin_username, "password": "1234", "role": "authority"},
        {"username": soldier_username, "password": "1234", "role": "personnel"},
        {"username": soldier2_username, "password": "1234", "role": "personnel"},
    ]

    ids = {}

    for u in users:
        r = requests.post(f"{BASE}/auth/register", json=u).json()
        print("REGISTER:", r)

        if not _is_success(r):
            raise Exception("AUTH FAILED")

        ids[u["username"]] = r["data"]["user_id"]

    return {
        "ids": ids,
        "admin": admin_username,
        "soldier": soldier_username,
        "soldier2": soldier2_username,
    }


# ==============================
# USER APPROVAL + LOGIN
# ==============================

def user_run(auth_ctx):
    print("\n=== USER CONTROL TEST ===")
    user_ids = auth_ctx["ids"]

    # Admin login
    r = requests.post(f"{BASE}/auth/login", json={
        "username": auth_ctx["admin"],
        "password": "1234",
        "device_id": DEVICE
    }).json()

    print("LOGIN RESPONSE:", r)

    if not _is_success(r):
        raise Exception("ADMIN LOGIN FAILED")

    token = r["data"].get("access_token") or r["data"].get("token")
    headers = {"Authorization": f"Bearer {token}"}

    print("ADMIN LOGIN SUCCESS")

    # Approve users
    for u in [auth_ctx["soldier"], auth_ctx["soldier2"]]:
        r = requests.post(
            f"{BASE}/users/approve",
            json={"user_id": user_ids[u]},
            headers=headers
        )
        print("APPROVE:", u, r.json())

    return token


# ==============================
# FACE FLOW (CRITICAL)
# ==============================

def face_run(token):
    print("\n=== FACE TEST ===")

    img = load_image()
    headers = {"Authorization": f"Bearer {token}"}

    # Register face
    r = requests.post(
        f"{BASE}/face/register",
        json={"image": img},
        headers=headers
    ).json()

    print("FACE REGISTER:", r)

    # Verify face
    r = requests.post(
        f"{BASE}/face/verify",
        json={"image": img},
        headers=headers
    ).json()

    print("FACE VERIFY:", r)

    if r.get("status") != "success":
        raise Exception("FACE VERIFICATION FAILED")


# ==============================
# USER LOGIN FOR CHAT
# ==============================

def chat_login(auth_ctx, username_key):
    print("\n=== LOGIN USER (CHAT TEST) ===")

    r = requests.post(f"{BASE}/auth/login", json={
        "username": auth_ctx[username_key],
        "password": "1234",
        "device_id": DEVICE
    }).json()

    print("LOGIN RESPONSE:", r)

    if not _is_success(r):
        raise Exception("USER LOGIN FAILED")

    print("USER LOGIN SUCCESS")

    return r["data"].get("access_token") or r["data"].get("token")


# ==============================
# WEBSOCKET TEST
# ==============================

async def ws_test(token, receiver_user_id):
    print("\n=== WEBSOCKET TEST ===")

    ws_base = BASE.replace("http://", "ws://").replace("https://", "wss://")
    ws_base = ws_base[:-4] if ws_base.endswith("/api") else ws_base
    uri = f"{ws_base}/api/chat/ws/{token}"

    async with websockets.connect(uri) as ws:
        print("CONNECTED")

        # receive connection message
        response = await ws.recv()
        print("RESPONSE:", response)

        # send test message
        await ws.send(json.dumps({
            "receiver_id": receiver_user_id,
            "message": "hello",
            "device_id": DEVICE
        }))

        response = await ws.recv()
        print("MESSAGE RESPONSE:", response)


# ==============================
# MAIN RUNNER
# ==============================

def main():
    print("\nRUNNING FULL BACKEND TEST SUITE")

    auth_ctx = auth_run()

    admin_token = user_run(auth_ctx)

    #  FACE FOR ADMIN
    face_run(admin_token)

    # Login soldier
    user_token = chat_login(auth_ctx, "soldier")

    # Login second personnel and register face for valid websocket receiver
    user2_token = chat_login(auth_ctx, "soldier2")

    #  FACE FOR USER (CRITICAL)
    face_run(user_token)
    face_run(user2_token)

    # WebSocket test
    receiver_id = auth_ctx["ids"][auth_ctx["soldier2"]]
    asyncio.run(ws_test(user_token, receiver_id))

    print("\nALL TESTS COMPLETED SUCCESSFULLY")


if __name__ == "__main__":
    main()