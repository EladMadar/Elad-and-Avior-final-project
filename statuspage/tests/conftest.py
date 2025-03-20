import pytest
from django.conf import settings

@pytest.fixture(scope='session')
def django_db_setup():
    settings.DATABASES['default'] = {
        'ENGINE': 'django.db.backends.postgresql',
        'HOST': 'test-db',
        'NAME': 'statuspage_test',
        'USER': 'statuspage',
        'PASSWORD': 'statuspage',
    }

@pytest.fixture
def api_client():
    from rest_framework.test import APIClient
    return APIClient()

@pytest.fixture
def authenticated_client(api_client):
    from django.contrib.auth import get_user_model
    User = get_user_model()
    user = User.objects.create_superuser(
        username='testadmin',
        email='admin@test.com',
        password='testpass123'
    )
    api_client.force_authenticate(user=user)
    return api_client
