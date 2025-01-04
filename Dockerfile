# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy requirements.txt to the container
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy all Python scripts into the container
COPY python-scripts/ ./python-scripts/

# Set the default command to run the pod health check script
CMD ["python3", "./python-scripts/pod_health_check_and_restart.py"]