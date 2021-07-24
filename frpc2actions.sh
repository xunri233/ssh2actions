#!/usr/bin/env bash

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
INFO="[${Green_font_prefix}INFO${Font_color_suffix}]"
ERROR="[${Red_font_prefix}ERROR${Font_color_suffix}]"

if [[ -z "${FRPC_CONFIG_URL}" ]]; then
    echo -e "${ERROR} Please set 'FRPC_CONFIG_URL' environment variable."
    exit 2
fi

if [[ -z "${SYS_PASSWORD}" ]]; then
    echo -e "${ERROR} Please set 'SYS_PASSWORD' environment variable."
    exit 3
fi

if [[ -z "${SYS_USER}" ]]; then
    echo -e "${ERROR} Please set 'SYS_USER' environment variable."
    exit 4
fi


if [[ -n "$(uname | grep -i Linux)" ]]; then
    echo -e "${INFO} download frpc"
    wget https://github.com/fatedier/frp/releases/download/v0.37.0/frp_0.37.0_linux_amd64.tar.gz 
    tar -zxvf frp_0.37.0_linux_amd64.tar.gz
    rm frp_0.37.0_linux_amd64.tar.gz 
    cd frp_0.37.0_linux_amd64
    chmod +x frpc
    sudo mv frpc /usr/local/bin
elif [[ -n "$(uname | grep -i Darwin)" ]]; then
    echo -e "${INFO} download frpc"
    wget https://github.com/fatedier/frp/releases/download/v0.37.0/frp_0.37.0_darwin_amd64.tar.gz
    tar -zxvf frp_0.37.0_darwin_amd64.tar.gz
    rm frp_0.37.0_darwin_amd64.tar.gz
    cd frp_0.37.0_darwin_amd64
    chmod +x frpc
    sudo mv frpc /usr/local/bin
    echo -e "${INFO} Set SSH service ..."
    echo 'PermitRootLogin yes' | sudo tee -a /etc/ssh/sshd_config >/dev/null
    sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist
    sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
else
    echo -e "${ERROR} This system is not supported!"
    exit 1
fi

if [[ -n "${SYS_PASSWORD}" ]]; then
    echo -e "${INFO} Set user(${SYS_USER}) password ..."
    echo -e "${SYS_PASSWORD}\n${SYS_PASSWORD}" | sudo passwd "${SYS_USER}"
fi

echo -e "${INFO} Start frpc proxy for SSH port..."
cd /usr/local/bin
wget ${FRPC_CONFIG_URL}
./frpc
