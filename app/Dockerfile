FROM python:3.12-alpine

WORKDIR /app
COPY app.py .

RUN adduser -D -u 10001 appuser
USER 10001

ENV PORT=8080
EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD python -c "import urllib.request;urllib.request.urlopen('http://127.0.0.1:8080/healthz')"

CMD ["python", "app.py"]
