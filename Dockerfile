############################################
# 🏗️ STAGE 1 — Build Stage
############################################
FROM python:3.11-slim AS builder

# Set working directory inside the container
WORKDIR /app

# Prevent Python from writing .pyc files & enable direct log output
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Copy only requirements first (for caching)
COPY requirements.txt .

# Upgrade pip and install dependencies
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Optional cleanup (remove caches or compiled files)
RUN find /app -name "__pycache__" -type d -exec rm -rf {} + \
    && find /app -name "*.pyc" -delete

############################################
# 🚀 STAGE 2 — Runtime Stage
############################################
FROM python:3.11-alpine AS runtime

# Set working directory
WORKDIR /app

# Set environment variables again
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Copy only installed Python packages from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages/ /usr/local/lib/python3.11/site-packages/

# Copy only application code, respecting .dockerignore
COPY . /app

# Expose the port Django will run on
EXPOSE 8000

# Final command to run Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

