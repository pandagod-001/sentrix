"""
Comprehensive tests for Group Management system
Tests: Official Groups, Family Groups, Member management
"""

import requests

BASE = "http://127.0.0.1:8001/api"


def test_group_creation(token_authority, token_personnel1, user_ids):
    """Test creating official and family groups"""
    print("\n=== GROUP CREATION TEST ===")
    
    headers_auth = {"Authorization": f"Bearer {token_authority}"}
    headers_personnel = {"Authorization": f"Bearer {token_personnel1}"}
    
    # Test 1: Authority creates official group
    print("\n[1] Authority creates official group...")
    r = requests.post(
        f"{BASE}/groups/create",
        json={
            "name": "Security Team Alpha",
            "type": "official",
            "members": [user_ids["personnel1"], user_ids["personnel2"]]
        },
        headers=headers_auth
    )
    print(f"Status: {r.status_code}, Response: {r.json()}")
    assert r.status_code == 200, f"Failed to create official group: {r.text}"
    official_group = r.json()["data"]["group_id"]
    print(f"✓ Official group created: {official_group}")
    
    # Test 2: Personnel cannot create official group
    print("\n[2] Personnel cannot create official group...")
    r = requests.post(
        f"{BASE}/groups/create",
        json={
            "name": "Should Fail",
            "type": "official"
        },
        headers=headers_personnel
    )
    print(f"Status: {r.status_code}, Response: {r.json()}")
    assert r.status_code == 403, "Should reject non-authority official group creation"
    print("✓ Correctly rejected non-authority creation")
    
    # Test 3: Personnel creates family group (with dependents)
    print("\n[3] Personnel creates family group...")
    r = requests.post(
        f"{BASE}/groups/create-family",
        json={
            "name": "Soldier Family",
            "include_dependents": True
        },
        headers=headers_personnel
    )
    print(f"Status: {r.status_code}, Response: {r.json()}")
    assert r.status_code == 200, f"Failed to create family group: {r.text}"
    family_group = r.json()["data"]["group_id"]
    print(f"✓ Family group created: {family_group}")
    
    return {
        "official_group": official_group,
        "family_group": family_group
    }


def test_group_members(token_authority, token_personnel1, user_ids, group_ids):
    """Test adding/removing group members"""
    print("\n=== GROUP MEMBERS TEST ===")
    
    headers_auth = {"Authorization": f"Bearer {token_authority}"}
    headers_personnel = {"Authorization": f"Bearer {token_personnel1}"}
    
    official_group = group_ids["official_group"]
    
    # Test 1: Get group members
    print("\n[1] Get group members...")
    r = requests.get(
        f"{BASE}/groups/{official_group}/members",
        headers=headers_auth
    )
    print(f"Status: {r.status_code}, Response: {r.json()}")
    assert r.status_code == 200, f"Failed to get members: {r.text}"
    members = r.json()["data"]["members"]
    print(f"✓ Retrieved {len(members)} members")
    
    # Test 2: Add member to group (authority)
    print("\n[2] Authority adds member to group...")
    r = requests.post(
        f"{BASE}/groups/{official_group}/add-member",
        json={"user_id": user_ids["dependent1"]},
        headers=headers_auth
    )
    print(f"Status: {r.status_code}, Response: {r.json()}")
    assert r.status_code == 200, f"Failed to add member: {r.text}"
    print("✓ Member added successfully")
    
    # Test 3: Personnel cannot add member to official group
    print("\n[3] Personnel cannot add to official group...")
    r = requests.post(
        f"{BASE}/groups/{official_group}/add-member",
        json={"user_id": user_ids["dependent1"]},
        headers=headers_personnel
    )
    print(f"Status: {r.status_code}, Response: {r.json()}")
    assert r.status_code == 403, "Should reject non-authority member addition"
    print("✓ Correctly rejected unauthorized access")
    
    # Test 4: Remove member from group
    print("\n[4] Authority removes member from group...")
    r = requests.delete(
        f"{BASE}/groups/{official_group}/remove-member",
        json={"user_id": user_ids["personnel3"]},
        headers=headers_auth
    )
    print(f"Status: {r.status_code}, Response: {r.json()}")
    assert r.status_code == 200, f"Failed to remove member: {r.text}"
    print("✓ Member removed successfully")


def test_list_groups(token_authority, token_personnel1):
    """Test listing user groups"""
    print("\n=== LIST GROUPS TEST ===")
    
    headers_auth = {"Authorization": f"Bearer {token_authority}"}
    headers_personnel = {"Authorization": f"Bearer {token_personnel1}"}
    
    # Test 1: Authority lists all groups
    print("\n[1] Authority lists all groups...")
    r = requests.get(
        f"{BASE}/groups/list",
        headers=headers_auth
    )
    print(f"Status: {r.status_code}, Response: {r.json()}")
    assert r.status_code == 200, f"Failed to list groups: {r.text}"
    groups = r.json()["data"]["groups"]
    print(f"✓ Retrieved {len(groups)} groups")
    
    # Test 2: Personnel lists their groups
    print("\n[2] Personnel lists their groups...")
    r = requests.get(
        f"{BASE}/groups/list",
        headers=headers_personnel
    )
    print(f"Status: {r.status_code}, Response: {r.json()}")
    assert r.status_code == 200, f"Failed to list groups: {r.text}"
    personnel_groups = r.json()["data"]["groups"]
    print(f"✓ Personnel has {len(personnel_groups)} groups")


def test_group_restrictions(token_dependent, user_ids, group_ids):
    """Test that dependents cannot create groups"""
    print("\n=== GROUP RESTRICTIONS TEST ===")
    
    headers_dependent = {"Authorization": f"Bearer {token_dependent}"}
    
    # Test 1: Dependent cannot create official group
    print("\n[1] Dependent cannot create official group...")
    r = requests.post(
        f"{BASE}/groups/create",
        json={
            "name": "Should Fail",
            "type": "official"
        },
        headers=headers_dependent
    )
    print(f"Status: {r.status_code}, Response: {r.json()}")
    assert r.status_code == 403, "Dependent should not create official groups"
    print("✓ Correctly rejected dependent group creation")
    
    # Test 2: Dependent cannot create family group
    print("\n[2] Dependent cannot create family group...")
    r = requests.post(
        f"{BASE}/groups/create-family",
        json={"name": "Should Fail"},
        headers=headers_dependent
    )
    print(f"Status: {r.status_code}, Response: {r.json()}")
    assert r.status_code == 403, "Dependent should not create groups"
    print("✓ Correctly rejected dependent family group creation")


def run(tokens, user_ids):
    """Run all group tests"""
    try:
        group_ids = test_group_creation(
            tokens["authority"],
            tokens["personnel"],
            user_ids
        )
        
        # Verify group creation succeeded before member tests
        assert group_ids, "Group creation failed"
        print("\n✓ Group creation tests passed")
        
        test_group_members(
            tokens["authority"],
            tokens["personnel"],
            user_ids,
            group_ids
        )
        print("✓ Group member tests passed")
        
        test_list_groups(tokens["authority"], tokens["personnel"])
        print("✓ List groups tests passed")
        
        if "dependent" in tokens:
            test_group_restrictions(tokens["dependent"], user_ids, group_ids)
            print("✓ Group restriction tests passed")
        
        print("\n✓✓✓ ALL GROUP TESTS PASSED ✓✓✓")
        return True
        
    except AssertionError as e:
        print(f"\n✗✗✗ GROUP TEST FAILED: {e}")
        return False
    except Exception as e:
        print(f"\n✗✗✗ GROUP TEST ERROR: {e}")
        return False
