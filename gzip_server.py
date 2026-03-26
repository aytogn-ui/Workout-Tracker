#!/usr/bin/env python3
"""
gzip圧縮対応 + CORSヘッダー付き Flutter Web サーバー
canvaskit.wasm など全ファイルをgzip配信
"""
import http.server, socketserver, os, mimetypes, sys

GZIP_EXTS = {'.js', '.css', '.html', '.json', '.svg', '.wasm', '.dart'}

CACHE = {
    '.wasm': 'max-age=86400',
    '.js':   'max-age=86400',
    '.css':  'max-age=86400',
    '.png':  'max-age=86400',
    '.html': 'no-cache, no-store, must-revalidate',
    '.json': 'no-cache',
}

MIME = {
    '.wasm': 'application/wasm',
    '.js':   'application/javascript',
    '.mjs':  'application/javascript',
}

class Handler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('X-Frame-Options', 'ALLOWALL')
        self.send_header('Content-Security-Policy', 'frame-ancestors *')
        super().end_headers()

    def do_GET(self):
        path = self.translate_path(self.path)
        if os.path.isdir(path):
            path = os.path.join(path, 'index.html')

        ext = os.path.splitext(path)[1].lower()
        accept = self.headers.get('Accept-Encoding', '')
        gz = path + '.gz'
        can_gz = 'gzip' in accept and ext in GZIP_EXTS and os.path.isfile(gz)

        serve = gz if can_gz else path
        if not os.path.isfile(serve):
            # SPA fallback
            idx = os.path.join(os.path.dirname(path), 'index.html')
            serve = idx if os.path.isfile(idx) else None
            ext = '.html'
            can_gz = False

        if not serve:
            self.send_error(404); return

        mime = MIME.get(ext) or mimetypes.types_map.get(ext, 'application/octet-stream')
        size = os.path.getsize(serve)
        cache = CACHE.get(ext, 'max-age=3600')

        self.send_response(200)
        self.send_header('Content-Type', mime)
        self.send_header('Content-Length', str(size))
        self.send_header('Cache-Control', cache)
        if can_gz:
            self.send_header('Content-Encoding', 'gzip')
            self.send_header('Vary', 'Accept-Encoding')
        self.end_headers()

        with open(serve, 'rb') as f:
            self.wfile.write(f.read())

    def log_message(self, *a): pass

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 5060
    web_dir = sys.argv[2] if len(sys.argv) > 2 else 'build/web'
    os.chdir(web_dir)
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(('0.0.0.0', port), Handler) as s:
        print(f'gzip server :{port} -> {web_dir}')
        s.serve_forever()
