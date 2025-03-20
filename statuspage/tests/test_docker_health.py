import os
import pytest
import requests
from time import sleep
from django.core.management import call_command
from django.db import connections
from redis import Redis

def test_database_connection():
    """Test that we can connect to the database"""
    try:
        connections['default'].cursor()
    except Exception as e:
        pytest.fail(f"Database connection failed: {e}")

def test_redis_connection():
    """Test that we can connect to Redis"""
    redis_url = os.environ.get('REDIS_URL', 'redis://test-redis:6379/0')
    try:
        redis = Redis.from_url(redis_url)
        redis.ping()
    except Exception as e:
        pytest.fail(f"Redis connection failed: {e}")

def test_static_files():
    """Test that static files are collected correctly"""
    try:
        call_command('collectstatic', '--noinput')
    except Exception as e:
        pytest.fail(f"Static files collection failed: {e}")

@pytest.mark.django_db
def test_migrations():
    """Test that all migrations can be applied"""
    try:
        call_command('migrate', '--noinput')
    except Exception as e:
        pytest.fail(f"Migrations failed: {e}")

def test_gunicorn_config():
    """Test that Gunicorn configuration is valid"""
    import gunicorn.config
    try:
        gunicorn.config.Config()
    except Exception as e:
        pytest.fail(f"Gunicorn configuration is invalid: {e}")
