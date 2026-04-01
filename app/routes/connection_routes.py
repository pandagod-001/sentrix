"""
Connection & QR Code Routes

Secure user pairing and connection establishment
"""

from fastapi import APIRouter, Depends, HTTPException, status
from ..services.connection_service import ConnectionService
from ..database import db
from ..config import verify_token, get_db

router = APIRouter(prefix="/api/connect", tags=["connection"])


@router.post("/generate-code")
def generate_connection_code(
    token: str = Depends(verify_token),
    request: dict = None
):
    """
    Generate a connection code (personnel only)
    """
    print("\n[CONNECTION-ROUTES] POST /generate-code called", flush=True)
    print(f"[CONNECTION-ROUTES] Token: {token}", flush=True)
    print(f"[CONNECTION-ROUTES] Request: {request}", flush=True)
    
    try:
        from ..database import db
        conn_service = ConnectionService(db)
        user_id = token.get("user_id")
        print(f"[CONNECTION-ROUTES] user_id from token: {user_id}, type={type(user_id).__name__}", flush=True)

        if request is None:
            request = {}
        expires_in = request.get("expires_in_minutes", 15)
        print(f"[CONNECTION-ROUTES] Calling generate_connection_code with requester_id={user_id}", flush=True)

        result = conn_service.generate_connection_code(
            requester_id=user_id,
            expires_in_minutes=expires_in
        )
        print(f"[CONNECTION-ROUTES] Result: {result}", flush=True)

        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message"))

        # Wrap in data for consistency
        return {
            "success": True,
            "data": {
                "code": result.get("code"),
                "expires_in_minutes": result.get("expires_in_minutes")
            }
        }

    except Exception as e:
        import traceback
        print(f"[CONNECTION-ROUTES] Exception: {e}", flush=True)
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/verify-code")
def verify_and_connect(
    request: dict,
    token: str = Depends(verify_token)
):
    """
    Accept a connection using a code/QR

    Personnel scans QR or enters code to establish connection

    Request:
    {
        "code": "connection_code"
    }

    Response:
    {
        "status": "success",
        "chat_id": "chat_id",
        "connected_with": "user_id"
    }
    """
    try:
        from ..database import db
        conn_service = ConnectionService(db)
        responder_id = token.get("user_id")
        code = request.get("code")

        result = conn_service.verify_and_connect(
            responder_id=responder_id,
            code=code
        )

        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message"))

        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/pending")
def get_pending_connections(
    token: str = Depends(verify_token)
):
    """
    Get all pending connection codes for authenticated user
    """
    try:
        from ..database import db
        conn_service = ConnectionService(db)
        user_id = token.get("user_id")

        result = conn_service.get_pending_connections(user_id)
        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/cancel")
def cancel_connection(
    request: dict,
    token: str = Depends(verify_token)
):
    """
    Cancel a pending connection request

    Request:
    {
        "code": "connection_code"
    }
    """
    try:
        from ..database import db
        conn_service = ConnectionService(db)
        user_id = token.get("user_id")
        code = request.get("code")

        result = conn_service.cancel_connection_request(code, user_id)

        if result.get("status") == "error":
            raise HTTPException(status_code=400, detail=result.get("message"))

        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{code}/qr-data")
def get_qr_data(
    code: str,
    token: str = Depends(verify_token)
):
    """
    Get QR-encodable data for a connection code

    Frontend can use this to generate QR code
    """
    try:
        from ..database import db
        conn_service = ConnectionService(db)

        result = conn_service.get_connection_qr_data(code)

        if result.get("status") == "error":
            raise HTTPException(status_code=404, detail=result.get("message"))

        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
