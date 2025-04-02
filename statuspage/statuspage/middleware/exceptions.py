"""
Exception handling middleware for Status Page.
"""
from django.conf import settings
from django.db import ProgrammingError
from django.http import Http404

from statuspage.views import server_error


class ExceptionHandlingMiddleware:
    """
    Intercept certain exceptions which are likely indicative of installation issues and provide helpful instructions
    to the user.
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        return self.get_response(request)

    def process_exception(self, request, exception):

        # Don't catch exceptions when in debug mode
        if settings.DEBUG:
            return

        # Ignore Http404s (defer to Django's built-in 404 handling)
        if isinstance(exception, Http404):
            return

        # Determine the type of exception. If it's a common issue, return a custom error page with instructions.
        custom_template = None
        if isinstance(exception, ProgrammingError):
            custom_template = 'exceptions/programming_error.html'
        elif isinstance(exception, ImportError):
            custom_template = 'exceptions/import_error.html'
        elif isinstance(exception, PermissionError):
            custom_template = 'exceptions/permission_error.html'

        # Return a custom error message, or fall back to Django's default 500 error handling
        if custom_template:
            return server_error(request, template_name=custom_template)
