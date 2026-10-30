
# Use Python base image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Expose Flask application port
EXPOSE 5000

# Run application using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
