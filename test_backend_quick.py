import requests
import json
import time

print('='*60)
print('BACKEND VALIDATION TEST SUITE')
print('='*60)

# Test 1: Health Check
print('\n[1] Health Check')
try:
    resp = requests.get('http://localhost:8014/')
    print(f'✓ Status: {resp.status_code}')
    print(f'  Response: {resp.json()}')
except Exception as e:
    print(f'✗ Error: {e}')

# Test 2: Auth Endpoint - Register
print('\n[2] Auth Register Endpoint')
try:
    username = f'testuser_{int(time.time())}'
    payload = {
        'username': username,
        'password': 'TestPassword123!'
    }
    resp = requests.post('http://localhost:8014/api/auth/register', json=payload)
    print(f'✓ Status: {resp.status_code}')
    result = resp.json()
    print(f'  Response: {result}')
    test_user = payload
except Exception as e:
    print(f'✗ Error: {e}')

# Test 3: Auth Endpoint - Login
print('\n[3] Auth Login Endpoint')
try:
    resp = requests.post('http://localhost:8014/api/auth/login', json=payload)
    print(f'✓ Status: {resp.status_code}')
    result = resp.json()
    print(f'  Has token: {"token" in result}')
    print(f'  Has user data: {"user" in result}')
    token = result.get('token')
except Exception as e:
    print(f'✗ Error: {e}')

# Test 4: User Profile Endpoint
print('\n[4] User Profile Endpoint')
if 'token' in locals() and token:
    try:
        headers = {'Authorization': f'Bearer {token}'}
        resp = requests.get('http://localhost:8014/api/users/profile', headers=headers)
        print(f'✓ Status: {resp.status_code}')
        profile = resp.json()
        print(f'  Username: {profile.get("username", "N/A")}')
        print(f'  Email: {profile.get("email", "N/A")}')
    except Exception as e:
        print(f'✗ Error: {e}')

# Test 5: Face Auth Endpoint  
print('\n[5] Face Auth Endpoint Check')
try:
    resp = requests.get('http://localhost:8014/api/face-auth/health')
    print(f'✓ Status: {resp.status_code}')
    print(f'  Response: {resp.json()}')
except Exception as e:
    print(f'✗ Error: {e}')

# Test 6: Chat Endpoint Check
print('\n[6] Chat Endpoint Check')
if 'token' in locals() and token:
    try:
        headers = {'Authorization': f'Bearer {token}'}
        resp = requests.get('http://localhost:8014/api/chat/rooms', headers=headers)
        print(f'✓ Status: {resp.status_code}')
        print(f'  Chat rooms retrieved')
    except Exception as e:
        print(f'✗ Error: {e}')

print('\n' + '='*60)
print('VALIDATION COMPLETE')
print('='*60)
