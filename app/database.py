# ==============================
# HYBRID DATABASE (AUTO FALLBACK)
# ==============================

from pymongo import MongoClient
from pymongo.errors import ConnectionFailure


USE_MEMORY_DB = False

try:
    client = MongoClient("mongodb://localhost:27017", serverSelectionTimeoutMS=2000)
    client.admin.command("ping")
    db = client["sentrix"]

    users_collection = db["users"]
    messages_collection = db["messages"]

    print("MongoDB connected")

except Exception:
    print("MongoDB not available → using in-memory DB")
    USE_MEMORY_DB = True


# ==============================
# MEMORY FALLBACK (SAME API)
# ==============================

if USE_MEMORY_DB:

    class FakeCollection:
        def __init__(self):
            self.data = {}

        def insert_one(self, doc):
            _id = str(len(self.data) + 1)
            doc["_id"] = _id
            self.data[_id] = doc
            return type("obj", (), {"inserted_id": _id})

        def find_one(self, query):
            for item in self.data.values():
                match = True
                for k, v in query.items():
                    if item.get(k) != v:
                        match = False
                if match:
                    return item
            return None

        def update_one(self, query, update):
            obj = self.find_one(query)
            if obj:
                if "$set" in update:
                    obj.update(update["$set"])

        def find(self, query=None):
            return list(self.data.values())

        def delete_one(self, query):
            obj = self.find_one(query)
            if obj:
                del self.data[obj["_id"]]


    users_collection = FakeCollection()
    messages_collection = FakeCollection()