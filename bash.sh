#!/bin/bash
# 0. Python 3.13 ke liye missing tools install karo
pip install standard-imghdr

# 1. Folders banao
mkdir -p ggn/assets

# 2. Files ko sahi jagah copy karo
cp -f __init__.py importer.py ggn/
cp -f batch.py frontend.py functions.py generate.py login.py progress.py pyroplug.py speedtest.py start.py stats.py ggn/assets/
touch ggn/assets/__init__.py

# 3. bot aur import theek karo
sed -i 's/#bot = TelegramClient/bot = TelegramClient/g' ggn/__init__.py
sed -i 's/import bot/from . import bot/g' __main__.py
cp -f __main__.py ggn/

# 4. Render ke liye web server background me chalao
python3 app.py &

# 5. Telegram bot start karo
python3 -m ggn
