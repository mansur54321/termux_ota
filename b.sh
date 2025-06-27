
#!/bin/bash/
# 🎨 Farby pre lepšiu čitateľnosť
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
PURPLE="\e[35m"
BLUE="\e[34m"
RESET="\e[0m"

# 📌 Maps regions, kodov and nv_id
 declare -A REGIONS=(
    [A6]="MEA Middle_East_Africa 10100110"
    [1A]="TW Taiwan 00011010"
    [1B]="IN India 00011011"
    [9A]="LATAM Latin_America 10011010"
    [2C]="SG Singapure 00101100"
    [33]="ID Indonesia 00110011"
    [51]="TR Turkey 01010001"
    [75]="EG Egypt 01110101"
    [37]="RU Russia 00110111"
    [38]="MY Malaysia 00111000"
    [39]="TH Thailand 00111001"
    [44]="EUEX Europe 01000100"
    [83]="SA Saudi_Arabia 10000011"
    [A4]="APC Global 10100100"
    [A7]="ROW Global 10100111"
    [97]="CN China 10010111"
)
# 📌 Version Android
declare -A VERSIONS=(
    [A]="Launch version"
    [C]="First update"
    [F]="Second update"
    [H]="Third update"
)

# 📌 Server pre OTA (predvolený -r 3, výnimka CN -r 1)
 declare -A SERVERS=(
    [44]="-r 0"  # Europa
    [51]="-r 0"  # Turkey
    [A7]="-r 3"  # Row
    [97]="-r 1"  # China 
)

# 📌 Výpis regiónov
clear
echo -e "${GREEN}=======================================${RESET}"
echo -e "${GREEN}===${RESET}  ${YELLOW}OnePlus/OPPO/Realme OTAFindeR${RESET}  ${GREEN}===${RESET}"
echo -e "${GREEN}=======================================${RESET}"
printf "| %-5s | %-6s | %-18s |\n" "Manif" "R Code" "Region"
echo -e "---------------------------------------"

# Výpis tabuľky
for key in "${!REGIONS[@]}"; do
    region_data=(${REGIONS[$key]})
    region_code=${region_data[0]}
    region_name=${region_data[1]}

printf "|  ${YELLOW}%-4s${RESET} | %-6s | %-18s |\n" "$key" "$region_code" "$region_name"
done



echo -e "---------------------------------------"
echo -e "${GREEN}=======================================${RESET}"
echo -e "${GREEN}===${RESET}" "OTA version :  ${BLUE}A${RESET} ,  ${BLUE}C${RESET} ,  ${BLUE}F${RESET} ,  ${BLUE}H${RESET}"      "${GREEN}===${RESET}"
echo -e "${GREEN}=======================================${RESET}"

# 📌 Používateľ zadá model (automaticky začína na CPH)
read -p "📌 Enter the model number: " model_number
device_model="$model_number"

while true; do
    # 📌 Používateľ zadá región + verziu
    read -p "📌 Manifest + OTA version: " input
    region="${input:0:${#input}-1}"
    version="${input: -1}"


# 📌 Overenie vstupu
if [[ -z "${REGIONS[$region]}" || -z "${VERSIONS[$version]}" ]]; then
    echo -e "❌ Invalid input! Try again."
    exit 1
fi

# 📌 Načítanie údajov o regióne
region_data=(${REGIONS[$region]})
region_code=${region_data[0]}   # Napr. "MEA"
region_name=${region_data[1]}   # Napr. "Middle_East_Africa"
if [[ "$region" == "2C" ]]; then
    nv_id="00101100"
else
    nv_id=${region_data[2]}
fi

# 📌 Nastavenie servera
server="${SERVERS[$region]:--r 3}"

# 📌 **Oprava OTA modelu** (odstránenie regionálneho kódu)
ota_model="${device_model//SG/}"  # Odstráni "SG" z CPH2671SG
ota_model="${ota_model//EEA/}"  # Odstráni "EEA" z CPH2653EEA
ota_model="${ota_model//IN/}"  # Odstráni "IN" z CPH2649IN
ota_model="${ota_model//RU/}"  # Odstráni "RU" z RMX3853RU
ota_model="${ota_model//T2/}"  # Odstráni "T2" z RMX3301T2
ota_model="${ota_model//ID/}"  # Odstráni "ID" z CPH2671ID
ota_model="${ota_model//MY/}"  # Odstráni "MY" z CPH2671MY
ota_model="${ota_model//TH/}"  # Odstráni "TH" z CPH2671TH
ota_model="${ota_model//GLO/}"  # Odstráni "GLO" z CPH2653GLO
ota_model="${ota_model//APC/}"  # Odstráni "APC" z CPH2671APC
ota_model="${ota_model//CN/}"  # Odstráni "CN" z PJZ110CN

#  📌 Výpis konfigurácie
echo -e "🛠 Model: ${GREEN}$device_model${RESET}"
echo -e "🛠 Region: ${GREEN}$region_name${RESET} (code:${YELLOW}$region_code${RESET})"
echo -e "🛠 OTA version: ${BLUE}${VERSIONS[$version]}${RESET}"
echo -e "🛠 NV_ID: ${YELLOW}$region${RESET}"
echo -e "🛠 Server: ${GREEN}$server${RESET}"

# 📌 Overenie vstupu
if [[ -z "${REGIONS[$region]}" ]]; then
    echo -e "${RED}❌ Invalid region. Please try again.${RESET}"
    exit 1
fi

# 📌 Načítanie údajov o regióne
region_data=(${REGIONS[$region]})
region_code=${region_data[0]}
region_name=${region_data[1]}
nv_id=${region_data[2]}

# 📌 Nastavenie servera
server="${SERVERS[$region]:--r 3}"

# 📌 Modely
model_with_region="$device_model"  # Model v príkaze (napr. CPH2653EEA)

# 📌 Ak model obsahuje "EEA", ponecháme ho nezmenené
if [[ "$device_model" =~ EEA$ ]]; then
    ota_model="$ota_model"

# 📌 Ak model obsahuje iné regionálne označenie, odstránime ho
else
    ota_model="${device_model//EEA/}"
    ota_model="${ota_model//IN/}"
    ota_model="${ota_model//ID/}"
    ota_model="${ota_model//T2/}"
    ota_model="${ota_model//GLO/}"
    ota_model="${ota_model//MY/}"
    ota_model="${ota_model//TR/}"
    ota_model="${ota_model//RU/}"
    ota_model="${ota_model//TH/}"
    ota_model="${ota_model//SG/}"
    ota_model="${ota_model//EU/}"
    ota_model="${ota_model//APC/}"
    ota_model="${ota_model//CN/}"
fi

# 📌 Spustenie OTA príkazu
ota_command="realme-ota $server $model_with_region ${ota_model}_11.${version}.01_0001_100001010000 6 $nv_id"

output=$(eval "$ota_command")

# 📌 Extrakcia správnej hodnoty F.?? a dátumu zo serverovej odpovede
real_ota_version=$(echo "$output" | grep -o '"realOtaVersion": *"[^"]*"' | cut -d '"' -f4)
real_version_name=$(echo "$output" | grep -o '"realVersionName": *"[^"]*"' | cut -d '"' -f4)
os_version=$(echo "$output" | grep -o '"realOsVersion": *"[^"]*"' | cut -d '"' -f4)
security_os=$(echo "$output" | grep -o '"securityPatchVendor": *"[^"]*"' | cut -d '"' -f4)
android_version=$(echo "$output" | grep -o '"androidVersion": *"[^"]*"' | cut -d '"' -f4)
# Predpokladáme že celý JSON je v premennej "$output"

# Získať URL k About this update
about_update_url=$(echo "$output" | grep -oP '"panelUrl"\s*:\s*"\K[^"]+')

# Získať VersionTypeId
version_type_id=$(echo "$output" | grep -oP '"versionTypeId"\s*:\s*"\K[^"]+')

# Výpis
echo -e "ℹ️   OTA Version: ${YELLOW}$real_ota_version${RESET}"
echo -e "ℹ️   Version Firmware: ${PURPLE}$real_version_name${RESET}"
echo -e "ℹ️   Android Version: ${YELLOW}$android_version${RESET}"
echo -e "ℹ️   OS Version: ${YELLOW}$os_version${RESET}"
echo -e "ℹ️   Security Patch: ${YELLOW}$security_os${RESET}"
echo -e "ℹ️   ChangeLoG: ${GREEN}$about_update_url${RESET}"
echo -e "ℹ️   Status OTA: ${YELLOW}$version_type_id${RESET}"

# **Získanie správneho F.?? z realOtaVersion**
ota_f_version=$(echo "$real_ota_version" | grep -oE '_11\.[A-Z]\.[0-9]+' | sed 's/_11\.//')

# **Získanie dátumu z realOtaVersion**
ota_date=$(echo "$real_ota_version" | grep -oE '_[0-9]{12}$' | tr -d '_')

# 📌 Zostavenie správneho názvu OTA verzie
ota_version_full="${ota_model}_11.${ota_f_version}_${region_code}_${ota_date}"

# 📌 Extrakcia odkazu na stiahnutie
download_link=$(echo "$output" | grep -o 'http[s]*://[^"]*' | head -n 1 | sed 's/["\r\n]*$//')
modified_link=$(echo "$download_link" | sed 's/componentotacostmanual/opexcostmanual/g')

# 📌 Výstup na obrazovku
echo -e "\n📥 OTA version: ${BLUE}$ota_version_full${RESET}"
if [[ -n "$modified_link" ]]; then
    echo -e "📥 Download URL: ${GREEN}$modified_link${RESET}"
else
    echo -e "❌ Download Link not found."
fi


file="Ota_links.csv"
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
ota_info="$ota_version_full"
firmware_info="$real_version_name"
android="$android_version"
version_os="$os_version"
security="$security_os"
link="$modified_link"

# Ak súbor neexistuje, vytvor ho a pridaj hlavičku
if [ ! -f "$file" ]; then
    echo "OTA Version and URL:" > "$file"
    echo "" >> "$file"
fi

# Overenie, či už existuje
if ! grep -qF "$link" "$file"; then
    echo "$timestamp" >> "$file"
    echo "$ota_info" >> "$file"
    echo "$firmware_info" >> "$file"
    echo "$android" >> "$file"
    echo "$version_os" >> "$file"
    echo "$security" >> "$file"
    echo "$link" >> "$file"
    echo "" >> "$file"
    echo -e "✅ The link has been saved to ${YELLOW}$file${RESET}"
else
    echo "ℹ️   The link has already been saved."
fi


# Možnosti návratu
 echo -e "\n🔄 1 - Change only region/version (keep model: ${GREEN}$device_model${RESET})"
echo -e "🔄 2 - Change device model"
echo -e "❌ 3 - End script"
echo -e "⬇️  4 -${GREEN}$Show URLs${RESET}" "(long press to open the menu)"
echo -e "     → More > Select URL"
echo -e "     → ${PURPLE}Tap to copy the link${RESET}, ${BLUE}long press to open in browser${RESET}"

read -p "💡 Select an option (1/2/3): " choice

if [[ "$choice" == "2" ]]; then
    bash "$0"
    exit 0
elif [[ "$choice" == "3" ]]; then
    echo -e "👋 Goodbye."
    exit 0
fi
done