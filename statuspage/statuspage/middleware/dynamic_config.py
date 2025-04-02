"""
Dynamic configuration middleware for Status Page.
"""
from statuspage.config import clear_config


class DynamicConfigMiddleware:
    """
    Store the cached Status-Page configuration in thread-local storage for the duration of the request.
    """
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        clear_config()
        return response
