# Use Debian Bookworm to pick up newer patched libraries
FROM python:3.9-slim-bookworm

# 1) Patch vulnerable OS packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libc-bin \
      perl-base \
      zlib1g \
      libsystemd0 \
      libudev1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2) Set working dir & install Python deps
WORKDIR /app
COPY requirements.txt .

# Upgrade pip and ensure setuptools is latest
RUN pip install --upgrade pip setuptools && \
    pip install --no-cache-dir -r requirements.txt

# 3) Copy in your code, collect static assets
COPY . /app/
WORKDIR /app/databytes
RUN python manage.py collectstatic --noinput

# 4) At runtime, run your web server…
CMD ["gunicorn", "databytes.wsgi:application", "--bind", "0.0.0.0:8000"]
