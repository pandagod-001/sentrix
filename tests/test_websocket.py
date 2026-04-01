import asyncio
import websockets
import json

async def run(token):
    uri = f"ws://127.0.0.1:8001/api/chat/ws/{token}"

    async with websockets.connect(uri) as ws:
        print("CONNECTED")

        await ws.send(json.dumps({
            "receiver_id": "2",
            "message": "Hello from test",
            "device_id": "testDevice"
        }))

        response = await ws.recv()
        print("RESPONSE:", response)

def start(token):
    asyncio.run(run(token))