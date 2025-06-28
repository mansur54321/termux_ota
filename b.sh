#!/bin/bash

# 🎨 Colors for better readability
RED="\e[31m"; GREEN="\e[32m"; PURPLE="\e[35m";
YELLOW="\e[33m"; BLUE="\e[34m"; RESET="\e[0m"

# 📌 Regions, versions, and servers
declare -A REGIONS=(
    [A4]="APC Global 10100100"
    [A5]="OCA Oce_Cen_Australia 10100101"
    [A6]="MEA Middle_East_Africa 10100110"
    [A7]="ROW Global 10100111"
    [1A]="TW Taiwan 00011010"
    [1B]="IN India 00011011"
    [2C]="SG Singapure 00101100"
    [3C]="VN Vietnam 00111100"
    [3E]="PH Philippines 00111110"
    [33]="ID Indonesia 00110011"
    [37]="RU Russia 00110111"
    [38]="MY Malaysia 00111000"
    [39]="TH Thailand 00111001"
    [44]="EUEX Europe 01000100"
    [51]="TR Turkey 01010001"
    [75]="EG Egypt 01110101"
    [82]="HK Hong_Kong 10000010"
    [83]="SA Saudi_Arabia 10000011"
    [9A]="LATAM Latin_America 10011010"
    [97]="CN China 10010111"
)
declare -A VERSIONS=(
  [A]="Launch version" [C]="First update" [F]="Second update" [H]="Third update"
)
declare -A SERVERS=(
  [97]="-r 1" [44]="-r 0" [51]="-r 0"
)

# 📌 Function to process OTA
run_ota() {
    # Input validation
    if [[ -z "${REGIONS[$region]}" || -z "${VERSIONS[$version]}" ]]; then
        echo -e "${RED}❌ Invalid region or version. Please try again.${RESET}"
        return 1
    fi

    region_data=(${REGIONS[$region]})
    region_code=${region_data[0]}
    region_name=${region_data[1]}
    nv_id=${region_data[2]}
    server="${SERVERS[$region]:--r 3}"
    ota_model="$device_model"
    
    # Remove regional suffixes from the model for the OTA request
    for rm in TR RU EEA T2 CN IN ID MY TH EU SG GLO APC; do
        ota_model="${ota_model//$rm/}";
    done

    echo -e "\n🛠 Model: ${COLOR}$device_model${RESET}"
    echo -e "🛠 Region: ${GREEN}$region_name${RESET} (code: ${YELLOW}$region_code${RESET})"
    echo -e "🛠 OTA version: ${BLUE}${VERSIONS[$version]}${RESET}"
    echo -e "🛠 Server: ${GREEN}$server${RESET}"

    # More reliable direct call to the Python module
    export PYTHONUTF8=1
    ota_command="python -m realme_ota.main $server $device_model ${ota_model}_11.${version}.01_0001_100001010000 6 $nv_id"
    
    echo -e "🔍 Running: ${BLUE}$ota_command${RESET}"
    output=$(eval "$ota_command")

    # If there is no output, nothing was found
    if [[ -z "$output" ]]; then
        echo -e "${RED}❌ OTA not found. Check if the model, region, and version are correct.${RESET}"
        return
    fi

    # Processing the output
    real_ota_version=$(echo "$output" | grep -o '"realOtaVersion": *"[^"]*"' | cut -d '"' -f4)
    real_version_name=$(echo "$output" | grep -o '"realVersionName": *"[^"]*"' | cut -d '"' -f4)
    ota_f_version=$(echo "$real_ota_version" | grep -oE '_11\.[A-Z]\.[0-9]+' | sed 's/_11\.//')
    ota_date=$(echo "$real_ota_version" | grep -oE '_[0-9]{12}$' | tr -d '_')
    ota_version_full="${ota_model}_11.${ota_f_version}_${region_code}_${ota_date}"
    os_version=$(echo "$output" | grep -o '"realOsVersion": *"[^"]*"' | cut -d '"' -f4)
    security_os=$(echo "$output" | grep -o '"securityPatchVendor": *"[^"]*"' | cut -d '"' -f4)
    android_version=$(echo "$output" | grep -o '"androidVersion": *"[^"]*"' | cut -d '"' -f4)
    about_update_url=$(echo "$output" | grep -oP '"panelUrl"\s*:\s*"\K[^"]+')
    version_type_id=$(echo "$output" | grep -oP '"versionTypeId"\s*:\s*"\K[^"]+')
    download_link=$(echo "$output" | grep -o 'http[s]*://[^"]*' | head -n 1 | sed 's/["\r\n]*$//')
    modified_link=$(echo "$download_link" | sed 's/componentotacostmanual/opexcostmanual/g')

    # Displaying information
    echo -e "ℹ️   OTA Version: ${YELLOW}$real_ota_version${RESET}"
    echo -e "ℹ️   Firmware Version: ${PURPLE}$real_version_name${RESET}"
    echo -e "ℹ️   Android Version: ${YELLOW}$android_version${RESET}"
    echo -e "ℹ️   OS Version: ${YELLOW}$os_version${RESET}"
    echo -e "ℹ️   Security Patch: ${YELLOW}$security_os${RESET}"
    echo -e "ℹ️   Changelog URL: ${GREEN}$about_update_url${RESET}"
    echo -e "ℹ️   OTA Status: ${BLUE}$version_type_id${RESET}"

    echo -e "\n📥 OTA Version Name: ${BLUE}$ota_version_full${RESET}"
    if [[ -n "$modified_link" ]]; then
        echo -e "📥 Download URL: ${GREEN}$modified_link${RESET}"
    else
        echo -e "❌ Download URL not found."
    fi

    # Saving to file
    file="Ota_links.csv"
    if [[ ! -f "$file" ]]; then echo "Timestamp,OTA Version,Firmware,Android,OS,Security,URL" > "$file"; fi
    if ! grep -qF "$modified_link" "$file" && [[ -n "$modified_link" ]]; then
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$timestamp,\"$ota_version_full\",\"$real_version_name\",\"$android_version\",\"$os_version\",\"$security_os\",\"$modified_link\"" >> "$file"
        echo -e "✅ Link has been saved to ${YELLOW}$file${RESET}"
    else
        echo "ℹ️   Link has already been saved."
    fi
}

# 📌 MAIN MENU
clear
echo -e "${GREEN}=======================================${RESET}"
echo -e "${GREEN}===${RESET}  ${YELLOW}OnePlus/OPPO/Realme OTAFindeR${RESET}  ${GREEN}===${RESET}"
echo -e "${GREEN}=======================================${RESET}"
printf "| %-5s | %-6s | %-18s |\n" "Manif" "R Code" "Region"
echo -e "---------------------------------------"
# Displaying the regions table
keys=("${!REGIONS[@]}"); IFS=$'\n' keys=($(sort <<<"${keys[*]}")); unset IFS
for key in "${keys[@]}"; do
    region_data=(${REGIONS[$key]})
    printf "|  ${YELLOW}%-4s${RESET} | %-6s | %-18s |\n" "$key" "${region_data[0]}" "${region_data[1]}"
done
echo -e "---------------------------------------"
echo -e "OTA version: ${BLUE}A${RESET}=Launch, ${BLUE}C${RESET}=1st, ${BLUE}F${RESET}=2nd, ${BLUE}H${RESET}=3rd"
echo -e "${GREEN}=======================================${RESET}"

# 📌 Select device source
echo -e "📦 Select how to enter the model:"
echo -e "  ${YELLOW}1)${RESET} Enter model manually"
echo -e "  ${PURPLE}2)${RESET} Select from list (devices.txt)"
read -p "💡 Your choice (1/2): " choice

if [[ "$choice" == "2" ]]; then
    if [[ ! -f "devices.txt" ]]; then echo -e "❌ File 'devices.txt' not found. Please create it."; exit 1; fi
    echo -e "\n📱 ${PURPLE}List of available devices:${RESET}";
    echo -e "${GREEN}+----+----------------------+----------------+--------+-----+"
    printf "| %-2s | %-20s | %-14s | %-6s | %-3s |\n" "No." "Device" "Model" "Manif" "OTA"
    echo -e "+----+----------------------+----------------+--------+-----+"
    mapfile -t devices < <(grep -v '^\s*$' devices.txt)
    for i in "${!devices[@]}"; do
        IFS='|' read -r d m r v <<< "${devices[$i]}"
        printf "| ${YELLOW}%-2d${RESET} | %-20s | %-14s | %-6s | %-3s |\n" $((i+1)) "$d" "$m" "$r" "$v"
    done
    echo -e "${GREEN}+----+----------------------+----------------+--------+-----+"
    read -p "🔢 Enter device number: " selected
    if ! [[ "$selected" =~ ^[0-9]+$ ]] || (( selected < 1 || selected > ${#devices[@]} )); then echo "❌ Invalid selection."; exit 1; fi
    IFS='|' read -r selected_name selected_model region version <<< "${devices[$((selected-1))]}"
    device_model="$(echo $selected_model | xargs)"; region="$(echo $region | xargs)"; version="$(echo $version | xargs)"
    echo -e "✅ Selected device: ${PURPLE}$selected_name${RESET} → ${BLUE}$device_model${RESET}, ${GREEN}$region${RESET}, ${YELLOW}$version${RESET}"
    if [[ "$device_model" == CPH* ]]; then COLOR=$YELLOW; elif [[ "$device_model" == RMX* ]]; then COLOR=$GREEN; else COLOR=$BLUE; fi
else
    COLOR=$BLUE
    read -p "📌 Enter model (e.g. CPH2581EEA): " device_model
    if [[ -z "$device_model" ]]; then echo "❌ Model cannot be empty."; exit 1; fi
    read -p "📌 Enter Manifest + OTA version (e.g. 44C): " input
    region="${input:0:${#input}-1}"; version="${input: -1}"
fi

# ✅ First run of the OTA function
run_ota

# 🔁 Loop for further actions
while true; do
    echo -e "\n🔄 1 - Change only region/version (model: ${COLOR}$device_model${RESET})"
    echo -e "🔄 2 - Change device model (restarts script)"
    echo -e "🔄 3 - Show links list (Ota_links.csv)"
    echo -e "❌ 0 - End script"
    read -p "💡 Your choice (1/2/3/0): " option
    case "$option" in
        1)
            read -p "📌 Enter Manifest + OTA version (e.g. 44F): " input
            region="${input:0:${#input}-1}"; version="${input: -1}"
            run_ota
            ;;
        2) bash "$0"; exit 0 ;;
        3) 
            if [[ -f "Ota_links.csv" ]]; then 
                echo -e "\n--- Contents of Ota_links.csv ---"
                cat Ota_links.csv
                echo -e "-----------------------------------\n"
            else 
                echo -e "❌ File 'Ota_links.csv' has not been created yet."
            fi 
            ;;
        0) echo -e "👋 Goodbye."; exit 0 ;;
        *) echo "❌ Invalid option." ;;
    esac
done
