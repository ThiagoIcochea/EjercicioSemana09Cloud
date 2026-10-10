import json
import threading
import unittest
import urllib.request
from http.server import ThreadingHTTPServer

import app


class AppTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), app.Handler)
        cls.base = f"http://127.0.0.1:{cls.server.server_port}"
        threading.Thread(target=cls.server.serve_forever, daemon=True).start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()

    def get(self, path):
        with urllib.request.urlopen(self.base + path) as r:
            return r.status, json.loads(r.read())

    def test_healthz(self):
        self.assertEqual(self.get("/healthz"), (200, {"status": "ok"}))

    def test_identity(self):
        status, body = self.get("/")
        self.assertEqual(status, 200)
        self.assertEqual(body["service"], "semana09-app")
        self.assertIn("role", body)
        self.assertEqual(body["author"], "Thiago Paolo Icochea Rodriguez")

    def test_not_found(self):
        with self.assertRaises(urllib.error.HTTPError) as ctx:
            self.get("/nada")
        self.assertEqual(ctx.exception.code, 404)


if __name__ == "__main__":
    unittest.main()
