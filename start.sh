#!/bin/bash

# --- НАСТРОЙКИ ---
GITHUB_RAW_URL_OTA="https://raw.githubusercontent.com/mansur54321/termux_ota/refs/heads/main/ota.sh" 
GITHUB_RAW_URL_B="https://raw.githubusercontent.com/mansur54321/termux_ota/refs/heads/main/b.sh" 
# -----------------


LOG="$HOME/termux_setup.log"
exec > >(tee -a "$LOG") 2>&1

echo -e "\n=== [ $(date) ] Starting automated Termux setup ==="

# Проверка зависимостей
function check_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "⚠️ '$1' not found. Installing..."
    pkg install -y "$1" || { echo "❌ Failed to install $1. Aborting."; exit 1; }
  else
    echo "✅ '$1' is already installed."
  fi
}

check_command curl
check_command termux-api
check_command nano

# 0. Разрешаем доступ к хранилищу
echo -e "\n📂 Requesting storage permissions..."
termux-setup-storage
sleep 2

# 1. Создание папки OTA
OTA_DIR="/sdcard/OTA"
echo -e "\n📁 Creating OTA folder: $OTA_DIR"
mkdir -p "$OTA_DIR" || { echo "❌ Failed to create $OTA_DIR"; exit 1; }

# 2. Скачивание ota.sh
echo -e "\n📥 Downloading ota.sh..."
curl -fsSL "$GITHUB_RAW_URL_OTA" -o "$OTA_DIR/ota.sh" || { echo "❌ Failed to download ota.sh"; exit 1; }

# 3. Скачивание b.sh
echo -e "\n📥 Downloading b.sh..."
curl -fsSL "$GITHUB_RAW_URL_B" -o "$OTA_DIR/b.sh" || { echo "❌ Failed to download b.sh"; exit 1; }

# 4. Делаем исполняемыми
chmod +x "$OTA_DIR/"*.sh
echo "✅ Scripts are executable."

# 5. Выполнение ota.sh с предопределёнными ответами
echo -e "\n🚀 Running ota.sh..."
bash "$OTA_DIR/ota.sh" <<EOF
\n
\n
y
n
n
y
y
y
EOF

# 6. Создание папки .shortcuts
SHORTCUTS_DIR="$HOME/.shortcuts"
echo -e "\n📁 Creating .shortcuts directory..."
mkdir -p "$SHORTCUTS_DIR"
chmod 700 -R "$SHORTCUTS_DIR"

# 7. Копируем b.sh в шорткат
SHORTCUT_SCRIPT="$SHORTCUTS_DIR/OnePlus_OTA"
cp "$OTA_DIR/b.sh" "$SHORTCUT_SCRIPT"
chmod +x "$SHORTCUT_SCRIPT"
echo "✅ Shortcut script created: $SHORTCUT_SCRIPT"

# 8. Финальные шаги
echo -e "\n🎉 Setup completed successfully!"
echo "📌 You can now add the Termux Widget to your home screen and launch 'OnePlus_OTA'."
echo "📝 Full log saved to: $LOG"
