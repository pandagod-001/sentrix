"""
Pytest Conftest - Shared fixtures for SENTRIX tests
"""

import requests
from datetime import datetime
import json

BASE_URL = "http://127.0.0.1:8001/api"

# Test user credentials
TEST_USERS = {
    "authority": {
        "username": "authority_admin",
        "password": "Authority@123",
        "role": "authority"
    },
    "personnel1": {
        "username": "personnel_one",
        "password": "Personnel@123",
        "role": "personnel"
    },
    "personnel2": {
        "username": "personnel_two",
        "password": "Personnel@456",
        "role": "personnel"
    },
    "dependent1": {
        "username": "dependent_one",
        "password": "Dependent@123",
        "role": "dependent"
    },
    "dependent2": {
        "username": "dependent_two",
        "password": "Dependent@456",
        "role": "dependent"
    }
}


def pytest_collect_file(parent):
    """Hook to customize pytest collection"""
    pass


# Import pytest dynamically for compatibility
import sys
if 'pytest' not in sys.modules:
    try:
        import pytest as _pytest  # type: ignore
        pytest = _pytest
    except ImportError:
        # Create placeholder for linting
        class pytest:
            @staticmethod
            def fixture(*args, **kwargs):
                def decorator(func):
                    # Store fixture metadata
                    func._pytest_fixture = True
                    return func
                return decorator
else:
    pytest = sys.modules['pytest']


@pytest.fixture(scope="session")
def user_creds():
    return TEST_USERS


@pytest.fixture(scope="session")
def token_authority(user_creds):
    creds = user_creds["authority"]
    requests.post(f"{BASE_URL}/auth/register", json={
        "username": creds["username"],
        "password": creds["password"],
        "role": creds["role"]
    })
    r = requests.post(f"{BASE_URL}/auth/login", json={
        "username": creds["username"],
        "password": creds["password"],
        "device_id": "test_device_authority"
    })
    if r.status_code == 200:
        return r.json().get('data', {}).get('token')
    return None


@pytest.fixture(scope="session")
def token_personnel1(token_authority, user_creds):
    creds = user_creds["personnel1"]
    
    # Register
    requests.post(f"{BASE_URL}/auth/register", json={
        "username": creds["username"],
        "password": creds["password"],
        "role": creds["role"]
    })
    
    # Approve by authority (get user_id first)
    headers_auth = {"Authorization": f"Bearer {token_authority}"}
    users_r = requests.get(f"{BASE_URL}/users", headers=headers_auth)
    if users_r.status_code == 200:
        users_list = users_r.json().get("users", [])
        personnel_user = next((u for u in users_list if u.get("username") == creds["username"]), None)
        if personnel_user:
            requests.post(f"{BASE_URL}/users/{personnel_user.get('id')}/approve", headers=headers_auth)
    
    # Login
    r = requests.post(f"{BASE_URL}/auth/login", json={
        "username": creds["username"],
        "password": creds["password"],
        "device_id": "test_device_personnel1"
    })
    if r.status_code == 200:
        return r.json().get('data', {}).get('token')
    return None


@pytest.fixture(scope="session")
def token_personnel2(token_authority, user_creds):
    creds = user_creds["personnel2"]
    
    # Register
    requests.post(f"{BASE_URL}/auth/register", json={
        "username": creds["username"],
        "password": creds["password"],
        "role": creds["role"]
    })
    
    # Approve by authority (get user_id first)
    headers_auth = {"Authorization": f"Bearer {token_authority}"}
    users_r = requests.get(f"{BASE_URL}/users", headers=headers_auth)
    if users_r.status_code == 200:
        users_list = users_r.json().get("users", [])
        personnel_user = next((u for u in users_list if u.get("username") == creds["username"]), None)
        if personnel_user:
            requests.post(f"{BASE_URL}/users/{personnel_user.get('id')}/approve", headers=headers_auth)
    
    # Login
    r = requests.post(f"{BASE_URL}/auth/login", json={
        "username": creds["username"],
        "password": creds["password"],
        "device_id": "test_device_personnel2"
    })
    if r.status_code == 200:
        return r.json().get('data', {}).get('token')
    return None


@pytest.fixture(scope="session")
def user_ids(token_authority, token_personnel1, token_personnel2, token_dependent1, token_dependent2):
    headers_a = {"Authorization": f"Bearer {token_authority}"}
    headers_p1 = {"Authorization": f"Bearer {token_personnel1}"}
    headers_p2 = {"Authorization": f"Bearer {token_personnel2}"}
    headers_d1 = {"Authorization": f"Bearer {token_dependent1}"}
    headers_d2 = {"Authorization": f"Bearer {token_dependent2}"}
    
    r_a = requests.get(f"{BASE_URL}/users/me", headers=headers_a)
    r_p1 = requests.get(f"{BASE_URL}/users/me", headers=headers_p1)
    r_p2 = requests.get(f"{BASE_URL}/users/me", headers=headers_p2)
    r_d1 = requests.get(f"{BASE_URL}/users/me", headers=headers_d1)
    r_d2 = requests.get(f"{BASE_URL}/users/me", headers=headers_d2)
    
    return {
        "authority": r_a.json().get("id") if r_a.status_code == 200 else None,
        "personnel1": r_p1.json().get("id") if r_p1.status_code == 200 else None,
        "personnel2": r_p2.json().get("id") if r_p2.status_code == 200 else None,
        "dependent1": r_d1.json().get("id") if r_d1.status_code == 200 else None,
        "dependent2": r_d2.json().get("id") if r_d2.status_code == 200 else None
    }


@pytest.fixture(scope="session")
def token_dependent(token_authority, user_creds):
    creds = user_creds["dependent1"]
    r = requests.post(f"{BASE_URL}/auth/login", json={
        "username": creds["username"],
        "password": creds["password"],
        "device_id": "test_device_dependent"
    })
    if r.status_code == 200:
        return r.json().get('data', {}).get('token')
    return None


@pytest.fixture(scope="session")
def token_dependent1(token_authority, user_creds):
    creds = user_creds["dependent1"]
    r = requests.post(f"{BASE_URL}/auth/login", json={
        "username": creds["username"],
        "password": creds["password"],
        "device_id": "test_device_dependent1"
    })
    if r.status_code == 200:
        return r.json().get('data', {}).get('token')
    return None


@pytest.fixture(scope="session")
def token_dependent2(token_authority, user_creds):
    creds = user_creds["dependent2"]
    
    # Register first
    requests.post(f"{BASE_URL}/auth/register", json={
        "username": creds["username"],
        "password": creds["password"],
        "role": creds["role"]
    })
    
    r = requests.post(f"{BASE_URL}/auth/login", json={
        "username": creds["username"],
        "password": creds["password"],
        "device_id": "test_device_dependent2"
    })
    if r.status_code == 200:
        return r.json().get('data', {}).get('token')
    return None


@pytest.fixture(scope="session")
def group_id(token_authority, user_ids):
    headers = {"Authorization": f"Bearer {token_authority}"}
    r = requests.post(f"{BASE_URL}/groups/create", headers=headers, json={
        "name": "Defence Unit Alpha",
        "description": "Official defence unit",
        "members": [user_ids["personnel1"], user_ids["personnel2"]]
    })
    if r.status_code in [200, 201]:
        return r.json().get("id") or r.json().get("group_id")
    return None


@pytest.fixture(scope="session")
def chat_id(token_personnel1, user_ids):
    headers = {"Authorization": f"Bearer {token_personnel1}"}
    r = requests.post(f"{BASE_URL}/chat/create", headers=headers, json={
        "recipient_id": user_ids["personnel2"]
    })
    if r.status_code in [200, 201]:
        return r.json().get("id") or r.json().get("chat_id")
    return None


@pytest.fixture(scope="session")
def code(token_personnel1, user_ids):
    headers = {"Authorization": f"Bearer {token_personnel1}"}
    r = requests.post(f"{BASE_URL}/connect/generate-code", headers=headers, json={
        "expires_in_minutes": 15
    })
    if r.status_code in [200, 201]:
        return r.json().get("data", {}).get("code")
    return None


@pytest.fixture(scope="session")
def dependent_ids(user_ids):
    return [user_ids.get("dependent1"), user_ids.get("dependent2")]


@pytest.fixture(scope="session")
def dependent_id(user_ids):
    return user_ids.get("dependent1")


@pytest.fixture(scope="session")
def group_ids(token_authority, user_ids):
    headers = {"Authorization": f"Bearer {token_authority}"}
    r = requests.post(f"{BASE_URL}/groups/create", headers=headers, json={
        "name": "Official Defence Group",
        "description": "Official group for testing",
        "members": [user_ids["personnel1"], user_ids["personnel2"]]
    })
    if r.status_code in [200, 201]:
        group_id = r.json().get("id") or r.json().get("group_id")
        return {"official_group": group_id}
    return {"official_group": None}
