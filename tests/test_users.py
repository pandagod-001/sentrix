import requests

BASE = "http://127.0.0.1:8000"

def run(user_ids):
    print("\n=== USER CONTROL TEST ===")

    # -----------------------------
    # LOGIN ADMIN
    # -----------------------------
    r = requests.post(f"{BASE}/auth/login", json={
        "username": "admin",
        "password": "1234",
        "device_id": "adminDevice"
    })

    try:
        data = r.json()
    except:
        print(" Invalid response:", r.text)
        return None

    print("LOGIN RESPONSE:", data)

    #  SAFE CHECK
    if "data" not in data or "access_token" not in data["data"]:
        print(" ADMIN LOGIN FAILED:", data)
        return None

    token = data["data"]["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    print(" ADMIN LOGIN SUCCESS")

    # -----------------------------
    # APPROVE USERS
    # -----------------------------
    for u in ["soldier", "family"]:
        if u not in user_ids:
            print(f"Missing user_id for {u}")
            continue

        r = requests.post(
            f"{BASE}/users/approve",
            json={"user_id": user_ids[u]},
            headers=headers
        )

        print("APPROVE:", u, r.json())

    return token