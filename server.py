"""Serve Puppet Story Studio using only Python's standard library."""

from __future__ import annotations

import mimetypes
import os
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parent
HOST = os.environ.get("PUPPET_STUDIO_HOST", "0.0.0.0")
PORT = int(os.environ.get("PUPPET_STUDIO_PORT", "4174"))


class Handler(BaseHTTPRequestHandler):
    server_version = "PuppetStoryStudio/2.1"

    def respond(self, status: int, content_type: str, body: bytes) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        if self.command != "HEAD" and body:
            self.wfile.write(body)

    def do_GET(self) -> None:
        self.serve_file(urlsplit(self.path).path)

    def do_HEAD(self) -> None:
        self.serve_file(urlsplit(self.path).path)

    def serve_file(self, request_path: str) -> None:
        relative = unquote(request_path).lstrip("/") or "index.html"
        target = (ROOT / relative).resolve()
        if not target.is_relative_to(ROOT):
            self.respond(403, "text/plain; charset=utf-8", b"Forbidden")
            return
        if not target.is_file():
            self.respond(404, "text/plain; charset=utf-8", b"Not found")
            return
        content_type = mimetypes.guess_type(target.name)[0] or "application/octet-stream"
        if target.suffix.lower() in {".html", ".css", ".js", ".txt"}:
            content_type += "; charset=utf-8"
        self.respond(200, content_type, target.read_bytes())

    def log_message(self, fmt: str, *args: object) -> None:
        print(f"[{self.log_date_time_string()}] {fmt % args}")


if __name__ == "__main__":
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    print(f"Puppet Story Studio: http://127.0.0.1:{PORT}")
    addresses = socket.gethostbyname_ex(socket.gethostname())[2]
    for address in dict.fromkeys(ip for ip in addresses if not ip.startswith("127.")):
        print(f"Network access:     http://{address}:{PORT}")
    print("Speech uses the voices provided by each browser/device.")
    print("Keep this window open while using the app. Press Ctrl+C to stop.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping Puppet Story Studio…")
    finally:
        server.server_close()
