FROM python:3.10-slim AS builder

WORKDIR /app
COPY backend/requirements.txt ./
ENV PIP_DEFAULT_TIMEOUT=1200
RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --retries 10 --timeout 1200 --user \
      --index-url https://download.pytorch.org/whl/cpu \
      torch==2.5.1+cpu && \
    pip install --no-cache-dir --retries 10 --timeout 1200 --user \
      --extra-index-url https://download.pytorch.org/whl/cpu \
      -r requirements.txt

FROM python:3.10-slim

WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY backend/ ./

ENV PATH=/root/.local/bin:$PATH

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"]
