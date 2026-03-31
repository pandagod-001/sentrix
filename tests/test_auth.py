import requests

BASE = "http://127.0.0.1:8000"

def run():
    print("\n=== AUTH TEST ===")

    users = [
        {"username": "admin", "password": "1234", "role": "authority"},
        {"username": "soldier", "password": "1234", "role": "personnel"},
        {"username": "family", "password": "1234", "role": "dependent"}
    ]

    ids = {}

    for u in users:
        r = requests.post(f"{BASE}/auth/register", json=u)

        try:
            data = r.json()
        except:
            print("Invalid response:", r.text)
            continue

        print("REGISTER:", data)

        #  SAFE CHECK
        if "data" in data and "user_id" in data["data"]:
            ids[u["username"]] = data["data"]["user_id"]
        else:
            print(f" Failed to register {u['username']}:", data)

    return ids