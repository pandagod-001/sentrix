def success_response(data=None, message=None):
    return {
        "status": "success",
        "success": True,
        "message": message,
        "data": data
    }


def error_response(message):
    return {
        "status": "error",
        "success": False,
        "message": message
    }