"""
Status Page Configuration
"""
import os
import time

# Required parameters
ALLOWED_HOSTS = ['*', 'status.elad-avior.com']

# Database settings with connection retries
DB_CONNECT_RETRIES = int(os.environ.get('DB_CONNECT_RETRIES', 5))
DB_CONNECT_TIMEOUT = int(os.environ.get('DB_CONNECT_TIMEOUT', 60))

# Implement retry logic for database connections
for attempt in range(DB_CONNECT_RETRIES):
    try:
        import psycopg2
        conn = psycopg2.connect(
            host=os.environ.get('DB_HOST', 'status-page-prod-db.cx248m4we6k7.us-east-1.rds.amazonaws.com'),
            port=os.environ.get('DB_PORT', '5432'),
            user=os.environ.get('DB_USER', 'postgres'),
            password=os.environ.get('DB_PASSWORD', ''),
            database=os.environ.get('DB_NAME', 'statuspage'),
            connect_timeout=DB_CONNECT_TIMEOUT
        )
        conn.close()
        print(f"Database connection successful on attempt {attempt + 1}")
        break
    except Exception as e:
        print(f"Database connection attempt {attempt + 1} failed: {e}")
        if attempt < DB_CONNECT_RETRIES - 1:
            sleep_time = 5 * (attempt + 1)  # Progressive backoff
            print(f"Retrying in {sleep_time} seconds...")
            time.sleep(sleep_time)
        else:
            print("All database connection attempts failed")
            # Continue execution to allow Django to handle the connection errors

# Database configuration
DATABASE = {
    'NAME': os.environ.get('DB_NAME', 'statuspage'),
    'USER': os.environ.get('DB_USER', 'postgres'),
    'PASSWORD': os.environ.get('DB_PASSWORD', ''),
    'HOST': os.environ.get('DB_HOST', 'status-page-prod-db.cx248m4we6k7.us-east-1.rds.amazonaws.com'),
    'PORT': os.environ.get('DB_PORT', '5432'),
    'ENGINE': 'django.db.backends.postgresql',
    'CONN_MAX_AGE': 600,  # Connection persistence for 10 minutes
    'OPTIONS': {
        'connect_timeout': DB_CONNECT_TIMEOUT,
        'keepalives': 1,
        'keepalives_idle': 130,
        'keepalives_interval': 10,
        'keepalives_count': 10,
    },
}

# Redis settings with more robust configuration
REDIS = {
    'caching': {
        'HOST': os.environ.get('REDIS_HOST', 'statuspage-redis'),
        'PORT': int(os.environ.get('REDIS_PORT', 6379)),
        'DATABASE': int(os.environ.get('REDIS_DATABASE', 0)),
        'SSL': False,
        'SOCKET_TIMEOUT': 5,
        'SOCKET_CONNECT_TIMEOUT': 5,
        'RETRY_ON_TIMEOUT': True,
    },
    'tasks': {
        'HOST': os.environ.get('REDIS_HOST', 'statuspage-redis'),
        'PORT': int(os.environ.get('REDIS_PORT', 6379)),
        'DATABASE': int(os.environ.get('REDIS_DATABASE', 0)),
        'SSL': False,
        'SOCKET_TIMEOUT': 5,
        'SOCKET_CONNECT_TIMEOUT': 5,
        'RETRY_ON_TIMEOUT': True,
    }
}

# Disable RQ Scheduler to prevent issues
RQ_SHOW_ADMIN_LINK = False
INSTALLED_APPS_DISABLE = ['django_rq.queuing']

# Secret key for Django
SECRET_KEY = os.environ.get('SECRET_KEY', 'django-insecure-key-for-development-only')

# Site URL (used for links in emails, etc.)
SITE_URL = os.environ.get('SITE_URL', 'https://status.elad-avior.com')

# Debug mode (should be False in production)
DEBUG = os.environ.get('DEBUG', 'False').lower() == 'true'

# Time zone
TIME_ZONE = 'UTC'

# Email settings
EMAIL_HOST = os.environ.get('EMAIL_HOST', 'localhost')
EMAIL_PORT = int(os.environ.get('EMAIL_PORT', 25))
EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER', '')
EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD', '')
EMAIL_USE_TLS = os.environ.get('EMAIL_USE_TLS', 'False').lower() == 'true'
EMAIL_USE_SSL = os.environ.get('EMAIL_USE_SSL', 'False').lower() == 'true'
EMAIL_TIMEOUT = int(os.environ.get('EMAIL_TIMEOUT', 10))
SERVER_EMAIL = os.environ.get('SERVER_EMAIL', 'statuspage@example.com')
EMAIL_SUBJECT_PREFIX = '[Status Page] '

# Plugins
PLUGINS = []

# Default admin user
ADMINS = [
    ('Admin', 'admin@example.com'),
]

# Configure status components
STATUS_COMPONENTS = [
    {
        'name': 'Web Application',
        'description': 'Main web interface',
        'group': 'User Services',
    },
    {
        'name': 'API Services',
        'description': 'API Services',
        'group': 'User Services',
    },
    {
        'name': 'Database',
        'description': 'PostgreSQL Database',
        'group': 'Infrastructure',
    },
    {
        'name': 'Redis',
        'description': 'Redis Cache and Message Broker',
        'group': 'Infrastructure',
    },
    {
        'name': 'EKS Cluster',
        'description': 'Kubernetes Container Platform',
        'group': 'Infrastructure',
    }
]

# Logging configuration with more detailed errors
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '%(asctime)s [%(levelname)s] [%(process)d] %(name)s: %(message)s'
        },
    },
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
        },
        'django.db.backends': {
            'handlers': ['console'],
            'level': 'WARNING',
            'propagate': False,
        },
        'statuspage': {
            'handlers': ['console'],
            'level': 'DEBUG',
        },
    },
}
