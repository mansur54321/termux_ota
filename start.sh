#!/bin/bash

# --- НАСТРОЙКИ ---
B_SH_URL="https://raw.githubusercontent.com/mansur54321/termux_ota/refs/heads/main/b.sh"
REALME_OTA_REPO_URL="https://github.com/R0rt1z2/realme-ota.git"
# --- КОНЕЦ НАСТРОЕК ---

# Цвета для красивого вывода
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

# Целевые папки и пути
OTA_DIR="/storage/emulated/0/OTA"
REALME_OTA_DIR="$OTA_DIR/realme-ota"
B_SH_PATH="$OTA_DIR/b.sh"

# --- ФУНКЦИИ ---

# Функция для вывода ошибки и выхода
handle_error() {
    echo -e "\n${RED}ОШИБКА: $1${RESET}"
    echo -e "${YELLOW}Установка прервана. Пожалуйста, исправьте проблему и запустите скрипт снова.${RESET}"
    exit 1
}

# Функция для проверки наличия команды (установленного пакета)
check_command() {
    command -v "$1" >/dev/null 2>&1 || handle_error "Пакет '$1' не был установлен или не найден в PATH."
}

# Функция для проверки установленного Python-модуля
check_python_module() {
    python -c "import $1" &>/dev/null || handle_error "Python-модуль '$1' не был установлен."
}


# --- НАЧАЛО СКРИПТА ---
clear
echo -e "${BLUE}=====================================================${RESET}"
echo -e "${BLUE}==     Автоматический установщик для Realme OTA    ==${RESET}"
echo -e "${BLUE}=====================================================${RESET}"
echo ""
echo -e "${YELLOW}Этот скрипт автоматически скачает и настроит всё необходимое.${RESET}"
read -p "Нажмите [Enter] для начала установки..."

# --- Шаг 1: Настройка хранилища и создание папок ---
echo -e "\n${GREEN}>>> Шаг 1: Настройка хранилища...${RESET}"
termux-setup-storage
mkdir -p "$OTA_DIR" || handle_error "Не удалось создать папку $OTA_DIR."
echo -e "${GREEN}Папка $OTA_DIR готова к работе.${RESET}"

# --- Шаг 2: Обновление и установка системных пакетов ---
echo -e "\n${GREEN}>>> Шаг 2: Обновление пакетов и установка зависимостей...${RESET}"
# ИСПРАВЛЕНИЕ: Добавлена опция --force-confold для автоматического обновления
pkg update -y && pkg upgrade -y -o Dpkg::Options::="--force-confold"
pkg install -y curl git python tsu || handle_error "Не удалось установить базовые пакеты."

# Проверка установленных системных пакетов
echo -e "\n${BLUE}Проверка системных пакетов...${RESET}"
check_command "curl"
check_command "git"
check_command "python"
check_command "tsu"
echo -e "${GREEN}Все системные пакеты успешно установлены.${RESET}"

# --- Шаг 3: Клонирование репозитория realme-ota ---
echo -e "\n${GREEN}>>> Шаг 3: Загрузка утилиты realme-ota...${RESET}"
if [ -d "$REALME_OTA_DIR" ]; then
    echo -e "${YELLOW}Папка '$REALME_OTA_DIR' уже существует. Обновляем репозиторий...${RESET}"
    cd "$REALME_OTA_DIR" || handle_error "Не удалось перейти в папку $REALME_OTA_DIR"
    git pull || handle_error "Не удалось обновить репозиторий через 'git pull'."
    cd - > /dev/null
else
    echo -e "${BLUE}Клонируем репозиторий из GitHub...${RESET}"
    git clone "$REALME_OTA_REPO_URL" "$REALME_OTA_DIR" || handle_error "Не удалось клонировать репозиторий."
fi
echo -e "${GREEN}Утилита realme-ota успешно загружена в $REALME_OTA_DIR.${RESET}"

# --- Шаг 4: Установка Python-модулей ---
echo -e "\n${GREEN}>>> Шаг 4: Установка Python-модулей...${RESET}"
pip install --upgrade pip wheel

# Устанавливаем зависимости
pip install --upgrade pycryptodome requests || handle_error "Не удалось установить pycryptodome или requests."

# Устанавливаем саму утилиту из локальной папки
pip install --upgrade "$REALME_OTA_DIR" || handle_error "Не удалось установить realme-ota из локальной папки."

# Проверка установленных Python-модулей
echo -e "\n${BLUE}Проверка Python-модулей...${RESET}"
check_python_module "Crypto" # pycryptodome импортируется как Crypto
check_python_module "requests"
check_python_module "realme_ota"
echo -e "${GREEN}Все Python-модули успешно установлены.${RESET}"

# --- Шаг 5: Загрузка основного скрипта b.sh ---
echo -e "\n${GREEN}>>> Шаг 5: Загрузка основного скрипта (b.sh)...${RESET}"
curl -sL "$B_SH_URL" -o "$B_SH_PATH"
if [ ! -f "$B_SH_PATH" ] || [ ! -s "$B_SH_PATH" ]; then
    handle_error "Не удалось скачать скрипт b.sh! Проверьте URL и интернет-соединение."
fi
echo -e "${GREEN}Скрипт успешно загружен в $B_SH_PATH${RESET}"


# --- Шаг 6: Создание ярлыка ---
echo -e "\n${GREEN}>>> Шаг 6: Создание ярлыка для виджета...${RESET}"
SHORTCUT_DIR="$HOME/.shortcuts"
SHORTCUT_FILE="$SHORTCUT_DIR/Realme_OTA"

mkdir -p "$SHORTCUT_DIR"
chmod 700 -R "$SHORTCUT_DIR"

# Создаем скрипт-запускатор, который указывает на скачанный b.sh
echo "#!/bin/bash" > "$SHORTCUT_FILE"
echo "bash $B_SH_PATH" >> "$SHORTCUT_FILE"
chmod +x "$SHORTCUT_FILE"
echo -e "${GREEN}Ярлык 'Realme_OTA' успешно создан.${RESET}"

# --- ЗАВЕРШЕНИЕ ---
clear
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
