#!/bin/bash

# 自動修復 Windows 換行符問題
sed -i 's/\r$//' "$0" 2>/dev/null

# 定義顏色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 作者與腳本資訊
AUTHOR_GITHUB="https://github.com/Taylor000"
SCRIPT_NAME="一個人的腳本百寶箱"
SHORTCUT_CMD="tool"

# 默認全局配置
DEFAULT_PORT="11156"
DEFAULT_PASS="github.taylor000"
BIND_IP="127.0.0.1"

# 檢查是否為 Root
[[ $EUID -ne 0 ]] && echo -e "${RED}錯誤：請使用 root 用戶運行此腳本！${NC}" && exit 1

# 空輸入計數器
empty_count=0

# 獲取系統基本網絡資訊
get_network_info() {
    LOCAL_IP=$(curl -s4 https://api64.ipify.org || curl -s4 https://ifconfig.me || curl -s4 https://ip.gs)
    LOCAL_GATEWAY=$(ip route | grep default | awk '{print $3}' | head -n1)
    LOCAL_MASK="255.255.255.0"
}

# 檢查並自動安裝 Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}檢測到系統未安裝 Docker，正在開始自動安裝...${NC}"
        curl -fsSL https://get.docker.com | bash
        systemctl enable --now docker
    fi
}

# 預檢函數
check_installed() {
    if command -v "$1" &> /dev/null || [ -f "/usr/bin/$1" ] || [ -f "/usr/local/bin/$1" ] || [ -d "/www/server/panel" -a "$1" = "bt" ]; then
        echo -e "${YELLOW}【預檢提示】系統檢測到已安裝 ${BLUE}$2${NC}"
        echo -e "${YELLOW}快捷命令: ${RED}$3${NC}"
        read -p "是否仍然重新安裝？(y/n, 默認n): " re_confirm
        if [[ $re_confirm != [yY] ]]; then
            return 1
        fi
    fi
    return 0
}

# 精簡頁眉顯示 (用於安裝完成後保持視野)
show_mini_header() {
    echo -e "\n${BLUE}==================================================${NC}"
    echo -e "${GREEN}             ${SCRIPT_NAME}                  ${NC}"
    echo -e "${BLUE}     Author: ${YELLOW}${AUTHOR_GITHUB}${NC}"
    echo -e "${BLUE}     快捷啟動命令: ${RED}${SHORTCUT_CMD}${NC}"
    echo -e "${BLUE}==================================================${NC}"
    read -p "安裝已結束。是否返回百寶箱主菜單？(y/n): " back_choice
    if [[ $back_choice != [yY] ]]; then
        echo -e "${GREEN}腳本已退出。${NC}"
        exit 0
    fi
}

# 菜單函數
show_menu() {
    clear
    echo -e "${BLUE}==================================================${NC}"
    echo -e "${GREEN}             ${SCRIPT_NAME}                  ${NC}"
    echo -e "${BLUE}     Author: ${YELLOW}${AUTHOR_GITHUB}${NC}"
    echo -e "${BLUE}     快捷啟動命令: ${RED}${SHORTCUT_CMD}${NC}"
    echo -e "${BLUE}==================================================${NC}"
    echo -e "${YELLOW} 1.${NC} 顯示系統基本信息與性能測試"
    echo -e "${YELLOW} 2.${NC} 修改系統 root 密碼"
    echo -e "${YELLOW} 3.${NC} 修改 SSH 服務端口"
    echo -e "${YELLOW} 4.${NC} 安裝 BBR 加速插件 (秋水逸冰)"
    echo -e "${YELLOW} 5.${NC} 安裝 iperf3 網絡測速工具"
    echo -e "${YELLOW} 6.${NC} 安裝 Debian 11 系統"
    echo -e "${YELLOW} 7.${NC} 安裝 Win10 LTSC 系統 (秋水逸冰)"
    echo -e "${YELLOW} 8.${NC} 安裝 Win10 系統 (veip007)"
    echo -e "${YELLOW} 9.${NC} 安裝 aaPanel 面板 (AaronYES開心版)"
    echo -e "${YELLOW} 10.${NC} 安裝 aaPanel 面板 (官方正式版)"
    echo -e "${YELLOW} 11.${NC} 安裝 Docker 運行環境"
    echo -e "${YELLOW} 12.${NC} 安裝 Realm 端口轉發工具"
    echo -e "${YELLOW} 13.${NC} 安裝 ServerStatus 監控探針"
    echo -e "${YELLOW} 14.${NC} 安裝 Xray 代理服務 (233boy版)"
    echo -e "${YELLOW} 15.${NC} 安裝 sing-box 代理服務 (233boy版)"
    echo -e "${YELLOW} 16.${NC} 安裝 XrayR 後端對接 (官方正式版)"
    echo -e "${YELLOW} 17.${NC} 安裝 XrayR 後端對接 (柚子備份版)"
    echo -e "${BLUE}--------------------------------------------------${NC}"
    echo -e "${RED} 0.${NC} 退出腳本${NC}"
    echo -e "${BLUE}==================================================${NC}"
}

while true; do
    show_menu
    read -p "請輸入對應數字進行操作: " choice
    
    if [[ -z "$choice" ]]; then
        ((empty_count++))
        [[ $empty_count -ge 2 ]] && exit 0
        continue
    else
        empty_count=0
    fi

    case $choice in
        1) wget -qO- bench.sh | bash; read -p "按回車繼續..." ;;
        2) passwd root; read -p "按回車繼續..." ;;
        3)
            CURRENT_SSH_PORT=$(grep -i "^Port" /etc/ssh/sshd_config | awk '{print $2}')
            [ -z "$CURRENT_SSH_PORT" ] && CURRENT_SSH_PORT="22"
            echo -e "${BLUE}當前端口: ${YELLOW}${CURRENT_SSH_PORT}${NC}"
            read -p "繼續修改？(y/n): " confirm_ssh
            if [[ $confirm_ssh == [yY] ]]; then
                read -p "新端口 (默認 $DEFAULT_PORT): " ssh_port
                ssh_port=${ssh_port:-$DEFAULT_PORT}
                sed -i "s/^#\?Port .*/Port $ssh_port/" /etc/ssh/sshd_config
                systemctl restart ssh
                echo -e "${GREEN}端口已成功修改。${NC}"
            fi
            read -p "按回車繼續..." ;;
        4) bash <(curl -Lso- https://github.com/teddysun/across/raw/master/bbr.sh) ;;
        5)
            check_installed "iperf3" "iperf3 測速工具" "iperf3" || { read -p "按回車繼續..."; continue; }
            if [ -f /usr/bin/apt ]; then apt update && apt install -y iperf3; elif [ -f /usr/bin/yum ]; then yum install -y epel-release && yum install -y iperf3; fi
            echo -e "${GREEN}安裝完成！${NC}服務端運行: ${RED}iperf3 -s${NC}"
            read -p "按回車繼續..." ;;
        6)
            read -p "設置密碼 (默認 $DEFAULT_PASS): " dd_pass
            dd_pass=${dd_pass:-$DEFAULT_PASS}
            bash <(wget --no-check-certificate -qO- 'https://www.moeelf.com/attachment/LinuxShell/InstallNET.sh') -d 11 -v 64 -a -p "$dd_pass"
            ;;
        7)
            get_network_info
            read -p "設置密碼 (默認 $DEFAULT_PASS): " win_pass
            win_pass=${win_pass:-$DEFAULT_PASS}
            wget -qO- inst.sh | bash -s - -n $LOCAL_IP,$LOCAL_MASK,$LOCAL_GATEWAY -p "$win_pass" -t https://dl.lamp.sh/vhd/zh-cn_windows10_ltsc.xz
            ;;
        8)
            read -p "設置 Win10 密碼 (回車默認: $DEFAULT_PASS): " v_pass
            v_pass=${v_pass:-$DEFAULT_PASS}
            read -p "設置 RDP 端口 (回車默認: 3389): " v_port
            v_port=${v_port:-3389}
            wget -N --no-check-certificate https://raw.githubusercontent.com/veip007/dd/master/InstallNET.sh && chmod +x InstallNET.sh && ./InstallNET.sh -d 10 -v 64 -p "$v_pass" -port "$v_port"
            ;;
        9 | 10)
            check_installed "bt" "aaPanel 面板" "bt" || { read -p "按回車繼續..."; continue; }
            if [[ $choice == 9 ]]; then
                wget https://raw.githubusercontent.com/AaronYES/aaPanel/main/script/aapanel.sh -O aapanel.sh && chmod +x aapanel.sh && ./aapanel.sh
            else
                URL=https://www.aapanel.com/script/install_panel_en.sh
                curl -ksSO $URL || wget --no-check-certificate -O install_panel_en.sh $URL
                bash install_panel_en.sh ipssl
            fi
            show_mini_header ;;
        11) check_installed "docker" "Docker" "docker ps" || { read -p "按回車繼續..."; continue; }; check_docker; read -p "按回車繼續..." ;;
        12) check_installed "realm" "Realm" "./realm.sh" || { read -p "按回車繼續..."; continue; }; wget https://raw.githubusercontent.com/jinqians/realm/refs/heads/main/realm.sh && chmod +x realm.sh && ./realm.sh ;;
        13)
            if docker ps -a --format '{{.Names}}' | grep -q "^status$"; then
                read -p "探針容器已存在，是否重裝？(y/n): " re_status
                [[ $re_status != [yY] ]] && continue
                docker rm -f status &>/dev/null
            fi
            check_docker; get_network_info
            read -p "探針內部監聽端口 (默認 $DEFAULT_PORT): " s_port
            s_port=${s_port:-$DEFAULT_PORT}
            wget --no-check-certificate -qO ~/serverstatus-config.json https://raw.githubusercontent.com/cppla/ServerStatus/master/server/config.json && mkdir -p ~/serverstatus-monthtraffic
            docker run -d --restart=always --name=status -v ~/serverstatus-config.json:/ServerStatus/server/config.json -v ~/serverstatus-monthtraffic:/usr/share/nginx/html/json -p ${BIND_IP}:${s_port}:80 -p 35601:35601 cppla/serverstatus:1.1.5
            echo -e "${GREEN}探針安裝完成！反代目標: http://127.0.0.1:${s_port}${NC}"
            read -p "按回車繼續..." ;;
        14)
            check_installed "xray" "Xray" "xray" || { read -p "按回車繼續..."; continue; }
            bash <(wget -qO- -o- https://github.com/233boy/Xray/raw/main/install.sh)
            show_mini_header ;;
        15)
            check_installed "sb" "sing-box" "sb" || { read -p "按回車繼續..."; continue; }
            bash <(wget -qO- -o- https://github.com/233boy/sing-box/raw/main/install.sh)
            show_mini_header ;;
        16)
            check_installed "XrayR" "XrayR 官方" "XrayR" || { read -p "按回車繼續..."; continue; }
            bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)
            show_mini_header ;;
        17)
            check_installed "xrayr" "XrayR 柚子" "xrayr" || { read -p "按回車繼續..."; continue; }
            wget -N https://raw.githubusercontent.com/youzi3/XrayR-script/main/install.sh && bash install.sh
            show_mini_header ;;
        0) exit 0 ;;
        *) echo -e "${RED}選擇無效。${NC}"; sleep 1 ;;
    esac
done
