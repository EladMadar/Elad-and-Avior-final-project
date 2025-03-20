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
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Create media and static directories
RUN mkdir -p /app/statuspage/media /app/statuspage/static

# Generate secret key
RUN python statuspage/generate_secret_key.py > /app/statuspage/secretkey.py

# Collect static files
RUN cd statuspage && python manage.py collectstatic --noinput

# Expose port
EXPOSE 8000

# Start Gunicorn
CMD ["gunicorn", "--chdir", "statuspage", "--bind", "0.0.0.0:8000", "statuspage.wsgi:application"]
