FROM python:3.12-slim
LABEL org.opencontainers.image.source="https://github.com/mamungtg/devsecops-pipeline-demo"
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 10001 appuser
WORKDIR /app
COPY app/requirements.txt .
# Install runtime deps, then strip packaging tooling from the final image
RUN pip install --no-cache-dir -r requirements.txt \
    && pip uninstall -y setuptools wheel urllib3 pip \
    && rm -rf /usr/local/lib/python3.12/ensurepip /root/.cache
COPY app/ .
USER appuser
EXPOSE 8000
CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]
