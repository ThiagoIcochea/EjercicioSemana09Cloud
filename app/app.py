"""Servicio mínimo que corre en cada VM, contenedor y pod.

Responde con la identidad del nodo para comprobar que el orquestador
desplegó la réplica correcta en cada nube. Solo usa la biblioteca estándar.
"""
import json
import os
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT = int(os.environ.get("PORT", "8080"))


def identity():
    return {
        "service": "semana09-app",
        "cloud": os.environ.get("CLOUD_PROVIDER", "unknown"),
        "vm_name": os.environ.get("VM_NAME", socket.gethostname()),
        "role": os.environ.get("VM_ROLE", "generic"),
        "hostname": socket.gethostname(),
    }


class Handler(BaseHTTPRequestHandler):
    def _send(self, status, body):
        payload = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self):
        if self.path in ("/healthz", "/readyz"):
            self._send(200, {"status": "ok"})
        elif self.path == "/":
            self._send(200, identity())
        else:
            self._send(404, {"error": "not found"})

    def log_message(self, fmt, *args):
        print(f"{self.address_string()} {fmt % args}", flush=True)


if __name__ == "__main__":
    print(f"Escuchando en :{PORT} -> {identity()}", flush=True)
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
