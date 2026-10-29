FROM python:3.12-slim
LABEL org.opencontainers.image.source="https://github.com/mamungtg/devsecops-pipeline-demo"
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir --upgrade pip "setuptools>=78.1.1" "urllib3>=2.8.0" \
    && useradd --create-home --uid 10001 appuser
WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ .
USER appuser
EXPOSE 8000
CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]
