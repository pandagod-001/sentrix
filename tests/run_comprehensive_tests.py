"""
SENTRIX Comprehensive Test Suite
Runs all tests: Auth, Users, Groups, Connections, Dependents, DSIE, Flows
"""

import requests
import sys

# Import all test modules
import test_groups
import test_connections
import test_dependents
import test_dsie_comprehensive as test_dsie
import test_complete_flows as test_flows

BASE = "http://127.0.0.1:8001/api"

# Test users credentials
TEST_USERS = {
    "authority": {"username": "test_authority", "password": "auth_pass_123"},
    "personnel": {"username": "test_personnel", "password": "pers_pass_123"},
    "personnel2": {"username": "test_personnel2", "password": "pers2_pass_123"},
    "dependent": {"username": "test_dependent", "password": "dep_pass_123"},
    "dependent2": {"username": "test_dependent2", "password": "dep2_pass_123"},
}


def setup_test_environment():
    """Register test users and get tokens"""
    print("\n" + "="*70)
    print(" "*20 + "SENTRIX TEST SETUP")
    print("="*70)
    
    tokens = {}
    user_ids = {}
    
    print("\n[1] Registering test users...")
    for role, creds in TEST_USERS.items():
        role_type = "authority" if role == "authority" else \
                    "personnel" if "personnel" in role else "dependent"
        
        r = requests.post(
            f"{BASE}/auth/register",
            json={
                "username": creds["username"],
                "password": creds["password"],
                "role": role_type
            }
        )
        
        if r.status_code != 200:
            print(f"✗ Failed to register {role}: {r.text}")
            continue
        
        user_id = r.json()["data"]["user_id"]
        user_ids[role] = user_id
        print(f"✓ Registered {role}: {user_id}")
    
    print("\n[2] Approving users (authority needed for others)...")
    # Authority approves other users
    if "authority" in user_ids:
        r = requests.post(
            f"{BASE}/auth/login",
            json={
                "username": TEST_USERS["authority"]["username"],
                "password": TEST_USERS["authority"]["password"],
                "device_id": "test_device"
            }
        )
        
        if r.status_code == 200:
            auth_token = r.json()["data"]["access_token"]
            tokens["authority"] = auth_token
            headers = {"Authorization": f"Bearer {auth_token}"}
            
            # Approve others
            for role in ["personnel", "personnel2", "dependent", "dependent2"]:
                if role in user_ids:
                    r = requests.post(
                        f"{BASE}/users/approve",
                        json={"user_id": user_ids[role]},
                        headers=headers
                    )
                    if r.status_code == 200:
                        print(f"✓ Approved {role}")
                    else:
                        print(f"✗ Failed to approve {role}")
    
    print("\n[3] Logging in test users...")
    for role, creds in TEST_USERS.items():
        if role == "authority":
            continue  # Already logged in
        
        r = requests.post(
            f"{BASE}/auth/login",
            json={
                "username": creds["username"],
                "password": creds["password"],
                "device_id": f"test_device_{role}"
            }
        )
        
        if r.status_code != 200:
            print(f"✗ Failed to login {role}: {r.text}")
            continue
        
        token = r.json()["data"]["access_token"]
        tokens[role] = token
        print(f"✓ Logged in {role}")
    
    print("\n[4] Setting up relationships...")
    # Add some dependents for testing
    if "authority" in tokens and "personnel" in user_ids:
        headers = {"Authorization": f"Bearer {tokens['authority']}"}
        
        r = requests.post(
            f"{BASE}/users/{user_ids['personnel']}/add-dependent",
            json={\n                "dependent_name": "Test Dependent",
                "relationship": "child"
            },
            headers=headers
        )
        if r.status_code == 200:
            print("✓ Added dependent relationship")
    
    print("\n" + "="*70 + "\n")
    
    return tokens, user_ids


def run_all_tests(tokens, user_ids, user_creds):
    """Run all test suites"""
    
    results = {
        "groups": False,
        "connections": False,
        "dependents": False,
        "dsie": False,
        "flows": False
    }
    
    print("\n" + "="*70)
    print(" "*15 + "RUNNING ALL TEST SUITES")
    print("="*70)
    
    # Test 1: Groups
    print("\n[TEST 1/5] GROUP MANAGEMENT TESTS")
    print("-" * 70)
    try:
        results["groups"] = test_groups.run(tokens, user_ids)
    except Exception as e:
        print(f"✗ Groups test error: {e}")
        results["groups"] = False
    
    # Test 2: Connections
    print("\n[TEST 2/5] CONNECTION & QR TESTS")
    print("-" * 70)
    try:
        results["connections"] = test_connections.run(tokens, user_ids)
    except Exception as e:
        print(f"✗ Connections test error: {e}")
        results["connections"] = False
    
    # Test 3: Dependents
    print("\n[TEST 3/5] DEPENDENT MANAGEMENT TESTS")
    print("-" * 70)
    try:
        results["dependents"] = test_dependents.run(tokens, user_ids)
    except Exception as e:
        print(f"✗ Dependents test error: {e}")
        results["dependents"] = False
    
    # Test 4: DSIE Security
    print("\n[TEST 4/5] DSIE SECURITY ENGINE TESTS")
    print("-" * 70)
    try:
        results["dsie"] = test_dsie.run(tokens, user_ids)
    except Exception as e:
        print(f"✗ DSIE test error: {e}")
        results["dsie"] = False
    
    # Test 5: Complete Flows
    print("\n[TEST 5/5] SYSTEM FLOW TESTS")
    print("-" * 70)
    try:
        results["flows"] = test_flows.run(tokens, user_ids, user_creds)
    except Exception as e:
        print(f"✗ Flows test error: {e}")
        results["flows"] = False
    
    return results


def print_test_summary(results):
    """Print final test summary"""
    print("\n" + "="*70)
    print(" "*20 + "TEST SUMMARY")
    print("="*70)
    
    test_names = {
        "groups": "Group Management",
        "connections": "QR Connections",
        "dependents": "Dependent System",
        "dsie": "DSIE Security",
        "flows": "System Flows"
    }
    
    passed = sum(1 for v in results.values() if v)
    total = len(results)
    
    print(f"\nTotal: {passed}/{total} test suites passed\n")
    
    for test_key, test_name in test_names.items():
        status = "✓ PASSED" if results[test_key] else "✗ FAILED"
        print(f"  {status:12} - {test_name}")
    
    print("\n" + "="*70)
    
    if passed == total:
        print(" "*15 + "✓✓✓ ALL TESTS PASSED ✓✓✓")
        print("="*70)
        return 0
    else:
        print(f" "*10 + f"✗ {total - passed} test suite(s) failed")
        print("="*70)
        return 1


def main():
    """Main test execution"""
    print("\n")
    print("╔" + "="*68 + "╗")
    print("║" + " "*15 + "SENTRIX COMPREHENSIVE TEST SUITE" + " "*21 + "║")
    print("║" + " "*10 + "Testing all APIs and system flows per specification" + " "*7 + "║")
    print("╚" + "="*68 + "╝")
    
    try:
        # Setup
        tokens, user_ids = setup_test_environment()
        
        if not tokens:
            print("\n✗ Failed to setup test environment")
            return 1
        
        # Run all tests
        results = run_all_tests(tokens, user_ids, TEST_USERS)
        
        # Print summary
        return print_test_summary(results)
        
    except requests.exceptions.ConnectionError:
        print("\n✗ ERROR: Cannot connect to server at", BASE)
        print("  Make sure the SENTRIX server is running:")
        print("  uvicorn app.main:app --reload")
        return 1
    except Exception as e:
        print(f"\n✗ UNEXPECTED ERROR: {e}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
