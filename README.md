The system integrates authentication, biometric verification, device binding, and a dynamic security engine to enforce strict access control.

Core Idea

Traditional systems:

Authenticate once → allow everything

SENTRIX:

Authenticate → Verify identity → Validate device → Monitor behavior → Allow or block in real-time

This ensures that even if credentials are compromised, unauthorized access is prevented.

Architecture Flow

User → Login → JWT Token
   ↓
Face Registration & Verification
   ↓
Device Binding
   ↓
DSIE Security Engine (Risk Evaluation)
   ↓
WebSocket Communication (Real-time chat)

Key Components
1. Authentication (JWT)
Users log in using credentials
Backend generates a JWT token
Token is required for all protected routes

Security:

Stateless authentication
Token-based identity propagation
2. Face Verification System
Users register their face (base64 image → embedding)
Verification is required before accessing chat
Stored encoding is compared during verification

Purpose:

Prevent account misuse
Add biometric security layer
3. Device Binding
First login binds a device ID to the user
Future logins must match the same device

Security Benefit:

Prevents login from unknown devices
Stops credential sharing attacks
4. DSIE (Dynamic Security Intelligence Engine)

This is the core of the system.

Instead of static rules, DSIE calculates a risk score for every action.

Inputs:
User role
Device ID
Face verification status
Activity behavior
Message frequency
Metadata (optional)
Output:
ALLOW → normal operation
REAUTH → require face verification again
BLOCK → deny access
Example:
Device mismatch → increases risk
Rapid message spam → increases risk
Unverified face → increases risk
5. Role-Based Access Control

Roles:

Dependent
Can only chat with linked personnel
Cannot create groups
Restricted environment
Personnel
Can chat with multiple users
Can create groups
Moderate privileges
Authority
Full control
Can approve users
Can link dependents

All rules are enforced in backend (not frontend).

6. WebSocket Real-Time Communication
Persistent connection using WebSockets
Messages are sent instantly between users

Security enforced before every message:

DSIE check
Device validation
Face verification status
7. API Design

All APIs follow a strict format:

Success

{
"success": true,
"message": "optional",
"data": {}
}

Error

{
"success": false,
"message": "Error message"
}

This ensures predictable frontend integration.

Features
JWT Authentication
Face Recognition (Biometric Security)
Device Binding
Risk-Based Security Engine (DSIE)
Real-time WebSocket Chat
Role-Based Access Control
Structured API Responses
Tech Stack
FastAPI (Backend Framework)
Python
WebSockets (real-time communication)
OpenCV / Face Recognition
Custom Security Engine (DSIE)
Running the Project
uvicorn app.main:app --reload
Testing

Run full backend test suite:

python -m tests.run_all_tests
Why This Project Matters

Most systems rely on static authentication.

SENTRIX introduces:

Continuous identity validation
Behavioral monitoring
Adaptive security decisions

This makes it suitable for:

Defence communication systems
Secure enterprise messaging
Controlled environments
Future Enhancements
Liveness detection (anti-spoofing)
Geo-location anomaly detection
Machine learning-based risk scoring
End-to-end encryption
Summary

SENTRIX is a secure communication backend that combines authentication, biometrics, device trust, and behavioral intelligence into a unified system.

It moves beyond traditional login systems into continuous security enforcement.
