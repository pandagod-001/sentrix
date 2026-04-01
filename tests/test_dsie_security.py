import requests

BASE = "http://127.0.0.1:8001/api"

def run():
    print("\n=== DSIE SECURITY TEST ===")

    # wrong device
    r = requests.post(f"{BASE}/auth/login", json={
        "username": "soldier",
        "password": "1234",
        "device_id": "wrongDevice"
    })

    print("DEVICE CHECK:", r.json())

    # dependent trying restricted action
    r = requests.post(f"{BASE}/auth/login", json={
        "username": "family",
        "password": "1234",
        "device_id": "deviceF"
    })

    print("DEPENDENT LOGIN:", r.json())