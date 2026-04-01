import base64
import requests
import asyncio
import websockets


BASE = "http://127.0.0.1:8001/api"
DEVICE = "testDevice"   


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

    users = [
        {"username": "admin", "password": "1234", "role": "authority"},
        {"username": "soldier", "password": "1234", "role": "personnel"},
        {"username": "family", "password": "1234", "role": "dependent"},
    ]

    ids = {}

    for u in users:
        r = requests.post(f"{BASE}/auth/register", json=u).json()
        print("REGISTER:", r)

        if r.get("status") != "success":
            raise Exception("AUTH FAILED")

        ids[u["username"]] = r["data"]["user_id"]

    return ids


# ==============================
# USER APPROVAL + LOGIN
# ==============================

def user_run(user_ids):
    print("\n=== USER CONTROL TEST ===")

    # Admin login
    r = requests.post(f"{BASE}/auth/login", json={
        "username": "admin",
        "password": "1234",
        "device_id": DEVICE
    }).json()

    print("LOGIN RESPONSE:", r)

    if r.get("status") != "success":
        raise Exception("ADMIN LOGIN FAILED")

    token = r["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    print("ADMIN LOGIN SUCCESS")

    # Approve users
    for u in ["soldier", "family"]:
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

def chat_login():
    print("\n=== LOGIN USER (CHAT TEST) ===")

    r = requests.post(f"{BASE}/auth/login", json={
        "username": "soldier",
        "password": "1234",
        "device_id": DEVICE
    }).json()

    print("LOGIN RESPONSE:", r)

    if r.get("status") != "success":
        raise Exception("USER LOGIN FAILED")

    print("USER LOGIN SUCCESS")

    return r["data"]["access_token"]


# ==============================
# WEBSOCKET TEST
# ==============================

async def ws_test(token):
    print("\n=== WEBSOCKET TEST ===")

    uri = f"ws://127.0.0.1:8001/api/chat/ws/{token}"

    async with websockets.connect(uri) as ws:
        print("CONNECTED")

        # receive connection message
        response = await ws.recv()
        print("RESPONSE:", response)

        # send test message
        await ws.send(
            '{"receiver_id":"2","message":"hello","device_id":"testDevice"}'
        )

        response = await ws.recv()
        print("MESSAGE RESPONSE:", response)


# ==============================
# MAIN RUNNER
# ==============================

def main():
    print("\nRUNNING FULL BACKEND TEST SUITE")

    user_ids = auth_run()

    admin_token = user_run(user_ids)

    #  FACE FOR ADMIN
    face_run(admin_token)

    # Login soldier
    user_token = chat_login()

    #  FACE FOR USER (CRITICAL)
    face_run(user_token)

    # WebSocket test
    asyncio.run(ws_test(user_token))

    print("\nALL TESTS COMPLETED SUCCESSFULLY")


if __name__ == "__main__":
    main()