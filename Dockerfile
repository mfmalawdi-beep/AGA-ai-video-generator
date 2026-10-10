# Dockerfile for the FastAPI backend of the AI YouTube Shorts Generator.
# Deployable on Render / Railway / Fly.io / any Docker host.
#
# Includes ffmpeg (required for --mode local video processing) and all
# Python dependencies for both API mode and local mode.

FROM python:3.11-slim

# System dependencies:
#   ffmpeg        - video download/cut/crop for --mode local
#   libgl1, libglib2.0-0 - required by opencv-python on slim images
RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies first (better layer caching).
# requirements-local.txt already includes requirements.txt.
COPY requirements.txt requirements-local.txt ./
RUN pip install --no-cache-dir -r requirements-local.txt

# Copy the application (server/, shorts_generator/, main.py)
COPY . .

# Directory where rendered clips are written and served at /output
RUN mkdir -p output

# Render/Railway/Fly inject PORT; default to 8000 for local docker runs
ENV PORT=8000
EXPOSE 8000

# Run from the repo root so server/main.py can invoke main.py as a subprocess
CMD ["sh", "-c", "uvicorn server.main:app --host 0.0.0.0 --port ${PORT}"]
