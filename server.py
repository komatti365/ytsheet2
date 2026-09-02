#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ゆとシートⅡ ローカル開発用 CGI HTTP サーバー
"""
import http.server
import os
import subprocess
import sys
import urllib.parse

PERL_PATH = r"C:\Strawberry\perl\bin\perl.exe"
PORT = 8080

class YtsheetCGIHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        
        # ディレクトリへのアクセス時の index.cgi 補完
        local_path = self.translate_path(path)
        if os.path.isdir(local_path):
            index_cgi = os.path.join(local_path, "index.cgi")
            if os.path.isfile(index_cgi):
                if not path.endswith('/'):
                    self.send_response(301)
                    self.send_header("Location", path + "/" + (f"?{parsed.query}" if parsed.query else ""))
                    self.end_headers()
                    return
                path = path + "index.cgi"
                local_path = index_cgi

        if path.endswith(".cgi") and os.path.isfile(local_path):
            self.run_cgi(local_path, parsed.query, b"")
        else:
            super().do_GET()

    def do_POST(self):
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        local_path = self.translate_path(path)
        
        if os.path.isdir(local_path):
            index_cgi = os.path.join(local_path, "index.cgi")
            if os.path.isfile(index_cgi):
                path = path.rstrip('/') + "/index.cgi"
                local_path = index_cgi

        content_length = int(self.headers.get('Content-Length', 0))
        post_body = self.rfile.read(content_length)

        if path.endswith(".cgi") and os.path.isfile(local_path):
            self.run_cgi(local_path, parsed.query, post_body)
        else:
            self.send_error(405, "Method Not Allowed")

    def run_cgi(self, script_path, query_string, post_body):
        script_dir = os.path.dirname(os.path.abspath(script_path))
        script_file = os.path.basename(script_path)

        env = os.environ.copy()
        env['PATH'] = r"C:\Strawberry\c\bin;C:\Strawberry\perl\site\bin;C:\Strawberry\perl\bin;" + env.get('PATH', '')
        env['REQUEST_METHOD'] = self.command
        env['QUERY_STRING'] = query_string or ''
        env['CONTENT_LENGTH'] = str(len(post_body)) if post_body else ''
        env['CONTENT_TYPE'] = self.headers.get('Content-Type', '')
        env['SCRIPT_NAME'] = urllib.parse.urlparse(self.path).path
        env['SERVER_NAME'] = 'localhost'
        env['SERVER_PORT'] = str(PORT)
        env['SERVER_PROTOCOL'] = 'HTTP/1.1'
        env['GATEWAY_INTERFACE'] = 'CGI/1.1'
        env['HTTP_COOKIE'] = self.headers.get('Cookie', '')
        env['HTTP_USER_AGENT'] = self.headers.get('User-Agent', '')
        env['HTTP_ACCEPT'] = self.headers.get('Accept', '')
        env['HTTP_REFERER'] = self.headers.get('Referer', '')

        try:
            proc = subprocess.Popen(
                [PERL_PATH, script_file],
                cwd=script_dir,
                env=env,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            stdout_data, stderr_data = proc.communicate(input=post_body)
            
            if stderr_data:
                sys.stderr.write(stderr_data.decode('utf-8', errors='replace'))

            # ヘッダーとボディの分離
            header_end = stdout_data.find(b"\r\n\r\n")
            if header_end != -1:
                headers_raw = stdout_data[:header_end].decode('utf-8', errors='replace')
                body = stdout_data[header_end + 4:]
            else:
                header_end = stdout_data.find(b"\n\n")
                if header_end != -1:
                    headers_raw = stdout_data[:header_end].decode('utf-8', errors='replace')
                    body = stdout_data[header_end + 2:]
                else:
                    headers_raw = ""
                    body = stdout_data

            status_code = 200
            headers_list = []
            for line in headers_raw.splitlines():
                if not line.strip():
                    continue
                if ':' in line:
                    key, val = line.split(':', 1)
                    key = key.strip()
                    val = val.strip()
                    if key.lower() == 'status':
                        try:
                            status_code = int(val.split()[0])
                        except ValueError:
                            pass
                    elif key.lower() == 'location':
                        status_code = 302
                        headers_list.append((key, val))
                    else:
                        headers_list.append((key, val))

            self.send_response(status_code)
            for key, val in headers_list:
                self.send_header(key, val)
            self.end_headers()
            self.wfile.write(body)

        except Exception as e:
            self.send_error(500, f"CGI Execution Error: {str(e)}")

def main():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    server_address = ('', PORT)
    httpd = http.server.HTTPServer(server_address, YtsheetCGIHTTPRequestHandler)
    print(f"=== ゆとシートⅡ ローカルサーバー起動 ===")
    print(f"URL: http://localhost:{PORT}/")
    print(f"アフターアーカイブ: http://localhost:{PORT}/aa/")
    httpd.serve_forever()

if __name__ == '__main__':
    main()
