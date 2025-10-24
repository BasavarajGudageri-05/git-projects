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

# Upgrade pip and install dependencies for the build
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --user --no-cache-dir -r requirements.txt

# Now copy the full Django project into /app
COPY . .

# Optional cleanup (remove cache, compiled files)
RUN find /app -name "__pycache__" -type d -exec rm -rf {} + \
    && find /app -name "*.pyc" -delete

############################################
# 🚀 STAGE 2 — Runtime Stage
############################################
FROM python:3.11-slim AS runtime

# Set working directory
WORKDIR /app

# Set environment variables again (apply in this stage too)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Copy only installed Python packages from builder
COPY --from=builder /root/.local /root/.local

# Copy only the Django app code (not caches or venvs)
COPY --from=builder /app /app

# Add installed Python binaries to PATH
ENV PATH=/root/.local/bin:$PATH

# Expose the port Django will run on
EXPOSE 8000

# Final command to run Django development server
ENTRYPOINT ["python", "manage.py"]
CMD ["runserver", "0.0.0.0:8000"]

