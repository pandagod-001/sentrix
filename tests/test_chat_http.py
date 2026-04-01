import requests

BASE = "http://127.0.0.1:8001/api"

def run():
    print("\n=== LOGIN USER (CHAT TEST) ===")

    r = requests.post(f"{BASE}/auth/login", json={
        "username": "soldier",
        "password": "1234",
        "device_id": "deviceA"
    })

    try:
        data = r.json()
    except:
        print("Invalid response:", r.text)
        return None

    print("LOGIN RESPONSE:", data)

    #  SAFE CHECK
    if "data" not in data or "access_token" not in data["data"]:
        print(" USER LOGIN FAILED:", data)
        return None

    token = data["data"]["access_token"]

    print(" USER LOGIN SUCCESS")
    return token