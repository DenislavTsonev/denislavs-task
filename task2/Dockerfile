FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copy Python script to container
COPY get_serial_data.py .

# Define entrypoint
ENTRYPOINT ["python", "get_serial_data.py"]
