import requests
import json

BASE='http://127.0.0.1:8001/api'

# Register and get token for authority
print("1. Register authority...")
r = requests.post(f'{BASE}/auth/register', json={
    'username': 'test_auth_final',
    'password': 'Auth@123',
    'role': 'authority'
})
print(f"Register: {r.status_code}")

r = requests.post(f'{BASE}/auth/login', json={
    'username': 'test_auth_final',
    'password': 'Auth@123',
    'device_id': 'test'
})
auth_token = r.json().get('data', {}).get('token')
print(f'Authority token: {auth_token[:20] if auth_token else "None"}...')

# Register personnel
print("\n2. Register personnel...")
r = requests.post(f'{BASE}/auth/register', json={
    'username': 'test_personnel_final',
    'password': 'Pers@123',
    'role': 'personnel'
})
print(f"Register: {r.status_code}")

# Get all users and approve personnel
headers_auth = {'Authorization': f'Bearer {auth_token}'}
r = requests.get(f'{BASE}/users', headers=headers_auth)
print(f"\nGet users: {r.status_code}")
all_users = r.json().get('users', [])
personnel_user = next((u for u in all_users if u['username'] == 'test_personnel_final'), None)
if personnel_user:
    print(f"Found personnel: {personnel_user['id']}")
    
    # Approve
    r = requests.post(f'{BASE}/users/{personnel_user["id"]}/approve', headers=headers_auth)
    print(f"Approve: {r.status_code} - {r.json()}")

# Login as personnel
print("\n3. Login personnel...")
r = requests.post(f'{BASE}/auth/login', json={
    'username': 'test_personnel_final',
    'password': 'Pers@123',
    'device_id': 'test'
})
pers_token = r.json().get('data', {}).get('token')
print(f'Personnel token: {pers_token[:20] if pers_token else "None"}...')

# Try to generate code
if pers_token:
    print("\n4. Generate QR code...")
    headers_pers = {'Authorization': f'Bearer {pers_token}'}
    r = requests.post(f'{BASE}/connect/generate-code', headers=headers_pers, json={})
    print(f'Status: {r.status_code}')
    print(f'Response: {json.dumps(r.json(), indent=2)}')
