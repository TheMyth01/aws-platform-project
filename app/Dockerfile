# Stage 1: small, official Python base image
FROM python:3.12-slim

# Run as non-root for security
RUN useradd --create-home --shell /bin/bash appuser
WORKDIR /home/appuser

# Install dependencies first (Docker layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app source
COPY src/ ./src/

# Drop privileges
USER appuser

# Listen on 8080 (documentation only; EXPOSE doesn't actually publish)
EXPOSE 8080

# Basic healthcheck (Docker will probe this, also useful for orchestrators)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health').read()" || exit 1

# Run the app
CMD ["python", "src/app.py"]
