# Use a slim Python image
FROM python:3.9-slim

# Don’t buffer stdout/stderr and skip writing .pyc files
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Set the working directory
WORKDIR /app

# Install system dependencies (if you need any – e.g. libpq-dev for Postgres)
# RUN apt-get update && apt-get install -y --no-install-recommends gcc

# Copy and install Python dependencies
COPY requirements.txt /app/
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy in the rest of the code
COPY . /app/

# Switch into the Django project dir
WORKDIR /app/databytes

# Collect static files
RUN python manage.py collectstatic --noinput

# Expose the port your app will run on
EXPOSE 8000

# Run with Gunicorn
CMD ["gunicorn", "databytes.wsgi:application", "--bind", "0.0.0.0:8000"]
