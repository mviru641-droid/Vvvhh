#!/bin/bash

# 1. Missing package aur Werkzeug ko naye Python ke liye upgrade karo
pip install standard-imghdr "werkzeug>=3.0.0"

# 2. Global patch banao jo Flask aur Bot dono ko ek sath theek kare
cat << 'EOF' > sitecustomize.py
import sys, pkgutil, importlib.util
if not hasattr(pkgutil, 'get_loader'):
    pkgutil.get_loader = lambda name: getattr(importlib.util.find_spec(name), 'loader', None) if importlib.util.find_spec(name) else None
try:
    import imghdr
except ImportError:
    try:
        import standard_imghdr as imghdr
        sys.modules['imghdr'] = imghdr
    except Exception:
        pass
EOF

# System ke andar patch daalo taaki har file me khud-b-khud theek ho jaye
python3 -c "import site, shutil, os; [shutil.copy('sitecustomize.py', os.path.join(p, 'sitecustomize.py')) for p in site.getsitepackages() if os.path.exists(p)]" 2>/dev/null || true

# 3. Folders banao
mkdir -p ggn/assets

# 4. Files ko sahi jagah copy karo
cp -f importer.py sitecustomize.py ggn/
cp -f batch.py frontend.py functions.py generate.py login.py progress.py pyroplug.py speedtest.py start.py stats.py ggn/assets/
touch ggn/assets/__init__.py

# 5. __init__.py me bot on karo
sed -i 's/#bot = TelegramClient/bot = TelegramClient/g' __init__.py
cp -f __init__.py ggn/

# 6. __main__.py ko theek karo
sed -i 's/import bot/from . import bot/g' __main__.py
cp -f __main__.py ggn/

# 7. Render web server chalao
python3 app.py &

# 8. Telegram bot start karo
python3 -m ggn



