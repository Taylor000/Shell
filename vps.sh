#!/bin/bash

# 自动修复 Windows 换行符问题
sed -i 's/\r$//' "$0" 2>/dev/null

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 作者与脚本信息
AUTHOR_GITHUB="https://github.com/Taylor000"
SCRIPT_NAME="一个人的脚本百宝箱"
SHORTCUT_CMD="vps"

# 默认全局配置
DEFAULT_PORT="11156"
DEFAULT_PASS="github.taylor000"

# 检查是否为 Root
[[ $EUID -ne 0 ]] && echo -e "${RED}错误：请使用 root 用户运行此脚本！${NC}" && exit 1

# 空输入计数器
empty_count=0

# 获取系统基本网络信息
get_network_info() {
    LOCAL_IP=$(curl -s4 https://api64.ipify.org || curl -s4 https://ifconfig.me || curl -s4 https://ip.gs)
    LOCAL_GATEWAY=$(ip route | grep default | awk '{print $3}' | head -n1)
    LOCAL_MASK="255.255.255.0"
}

# 检查并自动安装 Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}检测到系统未安装 Docker，正在开始自动安装...${NC}"
        curl -fsSL https://get.docker.com | bash
        systemctl enable --now docker
        echo -e "${GREEN}Docker 安装完成！${NC}"
    fi
}

# 预检函数
check_installed() {
    if command -v "$1" &> /dev/null || [ -f "/usr/bin/$1" ] || [ -f "/usr/local/bin/$1" ] || [ -d "/www/server/panel" -a "$1" = "bt" ]; then
        echo -e "${YELLOW}【预检提示】系统检测到已安装 ${BLUE}$2${NC}"
        echo -e "${YELLOW}快捷命令: ${RED}$3${NC}"
        read -p "是否仍然重新安装？(y/n, 默认n): " re_confirm
        if [[ $re_confirm != [yY] ]]; then
            return 1
        fi
    fi
    return 0
}

# 菜单函数
show_menu() {
    clear
    echo -e "${BLUE}==================================================${NC}"
    echo -e "${GREEN}             ${SCRIPT_NAME}                  ${NC}"
    echo -e "${BLUE}     Author: ${YELLOW}${AUTHOR_GITHUB}${NC}"
    echo -e "${BLUE}     快捷启动命令: ${RED}${SHORTCUT_CMD}${NC}"
    echo -e "${BLUE}==================================================${NC}"
    echo -e "${YELLOW} 1.${NC} 显示系统基本信息与性能测试"
    echo -e "${YELLOW} 2.${NC} 修改系统 root 密码"
    echo -e "${YELLOW} 3.${NC} 修改 SSH 服务端口"
    echo -e "${YELLOW} 4.${NC} 安装 BBR 加速插件 (秋水逸冰)"
    echo -e "${YELLOW} 5.${NC} 安装 iperf3 网络测速工具"
    echo -e "${YELLOW} 6.${NC} 安装 Debian 11 系统"
    echo -e "${YELLOW} 7.${NC} 安装 Win10 LTSC 系统 (秋水逸冰)"
    echo -e "${YELLOW} 8.${NC} 安装 Win10 系统 (veip007)"
    echo -e "${YELLOW} 9.${NC} 安装 aaPanel 面板 (AaronYES开心版)"
    echo -e "${YELLOW} 10.${NC} 安装 aaPanel 面板 (官方正式版)"
    echo -e "${YELLOW} 11.${NC} 安装 Docker 运行环境"
    echo -e "${YELLOW} 12.${NC} 安装 Realm 端口转发工具"
    echo -e "${YELLOW} 13.${NC} 安装 ServerStatus 监控探针"
    echo -e "${YELLOW} 14.${NC} 安装 Xray 代理服务 (233boy版)"
    echo -e "${YELLOW} 15.${NC} 安装 sing-box 代理服务 (233boy版)"
    echo -e "${YELLOW} 16.${NC} 安装 XrayR 后端对接 (官方正式版)"
    echo -e "${YELLOW} 17.${NC} 安装 XrayR 后端对接 (柚子备份版)"
    echo -e "${BLUE}--------------------------------------------------${NC}"
    echo -e "${RED} 0.${NC} 退出脚本${NC}"
    echo -e "${BLUE}==================================================${NC}"
}

while true; do
    show_menu
    read -p "请输入对应数字进行操作: " choice
    
    if [[ -z "$choice" ]]; then
        ((empty_count++))
        [[ $empty_count -ge 2 ]] && exit 0
        continue
    else
        empty_count=0
    fi

    case $choice in
        1) wget -qO- bench.sh | bash; read -p "按回车继续..." ;;
        2) passwd root; read -p "按回车继续..." ;;
        3)
            CURRENT_SSH_PORT=$(grep -i "^Port" /etc/ssh/sshd_config | awk '{print $2}')
            [ -z "$CURRENT_SSH_PORT" ] && CURRENT_SSH_PORT="22"
            echo -e "${BLUE}当前端口: ${YELLOW}${CURRENT_SSH_PORT}${NC}"
            read -p "继续修改？(y/n): " confirm_ssh
            if [[ $confirm_ssh == [yY] ]]; then
                read -p "新端口 (默认 $DEFAULT_PORT): " ssh_port
                ssh_port=${ssh_port:-$DEFAULT_PORT}
                sed -i "s/^#\?Port .*/Port $ssh_port/" /etc/ssh/sshd_config
                systemctl restart ssh
                echo -e "${GREEN}端口已成功修改为 $ssh_port。${NC}"
            fi
            read -p "按回车继续..." ;;
        4) bash <(curl -Lso- https://github.com/teddysun/across/raw/master/bbr.sh) ;;
        5)
            check_installed "iperf3" "iperf3 测速工具" "iperf3" || { read -p "按回车继续..."; continue; }
            if [ -f /usr/bin/apt ]; then apt update && apt install -y iperf3; elif [ -f /usr/bin/yum ]; then yum install -y epel-release && yum install -y iperf3; fi
            echo -e "${GREEN}安装完成！${NC}服务端运行: ${RED}iperf3 -s${NC} | 客户端: ${RED}iperf3 -c IP${NC}"
            read -p "按回车继续..." ;;
        6)
            read -p "设置密码 (默认 $DEFAULT_PASS): " dd_pass
            dd_pass=${dd_pass:-$DEFAULT_PASS}
            echo -e "${RED}确认：Debian 11 | 密码 $dd_pass${NC}"
            sleep 10
            bash <(wget --no-check-certificate -qO- 'https://www.moeelf.com/attachment/LinuxShell/InstallNET.sh') -d 11 -v 64 -a -p "$dd_pass"
            ;;
        7)
            get_network_info
            read -p "设置密码 (默认 $DEFAULT_PASS): " win_pass
            win_pass=${win_pass:-$DEFAULT_PASS}
            echo -e "${RED}确认：Win10 | 密码 $win_pass${NC}"
            sleep 10
            wget -qO- inst.sh | bash -s - -n $LOCAL_IP,$LOCAL_MASK,$LOCAL_GATEWAY -p "$win_pass" -t https://dl.lamp.sh/vhd/zh-cn_windows10_ltsc.xz
            ;;
        8)
            read -p "设置 Win10 密码 (回车默认: $DEFAULT_PASS): " v_pass
            v_pass=${v_pass:-$DEFAULT_PASS}
            read -p "设置 RDP 端口 (回车默认: 3389): " v_port
            v_port=${v_port:-3389}
            echo -e "${RED}确认：密码 $v_pass | RDP端口 $v_port${NC}"
            sleep 10
            wget -N --no-check-certificate https://raw.githubusercontent.com/veip007/dd/master/InstallNET.sh && chmod +x InstallNET.sh && ./InstallNET.sh -d 10 -v 64 -p "$v_pass" -port "$v_port"
            ;;
        9 | 10)
            check_installed "bt" "aaPanel 面板" "bt" || { read -p "按回车继续..."; continue; }
            if [[ $choice == 9 ]]; then
                wget https://raw.githubusercontent.com/AaronYES/aaPanel/main/script/aapanel.sh -O aapanel.sh && chmod +x aapanel.sh && ./aapanel.sh
            else
                URL=https://www.aapanel.com/script/install_panel_en.sh
                curl -ksSO $URL || wget --no-check-certificate -O install_panel_en.sh $URL
                bash install_panel_en.sh ipssl
                exit 0
            fi
            ;;
        11) check_installed "docker" "Docker" "docker ps" || { read -p "按回车继续..."; continue; }; check_docker; read -p "按回车继续..." ;;
        12) check_installed "realm" "Realm" "./realm.sh" || { read -p "按回车继续..."; continue; }; wget https://raw.githubusercontent.com/jinqians/realm/refs/heads/main/realm.sh && chmod +x realm.sh && ./realm.sh ;;
        13)
            if docker ps -a --format '{{.Names}}' | grep -q "^status$"; then
                read -p "探针容器已存在，是否重装？(y/n): " re_status
                [[ $re_status != [yY] ]] && continue
                docker rm -f status &>/dev/null
            fi
            check_docker; get_network_info
            read -p "探针访问端口 (默认 $DEFAULT_PORT): " s_port
            s_port=${s_port:-$DEFAULT_PORT}
            wget --no-check-certificate -qO ~/serverstatus-config.json https://raw.githubusercontent.com/cppla/ServerStatus/master/server/config.json && mkdir -p ~/serverstatus-monthtraffic
            docker run -d --restart=always --name=status -v ~/serverstatus-config.json:/ServerStatus/server/config.json -v ~/serverstatus-monthtraffic:/usr/share/nginx/html/json -p $s_port:80 -p 35601:35601 cppla/serverstatus:1.1.5
            echo -e "${GREEN}探针地址: http://${LOCAL_IP}:${s_port}${NC}"; read -p "按回车继续..." ;;
        14) check_installed "xray" "Xray" "xray" || { read -p "按回车继续..."; continue; }; bash <(wget -qO- -o- https://github.com/233boy/Xray/raw/main/install.sh) ;;
        15) check_installed "sb" "sing-box" "sb" || { read -p "按回车继续..."; continue; }; bash <(wget -qO- -o- https://github.com/233boy/sing-box/raw/main/install.sh) ;;
        16) check_installed "XrayR" "XrayR 官方" "XrayR" || { read -p "按回车继续..."; continue; }; bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh) ;;
        17) check_installed "xrayr" "XrayR 柚子" "xrayr" || { read -p "按回车继续..."; continue; }; wget -N https://raw.githubusercontent.com/youzi3/XrayR-script/main/install.sh && bash install.sh ;;
        0) exit 0 ;;
        *) echo -e "${RED}选择无效。${NC}"; sleep 1 ;;
    esac
done
