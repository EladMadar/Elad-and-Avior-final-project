from django.apps import AppConfig
import sys

def get_func_name(func):
    """Return the function's name."""
    return func.__name__ if hasattr(func, '__name__') else str(func)

class QueuingConfig(AppConfig):
    name = 'queuing'
    verbose_name = 'Queuing'

    def ready(self):
        # Skip scheduler initialization in these commands
        skip_commands = ['migrate', 'makemigrations', 'collectstatic', 'shell']
        
        # Get the current command
        command = sys.argv[1] if len(sys.argv) > 1 else None
        
        # Skip the scheduler initialization for certain commands
        if command in skip_commands:
            return
            
        try:
            import django_rq
            try:
                scheduler = django_rq.get_scheduler('default')
            except Exception:
                # Handle the case where rq_scheduler isn't installed or configured
                pass
        except ImportError:
            # django_rq not installed, skip
            pass
