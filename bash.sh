#!/bin/bash
export PYTHONUNBUFFERED=1

# 1. Zaruri packages install karo
pip install standard-imghdr "werkzeug>=3.0.0"

# 2. Config.py ko crash-proof banane wala safe script
cat << 'EOF' > fix_config.py
import re, os

if os.path.exists('config.py'):
    with open('config.py', 'r') as f:
        code = f.read()
    
    # Missing os import add karo
    if 'import os' not in code:
        code = 'import os\n' + code
        
    # Khali int() variables ko crash hone se bachao
    code = re.sub(r'int\(getenv\(["\']LOG_GROUP["\'][^)]*\)\)', 'int(os.getenv("LOG_GROUP") or "8601489033")', code)
    code = re.sub(r'int\(getenv\(["\']CHANNEL_ID["\'][^)]*\)\)', 'int(os.getenv("CHANNEL_ID") or "0")', code)
    code = re.sub(r'int\(getenv\(["\']FREEMIUM_LIMIT["\'][^)]*\)\)', 'int(os.getenv("FREEMIUM_LIMIT") or "0")', code)
    code = re.sub(r'int\(getenv\(["\']PREMIUM_LIMIT["\'][^)]*\)\)', 'int(os.getenv("PREMIUM_LIMIT") or "500")', code)

    with open('config.py', 'w') as f:
        f.write(code)
    print("Config.py successfully patched!")
EOF
python3 fix_config.py

# 3. Python 3.14 ka pkgutil aur imghdr global patch
cat << 'EOF' > sitecustomize.py
import sys, pkgutil, importlib.util

def safe_loader(name):
    try:
        spec = importlib.util.find_spec(name)
        return getattr(spec, 'loader', None) if spec else None
    except Exception:
        return None

if not hasattr(pkgutil, 'get_loader'):
    pkgutil.get_loader = safe_loader

try:
    import imghdr
except ImportError:
    try:
        import standard_imghdr as imghdr
        sys.modules['imghdr'] = imghdr
    except Exception:
        pass
EOF

python3 -c "import site, shutil, os; [shutil.copy('sitecustomize.py', os.path.join(p, 'sitecustomize.py')) for p in site.getsitepackages() if os.path.exists(p)]" 2>/dev/null || true

# 4. Folders banao aur files copy karo
mkdir -p ggn/assets
cp -f importer.py sitecustomize.py config.py ggn/
cp -f batch.py frontend.py functions.py generate.py login.py progress.py pyroplug.py speedtest.py start.py stats.py ggn/assets/
touch ggn/assets/__init__.py

# 5. __init__.py me bot on karo
sed -i 's/#bot = TelegramClient/bot = TelegramClient/g' __init__.py
cp -f __init__.py ggn/

# 6. __main__.py ko theek karo
sed -i 's/import bot/from . import bot/g' __main__.py
cp -f __main__.py ggn/

# 7. Render ke liye 24/7 web server
cat << 'EOF' > run_server.py
import os
from http.server import HTTPServer, BaseHTTPRequestHandler

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(b"Bot is Running Live 24/7!")
    def log_message(self, format, *args):
        pass

port = int(os.environ.get("PORT", 8080))
httpd = HTTPServer(('0.0.0.0', port), Handler)
print(f"Render Web Server live on port {port}")
httpd.serve_forever()
EOF

python3 run_server.py &

# 8. Telegram Bot start karo
echo "Starting Telegram Bot..."
until python3 -u -m ggn; do
  echo "Bot band hua, 10 minute baad dobara try..."
  sleep 600
done







