# ==============================
# HYBRID DATABASE (AUTO FALLBACK)
# ==============================

import os
import pickle
from pathlib import Path

from pymongo import MongoClient
from pymongo.errors import ConnectionFailure

USE_MEMORY_DB = False
db = None
client = None


def _load_env_from_file() -> None:
    """Load .env values early so DB config is available before other imports."""
    env_path = Path(__file__).resolve().parent.parent / ".env"
    if not env_path.exists():
        return

    try:
        with open(env_path, "r", encoding="utf-8") as env_file:
            for line in env_file:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, value = line.split("=", 1)
                # Keep explicit process env values if they already exist.
                os.environ.setdefault(key.strip(), value.strip())
    except Exception:
        # If .env parsing fails, standard environment variables can still be used.
        pass


_load_env_from_file()

try:
    # Prefer explicit Atlas URI, then .env MONGO_URL, then localhost fallback.
    mongo_uri = os.getenv("MONGODB_URI") or os.getenv("MONGO_URL") or "mongodb://localhost:27017"
    db_name = os.getenv("DB_NAME", "sentrix")

    mongo_options = {"serverSelectionTimeoutMS": 5000}
    if mongo_uri.startswith("mongodb+srv://"):
        # Atlas requires TLS; use certifi CA bundle for consistent validation.
        try:
            import certifi

            mongo_options.update({
                "tls": True,
                "tlsCAFile": certifi.where(),
            })
        except Exception:
            # If certifi isn't available, fallback to pymongo defaults.
            mongo_options.update({"tls": True})

    client = MongoClient(mongo_uri, **mongo_options)
    client.admin.command("ping")
    db = client[db_name]

    users_collection = db["users"]
    messages_collection = db["messages"]
    groups_collection = db["groups"]
    connections_collection = db["connections"]
    chats_collection = db["chats"]
    face_scans_collection = db["face_scans"]

    print(f"✓ MongoDB connected (synchronous) -> {db_name}")

except Exception as e:
    print(f"✗ MongoDB not available → using in-memory DB")
    print(f"  Error: {e}")
    USE_MEMORY_DB = True


# ==============================
# MEMORY FALLBACK (SAME API)
# ==============================

if USE_MEMORY_DB:
    from passlib.context import CryptContext

    _pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")
    FALLBACK_DB_PATH = Path(__file__).resolve().parent.parent / ".sentrix_fallback_db.pkl"

    def _load_fallback_store() -> dict:
        default_store = {
            "users": [],
            "messages": [],
            "groups": [],
            "connections": [],
            "chats": [],
            "face_scans": [],
        }

        if not FALLBACK_DB_PATH.exists():
            return default_store

        try:
            with open(FALLBACK_DB_PATH, "rb") as store_file:
                loaded_store = pickle.load(store_file)
                if isinstance(loaded_store, dict):
                    for key, value in default_store.items():
                        loaded_store.setdefault(key, value)
                    return loaded_store
        except Exception:
            pass

        return default_store


    def _save_fallback_store(store: dict) -> None:
        try:
            temp_path = FALLBACK_DB_PATH.with_suffix(".tmp")
            with open(temp_path, "wb") as store_file:
                pickle.dump(store, store_file, protocol=pickle.HIGHEST_PROTOCOL)
            temp_path.replace(FALLBACK_DB_PATH)
        except Exception as e:
            print(f"Warning: failed to persist fallback DB: {e}")

    class FakeCollection:
        def __init__(self, store: dict, collection_name: str):
            self._store = store
            self._collection_name = collection_name
            self.data = self._store.setdefault(collection_name, [])

        def _persist(self):
            _save_fallback_store(self._store)

        def insert_one(self, doc):
            from bson import ObjectId
            _id = ObjectId()
            doc["_id"] = _id
            self.data.append(doc)
            self._persist()
            return type("obj", (), {"inserted_id": _id})()

        def find_one(self, query):
            """Find and return a single document matching the query"""
            for item in self.data:
                if self._matches(item, query):
                    return item
            return None

        def find(self, query=None):
            """Find and return all documents matching the query"""
            if query is None:
                query = {}
            matching = [item for item in self.data if self._matches(item, query)]
            
            class FindResult:
                def __init__(self, items):
                    self._items = items
                    
                def to_list(self, _=None):
                    return self._items
                
                def sort(self, *args, **kwargs):
                    return self
                
                def __iter__(self):
                    return iter(self._items)
            
            return FindResult(matching)

        def _matches(self, item, query):
            """Check if document matches all query conditions"""
            for k, v in query.items():
                if k == "$or":
                    conditions = v if isinstance(v, list) else []
                    if not any(self._matches(item, condition) for condition in conditions):
                        return False
                    continue

                item_val = item.get(k)
                
                if k == "_id":
                    if str(item_val) != str(v):
                        return False
                elif isinstance(v, dict):
                    # Minimal operator support for in-memory fallback compatibility.
                    if "$all" in v:
                        required_values = v.get("$all", [])
                        if not isinstance(item_val, list):
                            return False
                        item_values = {str(x) for x in item_val}
                        required = {str(x) for x in required_values}
                        if not required.issubset(item_values):
                            return False
                    elif "$in" in v:
                        options = v.get("$in", [])
                        option_values = {str(x) for x in options}
                        if isinstance(item_val, list):
                            if not any(str(x) in option_values for x in item_val):
                                return False
                        else:
                            if str(item_val) not in option_values:
                                return False
                    else:
                        # Unsupported operator block in fallback mode.
                        return False
                else:
                    # For list fields, support membership query semantics.
                    if isinstance(item_val, list):
                        if not any(str(x) == str(v) for x in item_val):
                            return False
                    else:
                        if str(item_val) != str(v):
                            return False
            return True

        def update_one(self, query, update):
            obj = self.find_one(query)
            if obj:
                if "$set" in update:
                    obj.update(update["$set"])
                if "$push" in update:
                    for k, v in update["$push"].items():
                        if k not in obj:
                            obj[k] = []
                        obj[k].append(v)
                if "$pull" in update:
                    for k, v in update["$pull"].items():
                        if k in obj:
                            if isinstance(obj[k], list):
                                obj[k] = [item for item in obj[k] if item != v]
                self._persist()
            return type("obj", (), {"matched_count": 1 if obj else 0, "modified_count": 1 if obj else 0})()

        def delete_one(self, query):
            obj = self.find_one(query)
            if obj:
                self.data.remove(obj)
                self._persist()
                return type("obj", (), {"deleted_count": 1})()
            return type("obj", (), {"deleted_count": 0})()

        def delete_many(self, query):
            to_delete = []
            for item in self.data:
                if self._matches(item, query):
                    to_delete.append(item)
            for item in to_delete:
                self.data.remove(item)
            if to_delete:
                self._persist()
            return type("obj", (), {"deleted_count": len(to_delete)})()
        
        def insert_many(self, docs):
            """Insert multiple documents"""
            from bson import ObjectId
            inserted_ids = []
            for doc in docs:
                _id = ObjectId()
                doc["_id"] = _id
                self.data.append(doc)
                inserted_ids.append(_id)
            if inserted_ids:
                self._persist()
            return type("obj", (), {"inserted_ids": inserted_ids})()


    class FakeDB:
        def __init__(self):
            self._store = _load_fallback_store()
            self.users = FakeCollection(self._store, "users")
            self.messages = FakeCollection(self._store, "messages")
            self.groups = FakeCollection(self._store, "groups")
            self.connections = FakeCollection(self._store, "connections")
            self.chats = FakeCollection(self._store, "chats")
            self.face_scans = FakeCollection(self._store, "face_scans")
    
    db = FakeDB()
    
    # Share the same collection instances to ensure consistency
    users_collection = db.users
    messages_collection = db.messages
    groups_collection = db.groups
    connections_collection = db.connections
    chats_collection = db.chats
    face_scans_collection = db.face_scans

    # Seed predictable demo users so login still works after backend restarts.
    if users_collection.find_one({"username": "admin1"}) is None:
        users_collection.insert_one({
            "username": "admin1",
            "password": _pwd_context.hash("TestPassword123!"),
            "role": "authority",
            "is_approved": True,
            "verified": False,
            "device_id": None,
            "face_encoding": None,
            "dependents": [],
        })

    if users_collection.find_one({"username": "person1"}) is None:
        users_collection.insert_one({
            "username": "person1",
            "password": _pwd_context.hash("TestPassword123!"),
            "role": "personnel",
            "is_approved": True,
            "verified": False,
            "device_id": None,
            "face_encoding": None,
            "dependents": [],
        })

    # Seed stable demo users used in multi-device chat demos.
    demo_users = [
        {
            "username": "authority_setup_085956",
            "password": "123",
            "role": "authority",
            "is_approved": True,
            "device_id": "device_authority_setup_01",
        },
        {
            "username": "personnelA_085956",
            "password": "1234",
            "role": "personnel",
            "is_approved": True,
            "device_id": "device_personnelA_01",
        },
        {
            "username": "personnelB_085956",
            "password": "1234",
            "role": "personnel",
            "is_approved": True,
            "device_id": "device_personnelB_01",
        },
        {
            "username": "dependentA_085956",
            "password": "1234",
            "role": "dependent",
            "is_approved": True,
            "device_id": "device_dependentA_01",
        },
        {
            "username": "dependentB_085956",
            "password": "1234",
            "role": "dependent",
            "is_approved": True,
            "device_id": "device_dependentB_01",
        },
    ]

    for demo_user in demo_users:
        if users_collection.find_one({"username": demo_user["username"]}) is None:
            users_collection.insert_one({
                "username": demo_user["username"],
                "password": _pwd_context.hash(demo_user["password"]),
                "role": demo_user["role"],
                "is_approved": demo_user["is_approved"],
                "verified": True,
                "device_id": demo_user["device_id"],
                "face_encoding": None,
                "face_registered": True,
                "dependents": [],
            })
    
    print("✓ In-memory database initialized")
