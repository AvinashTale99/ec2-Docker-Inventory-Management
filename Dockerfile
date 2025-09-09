FROM python:3.10

WORKDIR /app

# Copy requirements.txt into image
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY app/ /app/

EXPOSE 5000

CMD ["python", "main.py"]
