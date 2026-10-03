#!/bin/bash

# 1. Missing package install karo
pip install standard-imghdr

# 2. Folders banao
mkdir -p ggn/assets

# 3. Files ko sahi jagah copy karo
cp -f __init__.py importer.py ggn/
cp -f batch.py frontend.py functions.py generate.py login.py progress.py pyroplug.py speedtest.py start.py stats.py ggn/assets/
touch ggn/assets/__init__.py

# 4. bot aur imports theek karo
sed -i 's/#bot = TelegramClient/bot = TelegramClient/g' ggn/__init__.py
sed -i 's/import bot/from . import bot/g' __main__.py

# 5. pkgutil aur imghdr ko theek karne wala patch
cat << 'EOF' > fix.py
import importlib.util, pkgutil, sys
if not hasattr(pkgutil, 'get_loader'):
    pkgutil.get_loader = lambda name: importlib.util.find_spec(name).loader if importlib.util.find_spec(name) else None
try:
    import imghdr
except ImportError:
    try:
        import standard_imghdr as imghdr
        sys.modules['imghdr'] = imghdr
    except Exception:
        pass
EOF

# Patch ko main file ke sabse upar jod do
cat fix.py __main__.py > ggn/__main__.py

# 6. Render ko 24/7 zinda rakhne ke liye web server chalao
python3 app.py &

# 7. Telegram bot start karo
python3 -m ggn

