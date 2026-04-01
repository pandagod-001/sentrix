"""
Routes package - all API endpoint routers
"""

from . import auth_routes
from . import user_routes
from . import chat_routes
from . import face_routes
from . import group_routes
from . import connection_routes

__all__ = [
    "auth_routes",
    "user_routes",
    "chat_routes",
    "face_routes",
    "group_routes",
    "connection_routes"
]
