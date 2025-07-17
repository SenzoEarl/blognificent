# Use the official Python runtime image
FROM python:3.13

LABEL maintainer="Senzo Maseko <senzo.e.maseko@gmail.com>" \
      version="2.0.0" \
      description="Blognificent - A Django blog application container" \
      org.opencontainers.image.title="Django Blog App" \
      org.opencontainers.image.description="Containerized Django blog app using Python, Tailwind & DaisyUI" \
      org.opencontainers.image.authors="Senzo Maseko <senzo.emaseko@gmail.com>" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.url="https://example.com" \
      org.opencontainers.image.source="https://github.com/SenzoEarl/blognificent"
# Set environment variables
# Prevents Python from writing pyc files to disk
ENV PYTHONDONTWRITEBYTECODE=1
#Prevents Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED=1

# Set the working directory inside the container
WORKDIR /app

# Upgrade pip
RUN pip install --upgrade pip

# Copy the Django project  and install dependencies
COPY requirements.txt  ./requirements.txt

# run this command to install all dependencies
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the Django project to the container
COPY . .

# Expose the Django port
EXPOSE 8000

# Run Django’s development server
CMD ["gunicorn", "blognificent.wsgi:application", "--bind", "0.0.0.0:8000"]