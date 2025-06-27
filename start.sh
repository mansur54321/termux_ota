#!/bin/bash

# --- НАСТРОЙКИ ---
# ЗАМЕНИТЕ ЭТИ URL-АДРЕСА НА СВОИ "СЫРЫЕ" ССЫЛКИ ИЗ GITHUB
GITHUB_RAW_URL_OTA="https://raw.githubusercontent.com/mansur54321/termux_ota/refs/heads/main/ota.sh" # Например: https://raw.githubusercontent.com/myuser/myrepo/main/ota.sh
GITHUB_RAW_URL_B="https://raw.githubusercontent.com/mansur54321/termux_ota/refs/heads/main/b.sh"   # Например: https://raw.githubusercontent.com/myuser/myrepo/main/b.sh
# -----------------

echo "Starting Termux setup automation..."

# 1. Создаем папку OTA во внутренней памяти устройства
echo "1. Creating OTA folder in internal storage..."
mkdir -p /sdcard/OTA || { echo "Error: Could not create /sdcard/OTA. Ensure storage permissions are granted."; exit 1; }
echo "Folder /sdcard/OTA created."

# 2. Скачиваем ota.sh и b.sh из GitHub в папку OTA.
echo "2. Downloading ota.sh from GitHub..."
wget -O /sdcard/OTA/ota.sh "$GITHUB_RAW_URL_OTA" || { echo "Error: Could not download ota.sh. Check the URL and network connection."; exit 1; }
echo "ota.sh downloaded."

echo "3. Downloading b.sh from GitHub..."
wget -O /sdcard/OTA/b.sh "$GITHUB_RAW_URL_B" || { echo "Error: Could not download b.sh. Check the URL and network connection."; exit 1; }
echo "b.sh downloaded."

# Делаем скрипты исполняемыми
chmod +x /sdcard/OTA/ota.sh
chmod +x /sdcard/OTA/b.sh
echo "Scripts are executable."

echo "Now, please open Termux on your Android device and proceed with the following steps manually:"
echo ""
echo "----------------------------------------------------"
echo "IN TERMUX, TYPE THE FOLLOWING COMMANDS:"
echo "cd /sdcard/OTA"
echo "bash ota.sh"
echo ""
echo "When 'bash ota.sh' runs, you will be prompted to answer 'Enter, Enter, Y, N, N, Y, Y, Y' manually."
echo "----------------------------------------------------"

read -p "Press Enter after you have run 'bash ota.sh' in Termux and answered the prompts..."

echo ""
echo "----------------------------------------------------"
echo "CONTINUE IN TERMUX WITH THE FOLLOWING COMMANDS:"
echo "mkdir -p /data/data/com.termux/files/home/.shortcuts"
echo "chmod 700 -R /data/data/com.termux/files/home/.shortcuts"
echo "nano ~/.shortcuts/OnePlus_OTA"
echo ""
echo "!!! IMPORTANT MANUAL STEP !!!"
echo "After 'nano ~/.shortcuts/OnePlus_OTA' opens the editor:"
echo "1. Open the 'b.sh' file (from /sdcard/OTA) on your device using a text editor."
echo "2. Copy ALL its content."
echo "3. Paste the content into the 'nano' editor window in Termux."
echo "4. Press 'Ctrl + O' then 'Enter' to save."
echo "5. Press 'Ctrl + X' to exit nano."
echo ""
echo "Then, in Termux, type:"
echo "exit"
echo "----------------------------------------------------"

read -p "Press Enter after you have completed the manual steps in Termux and exited it..."

echo ""
echo "----------------------------------------------------"
echo "FINAL MANUAL STEP:"
echo "Go to your Android home screen and add the Termux:Widget for quick launch."
echo "----------------------------------------------------"

echo "Setup complete (manual steps required)."
