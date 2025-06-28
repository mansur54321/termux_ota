#!/bin/bash

# ==============================================================================
# ==   Универсальный автоматический установщик (максимально надежный)        ==
# ==============================================================================

export DEBIAN_FRONTEND=noninteractive

# --- НАСТРОЙКИ ---
B_SH_URL="https://raw.githubusercontent.com/mansur54321/termux_ota/main/b.sh"
DEVICES_TXT_URL="https://raw.githubusercontent.com/mansur54321/sus/main/devices.txt"
# Исправил ссылку на devices.txt, убрав /refs/heads - так надежнее

# --- КОНЕЦ НАСТРОЕК ---

# Цвета для красивого вывода
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

# Пути
OTA_DIR="/storage/emulated/0/OTA"
B_SH_PATH="$OTA_DIR/b.sh"
DEVICES_TXT_PATH="$HOME/devices.txt"
REALME_OTA_BIN="/data/data/com.termux/files/usr/bin/realme-ota"

handle_error() {
    echo -e "\n${RED}ОШИБКА: $1${RESET}"
    echo -e "${YELLOW}Установка прервана. Возможные причины:${RESET}"
    echo -e "${YELLOW}- Отсутствует интернет-соединение в Termux.${RESET}"
    echo -e "${YELLOW}- Включен VPN/Ad-blocker, который блокирует доступ.${RESET}"
    echo -e "${YELLOW}- Система Android ограничила сетевую активность Termux.${RESET}"
    exit 1
}

# --- НАЧАЛО СКРИПТА ---
clear
echo -e "${BLUE}=====================================================${RESET}"
echo -e "${BLUE}==     Автоматический установщик для Realme OTA    ==${RESET}"
echo -e "${BLUE}=====================================================${RESET}"
echo ""
echo -e "${YELLOW}Этот скрипт автоматически скачает и настроит всё необходимое.${RESET}"
read -p "Нажмите [Enter] для начала..."
sleep 2 # Небольшая пауза для "пробуждения" сети

# --- Шаг 1: Настройка хранилища и обновление пакетов ---
echo -e "\n${GREEN}>>> Шаг 1: Настройка хранилища и обновление системы...${RESET}"
termux-setup-storage
mkdir -p "$OTA_DIR" || handle_error "Не удалось создать папку $OTA_DIR."

DPKG_OPTIONS="-o Dpkg::Options::=--force-confold"
pkg update -y || handle_error "Не удалось обновить списки пакетов. Проверьте интернет."
pkg upgrade -y $DPKG_OPTIONS || handle_error "Не удалось обновить пакеты."
echo -e "${GREEN}Система Termux успешно обновлена.${RESET}"

# --- Шаг 2: Установка системных зависимостей ---
echo -e "\n${GREEN}>>> Шаг 2: Установка системных пакетов...${RESET}"
pkg install -y $DPKG_OPTIONS python python2 git tsu curl || handle_error "Не удалось установить системные пакеты."
echo -e "${GREEN}Все системные пакеты установлены.${RESET}"

# --- Шаг 3: Установка Python-модулей ---
echo -e "\n${GREEN}>>> Шаг 3: Установка Python-модулей...${RESET}"
pip install --upgrade pip wheel pycryptodome || handle_error "Не удалось установить базовые Python-модули."
pip3 install --upgrade requests pycryptodome git+https://github.com/R0rt1z2/realme-ota || handle_error "Не удалось установить realme-ota."

if [ -f "$REALME_OTA_BIN" ]; then
    chmod +x "$REALME_OTA_BIN"
else
    echo -e "${YELLOW}ПРЕДУПРЕЖДЕНИЕ: Не найден файл $REALME_OTA_BIN.${RESET}"
fi
echo -e "${GREEN}Python-модули успешно установлены.${RESET}"

# --- Шаг 4: Загрузка основного скрипта b.sh ---
echo -e "\n${GREEN}>>> Шаг 4: Загрузка основного скрипта (b.sh)...${RESET}"
# ИСПОЛЬЗУЕМ --fail для надежной проверки
curl -sL --fail "$B_SH_URL" -o "$B_SH_PATH"
if [ $? -ne 0 ]; then
    handle_error "Не удалось скачать скрипт b.sh! Проверьте URL и интернет-соединение в Termux."
fi
echo -e "${GREEN}Скрипт b.sh успешно загружен.${RESET}"

# --- Шаг 5: Загрузка списка устройств ---
echo -e "\n${GREEN}>>> Шаг 5: Загрузка списка устройств (devices.txt)...${RESET}"
curl -sL --fail "$DEVICES_TXT_URL" -o "$DEVICES_TXT_PATH"
if [ $? -ne 0 ]; then
    handle_error "Не удалось скачать файл devices.txt! Проверьте URL и интернет-соединение в Termux."
fi
echo -e "${GREEN}Файл devices.txt успешно загружен.${RESET}"

# --- Шаг 6: Создание ярлыка для виджета ---
echo -e "\n${GREEN}>>> Шаг 6: Автоматическое создание ярлыка...${RESET}"
SHORTCUT_DIR="$HOME/.shortcuts"
SHORTCUT_FILE="$SHORTCUT_DIR/Realme_OTA"
mkdir -p "$SHORTCUT_DIR"
chmod 700 -R "$SHORTCUT_DIR"
{
    echo "#!/bin/bash"
    echo "bash $B_SH_PATH"
} > "$SHORTCUT_FILE"
chmod +x "$SHORTCUT_FILE"
echo -e "${GREEN}Ярлык 'Realme_OTA' успешно создан!${RESET}"

# --- ЗАВЕРШЕНИЕ ---
clear
# ... (финальное сообщение без изменений) ...
echo -e "${GREEN}=============================================${RESET}"
echo -e "${GREEN}      🎉 Установка успешно завершена! 🎉      ${RESET}"
echo -e "${GREEN}=============================================${RESET}"
echo ""
echo -e "${YELLOW}Что делать дальше:${RESET}"
echo "1. Полностью закройте приложение Termux (командой 'exit' или через меню)."
echo "2. Перейдите на главный экран вашего телефона."
echo "3. Добавьте виджет 'Termux'."
echo "4. В списке доступных ярлыков должен появиться 'Realme_OTA'."
echo "5. Нажмите на него, чтобы запустить скрипт поиска обновлений."
echo ""
echo -e "${BLUE}Удачи!${RESET}"
