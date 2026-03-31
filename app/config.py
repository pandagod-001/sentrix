import os
from pathlib import Path


# ==============================
# Load .env manually (safe, no encoding issues)
# ==============================

BASE_DIR = Path(__file__).resolve().parent.parent
ENV_PATH = BASE_DIR / ".env"

if not ENV_PATH.exists():
    raise Exception(f".env file not found at {ENV_PATH}")


def load_env():
    try:
        with open(ENV_PATH, "r", encoding="utf-8") as file:
            for line in file:
                line = line.strip()

                # Skip empty lines and comments
                if not line or line.startswith("#"):
                    continue

                if "=" not in line:
                    continue

                key, value = line.split("=", 1)
                os.environ[key.strip()] = value.strip()

    except Exception as e:
        raise Exception(f"Failed to load .env file: {e}")


load_env()


# ==============================
# Load environment variables
# ==============================

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM")

MONGO_URL = os.getenv("MONGO_URL")
DB_NAME = os.getenv("DB_NAME")

AES_KEY = os.getenv("AES_KEY")


# ==============================
# Validation (NO silent failures)
# ==============================

missing_vars = []

if not SECRET_KEY:
    missing_vars.append("SECRET_KEY")

if not ALGORITHM:
    missing_vars.append("ALGORITHM")

if not MONGO_URL:
    missing_vars.append("MONGO_URL")

if not DB_NAME:
    missing_vars.append("DB_NAME")

if not AES_KEY:
    missing_vars.append("AES_KEY")


if missing_vars:
    raise Exception(f"Missing environment variables: {', '.join(missing_vars)}")


# ==============================
# Security validations
# ==============================

# AES key must be 32 bytes (AES-256)
if len(AES_KEY) < 32:
    raise Exception("AES_KEY must be at least 32 characters long")

# Secret key basic check
if len(SECRET_KEY) < 32:
    raise Exception("SECRET_KEY should be strong (at least 32 chars)")


# ==============================
# Debug (safe for development only)
# ==============================

print("Configuration loaded successfully")
print(f"Database: {DB_NAME}")