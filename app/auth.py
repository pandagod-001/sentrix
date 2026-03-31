from datetime import datetime, timedelta
from jose import jwt, JWTError
from passlib.context import CryptContext

from app.config import SECRET_KEY, ALGORITHM


# ==============================
# PASSWORD HASHING SETUP
# ==============================

pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")


# ==============================
# HASH PASSWORD (SAFE)
# ==============================

def hash_password(password: str) -> str:
    """
    Hash plain password using bcrypt (safe handling)
    """
    try:
        # Ensure string and enforce bcrypt limit (72 bytes)
        password = str(password)
        password = password[:72]

        return pwd_context.hash(password)

    except Exception as e:
        raise Exception(f"Password hashing failed: {e}")


# ==============================
# VERIFY PASSWORD
# ==============================

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify plain password against hashed password
    """
    try:
        plain_password = str(plain_password)
        plain_password = plain_password[:72]

        return pwd_context.verify(plain_password, hashed_password)

    except Exception:
        return False


# ==============================
# JWT TOKEN CONFIG
# ==============================

ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24  # 24 hours


# ==============================
# CREATE TOKEN
# ==============================

def create_token(data: dict) -> str:
    """
    Create JWT token with expiration
    """
    try:
        to_encode = data.copy()

        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)

        to_encode.update({
            "exp": expire,
            "iat": datetime.utcnow()
        })

        token = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
        return token

    except Exception as e:
        raise Exception(f"Token creation failed: {e}")


# ==============================
# VERIFY TOKEN
# ==============================

def verify_token(token: str) -> dict:
    """
    Decode and validate JWT token
    Returns payload if valid, else None
    """
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])

        # Basic required fields check
        if "id" not in payload or "role" not in payload:
            return None

        return payload

    except JWTError:
        return None
    except Exception:
        return None


# ==============================
# GET CURRENT USER
# ==============================

def get_current_user(token: str) -> dict:
    """
    Wrapper to validate token and return user payload
    Raises exception if invalid
    """
    payload = verify_token(token)

    if not payload:
        raise Exception("Invalid or expired token")

    return payload