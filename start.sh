#!/bin/bash

# --- НАСТРОЙКИ ---
B_SH_URL="https://raw.githubusercontent.com/mansur54321/termux_ota/refs/heads/main/b.sh" 
# --- КОНЕЦ НАСТРОЕК ---

# Цвета для красивого вывода
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

# Целевая папка и путь к скрипту
OTA_DIR="/storage/emulated/0/OTA"
B_SH_PATH="$OTA_DIR/b.sh"

# --- Начало скрипта ---
clear
echo -e "${BLUE}=====================================================${RESET}"
echo -e "${BLUE}==  Автоматический установщик для OTA Finder  ==${RESET}"
echo -e "${BLUE}=====================================================${RESET}"
echo ""
echo -e "${YELLOW}Этот скрипт автоматически скачает и настроит всё необходимое.${RESET}"
read -p "Нажмите [Enter] для начала установки..."

# --- Шаг 1: Установка curl и создание папки ---
echo -e "\n${GREEN}>>> Шаг 1: Установка 'curl' и настройка хранилища...${RESET}"
pkg install -y curl
termux-setup-storage
mkdir -p "$OTA_DIR"
echo -e "${GREEN}Папка $OTA_DIR создана.${RESET}"

# --- Шаг 2: Загрузка основного скрипта b.sh ---
echo -e "\n${GREEN}>>> Шаг 2: Загрузка основного скрипта (b.sh)...${RESET}"
curl -sL "$B_SH_URL" -o "$B_SH_PATH"

# Проверка, что файл скачался
if [ ! -f "$B_SH_PATH" ] || [ ! -s "$B_SH_PATH" ]; then
    echo -e "\n${RED}ОШИБКА: Не удалось скачать скрипт b.sh!${RESET}"
    echo -e "${YELLOW}Проверьте правильность URL в скрипте ota.sh или ваше интернет-соединение.${RESET}"
    exit 1
fi
echo -e "${GREEN}Скрипт успешно загружен в $B_SH_PATH${RESET}"

# --- Шаг 3: Обновление пакетов и установка зависимостей ---
echo -e "\n${GREEN}>>> Шаг 3: Обновление пакетов Termux...${RESET}"
pkg update -y && pkg upgrade -y
echo -e "\n${GREEN}>>> Шаг 4: Установка зависимостей (python, git, tsu)...${RESET}"
pkg install -y python git tsu

# --- Шаг 4: Установка Python-модулей ---
echo -e "\n${GREEN}>>> Шаг 5: Установка Python-модулей (pycryptodome, requests, realme-ota)...${RESET}"
pip install --upgrade pip wheel
pip install --upgrade pycryptodome requests
pip3 install --upgrade git+https://github.com/R0rt1z2/realme-ota

# --- Шаг 5: Создание ярлыка ---
echo -e "\n${GREEN}>>> Шаг 6: Создание ярлыка для виджета...${RESET}"
SHORTCUT_DIR="$HOME/.shortcuts"
SHORTCUT_FILE="$SHORTCUT_DIR/OnePlus_OTA"

mkdir -p "$SHORTCUT_DIR"
chmod 700 -R "$SHORTCUT_DIR"

# Создаем скрипт-запускатор, который указывает на скачанный b.sh
echo "#!/bin/bash" > "$SHORTCUT_FILE"
echo "bash $B_SH_PATH" >> "$SHORTCUT_FILE"
chmod +x "$SHORTCUT_FILE"
echo -e "${GREEN}Ярлык 'OnePlus_OTA' успешно создан.${RESET}"

# --- Завершение ---
clear
echo -e "${GREEN}=============================================${RESET}"
echo -e "${GREEN}      🎉 Установка успешно завершена! 🎉      ${RESET}"
echo -e "${GREEN}=============================================${RESET}"
echo ""
echo -e "${YELLOW}Что делать дальше:${RESET}"
echo "1. Полностью закройте приложение Termux (командой 'exit' или через меню)."
echo "2. Перейдите на главный экран вашего телефона."
echo "3. Добавьте виджет 'Termux'."
echo "4. В списке доступных ярлыков должен появиться 'OnePlus_OTA'."
echo "5. Нажмите на него, чтобы запустить скрипт поиска обновлений."
echo ""
echo -e "${BLUE}Удачи!${RESET}"
