from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
import uvicorn

from app.routes import auth_routes, user_routes, chat_routes, face_routes, group_routes, connection_routes


# ==============================
# APP INITIALIZATION
# ==============================

app = FastAPI(
    title="SENTRIX Backend",
    description="Secure Defence Communication System",
    version="1.0.0"
)


def _cors_origins() -> list[str]:
    raw = os.getenv("CORS_ORIGINS", "")
    if raw.strip():
        return [origin.strip() for origin in raw.split(",") if origin.strip()]

    return [
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://10.0.2.2:8000",
        "http://localhost",
    ]


# ==============================
# CORS CONFIG (Frontend Support)
# ==============================

app.add_middleware(
    CORSMiddleware,
    allow_origins=_cors_origins(),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ==============================
# ROUTES REGISTRATION
# ==============================

app.include_router(auth_routes.router)
app.include_router(user_routes.router)
app.include_router(chat_routes.router)
app.include_router(face_routes.router)
app.include_router(group_routes.router)
app.include_router(connection_routes.router)


# ==============================
# STARTUP EVENT (OPTIONAL LOG)
# ==============================

@app.on_event("startup")
def startup_event():
    print("SENTRIX Backend Started Successfully")


# ==============================
# ROOT ENDPOINT
# ==============================

@app.get("/")
def root():
    return {
        "status": "running",
        "service": "SENTRIX Backend",
        "version": "1.0.0"
    }


# ==============================
# HEALTH CHECK
# ==============================

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "timestamp": "ok"
    }


if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", "8000")),
        reload=os.getenv("RELOAD", "false").lower() == "true",
    )