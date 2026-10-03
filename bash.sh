#!/bin/bash

# 1. Packages install karo
pip install standard-imghdr "werkzeug>=3.0.0"

# 2. LOG_GROUP agar set nahi hai to default apna Admin ID daalo
export LOG_GROUP="${LOG_GROUP:-8601489033}"
sed -i 's/getenv("LOG_GROUP", "")/getenv("LOG_GROUP") or "8601489033"/g' config.py 2>/dev/null || true

# 3. Python 3.14 safe patch
cat << 'EOF' > sitecustomize.py
import sys, pkgutil, importlib.util
def _safe_loader(name):
    try:
        spec = importlib.util.find_spec(name)
        return getattr(spec, 'loader', None) if spec else None
    except Exception:
        return None
pkgutil.get_loader = _safe_loader
try:
    import standard_imghdr as imghdr
    sys.modules['imghdr'] = imghdr
except Exception:
    pass
EOF

python3 -c "import site, shutil, os; [shutil.copy('sitecustomize.py', os.path.join(p, 'sitecustomize.py')) for p in site.getsitepackages() if os.path.exists(p)]" 2>/dev/null || true

# 4. Folders banao aur files copy karo
mkdir -p ggn/assets
cp -f importer.py sitecustomize.py ggn/
cp -f batch.py frontend.py functions.py generate.py login.py progress.py pyroplug.py speedtest.py start.py stats.py ggn/assets/
touch ggn/assets/__init__.py

# 5. __init__.py me bot on karo
sed -i 's/#bot = TelegramClient/bot = TelegramClient/g' __init__.py
cp -f __init__.py ggn/

# 6. __main__.py ko theek karo
sed -i 's/import bot/from . import bot/g' __main__.py
cp -f __main__.py ggn/

# 7. Render ke liye fail-safe web server (zero crash)
cat << 'EOF' > run_server.py
import os, http.server, socketserver
port = int(os.environ.get('PORT', 8080))
class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Bot is Running Live!")
socketserver.TCPServer(("", port), Handler).serve_forever()
EOF
python3 run_server.py &

# 8. Telegram bot start karo
python3 -m ggn




