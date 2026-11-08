#!/usr/bin/env python3
"""
Mail Webhook Receiver for Lunar
Receives raw RFC 822 email payloads from Cloudflare Email Worker over HTTPS (via Cloudflare Tunnel)
and injects them into Stalwart Mail Server via local SMTP.
"""
import http.server
import os
import smtplib
import sys

WEBHOOK_SECRET = os.environ.get("WEBHOOK_SECRET", "lunar-mail-secret-2026")
SMTP_HOST = os.environ.get("SMTP_HOST", "stalwart")
SMTP_PORT = int(os.environ.get("SMTP_PORT", "25"))

class MailWebhookHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        auth_header = self.headers.get("X-Webhook-Secret")
        if auth_header != WEBHOOK_SECRET:
            self.send_response(401)
            self.end_headers()
            self.wfile.write(b"Unauthorized\n")
            return

        content_length = int(self.headers.get("Content-Length", 0))
        raw_email = self.rfile.read(content_length)

        mail_to = self.headers.get("X-Mail-To", "hi@muvex.dev")
        mail_from = self.headers.get("X-Mail-From", "")

        try:
            with smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=15) as client:
                client.sendmail(mail_from, [mail_to], raw_email)
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"Delivered\n")
        except Exception as e:
            sys.stderr.write(f"Error forwarding email to SMTP: {e}\n")
            self.send_response(500)
            self.end_headers()
            self.wfile.write(f"Error: {e}\n".encode())

    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Mail receiver active\n")

    def log_message(self, format, *args):
        sys.stdout.write(f"[mail-receiver] {self.address_string()} - {format % args}\n")
        sys.stdout.flush()

if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8089"))
    server = http.server.HTTPServer(("0.0.0.0", port), MailWebhookHandler)
    print(f"[mail-receiver] Listening on 0.0.0.0:{port} -> SMTP destination {SMTP_HOST}:{SMTP_PORT}")
    sys.stdout.flush()
    server.serve_forever()
