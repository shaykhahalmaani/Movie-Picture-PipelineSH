FROM python:3.10-slim

WORKDIR /app

# Install pipenv
RUN pip install pipenv

# Copy Pipfile files
COPY Pipfile Pipfile.lock* ./

# Install dependencies
RUN pipenv install --deploy --system

# Copy application code
COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
