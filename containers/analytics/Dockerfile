# Base image for production
FROM python:3.9-slim-buster as production

# Set environment variables
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_ENV=production

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Install production dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Flask application code
COPY . .

# Expose the Flask application port
EXPOSE 5000

VOLUME [ "/app" ]

ENTRYPOINT ["/entrypoint.sh"]
# Run the Flask application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]

# Base image for development
FROM python:3.9 as development

# Set environment variables
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_ENV=development

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Install development dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Flask application code
COPY . .

# Expose the Flask application port
EXPOSE 5000

VOLUME [ "/app" ]

ENTRYPOINT ["/entrypoint.sh"]
# Run the Flask application with automatic reloading
CMD ["flask", "run", "--reload"]
