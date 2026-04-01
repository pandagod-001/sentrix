import os
from pathlib import Path
from fastapi import HTTPException, status, Header
from app.database import db


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
# FastAPI Dependency Functions
# ==============================

def verify_token(authorization: str = Header(None)):
    """
    Verify and extract token from Authorization header
    
    Used with FastAPI Depends(verify_token)
    Returns token payload with user_id and role
    """
    from app.auth import verify_token as verify_token_func
    
    # Extract token from Authorization header
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authentication token"
        )
    
    # Handle "Bearer <token>" format
    token_str = None
    if authorization.startswith("Bearer "):
        token_str = authorization[7:]
    else:
        token_str = authorization
    
    # Verify token
    payload = verify_token_func(token_str)
    
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token"
        )
    
    # Normalize payload to use "user_id" instead of "id"
    if "id" in payload:
        payload["user_id"] = payload["id"]
    
    return payload


def get_db():
    """
    FastAPI dependency to get database connection
    """
    return db


# ==============================
# Debug (safe for development only)
# ==============================

print("Configuration loaded successfully")
print(f"Database: {DB_NAME}")
