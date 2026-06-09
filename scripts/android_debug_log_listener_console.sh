#!/usr/bin/env bash

# 1. 彻底清理旧的规则，防止端口冲突
echo "🧹 正在清理旧的 ADB 转发规则..."
adb forward --remove-all 2>/dev/null
adb reverse --remove-all 2>/dev/null

# 2. 建立反向代理（手机 8080 -> Mac 8080）
echo "🔗 正在建立 USB 反向代理通道..."
adb reverse tcp:8080 tcp:8080

# 3. 检查反向通道是否真的建立成功
echo "🔍 当前活跃的反向通道列表："
adb reverse --list

echo "--------------------------------------"
echo "🚀 ADB 通道就绪！开始监听 App 实时数据..."
echo "💡 提示：现在可以启动手机 App 并触发连接了（按 Ctrl+C 退出）"
echo "--------------------------------------"

# 4. 启动服务器监听
wscat -l 8080