#!/bin/bash

# proxychains 安装配置脚本
# 功能：安装 proxychains 并设置 SOCKS5 代理模板

# 检查是否为 root 权限
if [ "$EUID" -ne 0 ]; then
    echo "请使用 sudo 运行此脚本 (例如: sudo $0)"
    exit 1
fi

# 步骤 1: 更新软件源并安装 proxychains
echo "正在更新软件包列表..."
apt-get update -qq > /dev/null

echo "正在安装 proxychains..."
if apt-get install -y proxychains > /dev/null 2>&1; then
    echo "✅ proxychains 安装成功"
else
    echo "❌ proxychains 安装失败，请检查网络或软件源"
    exit 1
fi

# 步骤 2: 备份原始配置文件
config_file="/etc/proxychains.conf"
backup_file="/etc/proxychains.conf.bak"
if [ ! -f "$backup_file" ]; then
    cp "$config_file" "$backup_file"
    echo "🔒 原始配置文件已备份到 $backup_file"
fi

# 步骤 3: 写入自定义配置（SOCKS5 代理模板）
cat > "$config_file" << EOF
strict_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
# 默认使用 SSH 隧道创建的 SOCKS5 代理（端口 12345）
# 请根据实际代理地址修改以下行
socks5 127.0.0.1 12345
EOF

echo "⚙️  代理模板配置已写入 $config_file"
echo "----------------------------------------"
echo "使用说明："
echo "1. 请确保已建立 SSH 隧道（在本地执行local/start.sh）"
echo "2. 使用命令格式: proxychains <需要代理的命令>"
echo "3. 例如测试代理: proxychains curl -v https://github.com"
echo "----------------------------------------"

# 验证安装
if command -v proxychains > /dev/null; then
    echo "✅ 安装验证通过"
else
    echo "❌ 安装后未找到 proxychains 命令"
fi