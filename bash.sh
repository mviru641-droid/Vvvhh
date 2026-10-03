#!/bin/bash

# 1. Missing package install karo
pip install standard-imghdr

# 2. Folders banao
mkdir -p ggn/assets

# 3. Files ko sahi jagah copy karo
cp -f importer.py ggn/
cp -f batch.py frontend.py functions.py generate.py login.py progress.py pyroplug.py speedtest.py start.py stats.py ggn/assets/
touch ggn/assets/__init__.py

# 4. pkgutil aur imghdr ko theek karne wala patch banao
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

# 5. __init__.py me bot on karo aur sabse upar patch lagao
sed -i 's/#bot = TelegramClient/bot = TelegramClient/g' __init__.py
cat fix.py __init__.py > ggn/__init__.py

# 6. __main__.py ko theek karke patch lagao
sed -i 's/import bot/from . import bot/g' __main__.py
cat fix.py __main__.py > ggn/__main__.py

# 7. Render web server chalao
python3 app.py &

# 8. Telegram bot start karo
python3 -m ggn


