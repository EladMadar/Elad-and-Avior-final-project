FROM python:3.11-slim-bullseye

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .

# Add monitoring packages
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir prometheus-client django-prometheus psutil

# Copy project files
COPY . .

# Create media and static directories
RUN mkdir -p /app/statuspage/media /app/statuspage/static

# Generate secret key
RUN python statuspage/generate_secret_key.py > /app/statuspage/secretkey.py

# Create necessary directories and override environment variables for build
ENV STATUS_PAGE_CONFIGURATION=statuspage.configuration
ENV DJANGO_SETTINGS_MODULE=statuspage.settings

# Collect static files
RUN mkdir -p /app/statuspage/static /app/statuspage/media && \
    cd statuspage && python manage.py collectstatic --noinput || echo "Static collection failed, continuing build"

# Expose ports
EXPOSE 8000
EXPOSE 9090

# Add monitoring configuration
ENV ENABLE_METRICS=1
ENV METRICS_RETENTION_DAYS=14
ENV MONITOR_CPU=1
ENV MONITOR_MEMORY=1
ENV MONITOR_LOAD=1
ENV MONITOR_DATABASE_RESPONSE=1
ENV MONITOR_DATABASE_USAGE=1
ENV MONITOR_UPTIME=1

# Start Gunicorn with worker metrics
CMD ["gunicorn", "--chdir", "statuspage", "--bind", "0.0.0.0:8000", \
     "--workers", "4", "--threads", "2", \
     "--worker-class", "gthread", \
     "--statsd-host=localhost:9125", \
     "--logger-class=gunicorn.glogging.Logger", \
     "statuspage.wsgi:application"]
