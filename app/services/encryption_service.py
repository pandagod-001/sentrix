import base64
import os
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad

from app.config import AES_KEY


# ==============================
# PREPARE KEY (AES-256)
# ==============================

def get_aes_key():
    """
    Ensure AES key is exactly 32 bytes (AES-256)
    """
    key = AES_KEY.encode("utf-8")

    if len(key) < 32:
        key = key.ljust(32, b'0')
    elif len(key) > 32:
        key = key[:32]

    return key


# ==============================
# ENCRYPT TEXT (AES-CBC)
# ==============================

def encrypt_text(plain_text: str) -> str:
    """
    Encrypt text using AES-256-CBC
    Returns base64 encoded string (IV + ciphertext)
    """

    try:
        key = get_aes_key()

        # Generate random IV (16 bytes)
        iv = os.urandom(16)

        cipher = AES.new(key, AES.MODE_CBC, iv)

        # Pad and encrypt
        padded_text = pad(plain_text.encode("utf-8"), AES.block_size)
        encrypted_bytes = cipher.encrypt(padded_text)

        # Combine IV + encrypted data
        combined = iv + encrypted_bytes

        # Encode as base64 string
        encoded = base64.b64encode(combined).decode("utf-8")

        return encoded

    except Exception as e:
        raise Exception(f"Encryption failed: {e}")


# ==============================
# DECRYPT TEXT (AES-CBC)
# ==============================

def decrypt_text(cipher_text: str) -> str:
    """
    Decrypt AES-256-CBC encrypted text
    """

    try:
        key = get_aes_key()

        # Decode base64
        combined = base64.b64decode(cipher_text)

        # Extract IV and encrypted data
        iv = combined[:16]
        encrypted_bytes = combined[16:]

        cipher = AES.new(key, AES.MODE_CBC, iv)

        decrypted_padded = cipher.decrypt(encrypted_bytes)

        # Unpad
        decrypted = unpad(decrypted_padded, AES.block_size)

        return decrypted.decode("utf-8")

    except Exception as e:
        raise Exception(f"Decryption failed: {e}")