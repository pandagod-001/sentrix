import requests
BASE='http://127.0.0.1:8001/api'

# Register and login
r = requests.post(f'{BASE}/auth/register', json={
    'username': 'test_auth4',
    'password': 'Auth@123',
    'role': 'authority'
})

r = requests.post(f'{BASE}/auth/login', json={
    'username': 'test_auth4',
    'password': 'Auth@123',
    'device_id': 'test'
})
token = r.json().get('data', {}).get('token')
print(f"Token: {token[:20]}..." if token else "No token")

if token:
    headers = {'Authorization': f'Bearer {token}'}
    r = requests.get(f'{BASE}/users', headers=headers)
    print(f'Status: {r.status_code}')
    if r.status_code != 200:
        print(f'Error: {r.json()}')
    else:
        print(f'Users: {len(r.json().get("users", []))} users')
        for u in r.json().get('users', []):
            print(f'  - {u["username"]}')
