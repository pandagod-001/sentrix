# ==============================
# HYBRID DATABASE (AUTO FALLBACK)
# ==============================

from pymongo import MongoClient
from pymongo.errors import ConnectionFailure

USE_MEMORY_DB = False
db = None
client = None

try:
    client = MongoClient("mongodb://localhost:27017", serverSelectionTimeoutMS=2000)
    client.admin.command("ping")
    db = client["sentrix"]

    users_collection = db["users"]
    messages_collection = db["messages"]
    groups_collection = db["groups"]
    connections_collection = db["connections"]
    chats_collection = db["chats"]

    print("✓ MongoDB connected (synchronous)")

except Exception as e:
    print(f"✗ MongoDB not available → using in-memory DB")
    print(f"  Error: {e}")
    USE_MEMORY_DB = True


# ==============================
# MEMORY FALLBACK (SAME API)
# ==============================

if USE_MEMORY_DB:

    class FakeCollection:
        def __init__(self):
            self.data = []  # Use list instead of dict for more reliable storage

        def insert_one(self, doc):
            from bson import ObjectId
            _id = ObjectId()
            doc["_id"] = _id
            self.data.append(doc)
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
                item_val = item.get(k)
                
                if k == "_id":
                    # For _id, compare as strings
                    if str(item_val) != str(v):
                        return False
                else:
                    # For other fields, direct comparison
                    if item_val != v:
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
            return type("obj", (), {"modified_count": 1 if obj else 0})()

        def delete_one(self, query):
            obj = self.find_one(query)
            if obj:
                self.data.remove(obj)
                return type("obj", (), {"deleted_count": 1})()
            return type("obj", (), {"deleted_count": 0})()

        def delete_many(self, query):
            to_delete = []
            for item in self.data:
                if self._matches(item, query):
                    to_delete.append(item)
            for item in to_delete:
                self.data.remove(item)
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
            return type("obj", (), {"inserted_ids": inserted_ids})()


    class FakeDB:
        def __init__(self):
            self.users = FakeCollection()
            self.messages = FakeCollection()
            self.groups = FakeCollection()
            self.connections = FakeCollection()
            self.chats = FakeCollection()


    users_collection = FakeCollection()
    messages_collection = FakeCollection()
    groups_collection = FakeCollection()
    connections_collection = FakeCollection()
    chats_collection = FakeCollection()
    
    db = FakeDB()
    
    # Share the same collection instances to ensure consistency
    users_collection = db.users
    messages_collection = db.messages
    groups_collection = db.groups
    connections_collection = db.connections
    chats_collection = db.chats
    
    print("✓ In-memory database initialized")
