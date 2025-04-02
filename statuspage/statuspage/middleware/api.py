"""
API-related middleware for Status Page.
"""
from django.conf import settings
from utilities.api import is_api_request


class APIVersionMiddleware:
    """
    If the request is for an API endpoint, include the API version as a response header.
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        if is_api_request(request):
            response['API-Version'] = settings.REST_FRAMEWORK_VERSION
        return response
