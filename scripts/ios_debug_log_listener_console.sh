#!/usr/bin/env bash

PORT=8081

if ! command -v iproxy &> /dev/null; then
    echo "❌ 未检测到 iproxy，请先安装 libimobiledevice:"
    echo "   brew install libimobiledevice"
    exit 1
fi

if ! command -v websocat &> /dev/null && ! command -v wscat &> /dev/null; then
    echo "❌ 未检测到 websocat 或 wscat，请先安装其一:"
    echo "   brew install websocat   # 推荐，支持客户端 ping 保活"
    echo "   npm install -g wscat"
    exit 1
fi

echo "🧹 正在清理旧的转发和监听进程..."
kill -9 $(lsof -t -i:${PORT}) 2>/dev/null || true
pkill -f "iproxy.*${PORT}" 2>/dev/null || true
pkill -f "wscat.*${PORT}" 2>/dev/null || true
sleep 1

IPROXY_PID=""

start_iproxy() {
    kill $IPROXY_PID 2>/dev/null || true
    pkill -f "iproxy.*${PORT}:" 2>/dev/null || true
    sleep 0.3
    echo "🔗 正在建立 iOS USB 端口转发 (Mac:${PORT} -> 手机:${PORT})..."
    iproxy ${PORT}:${PORT} > /dev/null 2>&1 &
    IPROXY_PID=$!
    sleep 0.5
}

connect_ws() {
    if command -v websocat &> /dev/null; then
        # 客户端发 ping，比 App 端 ping 经 iproxy 更可靠
        websocat --ping-interval 10 --ping-timeout 20 "ws://127.0.0.1:${PORT}"
    else
        wscat -c "ws://127.0.0.1:${PORT}"
    fi
}

cleanup() {
    echo -e "\n🛑 正在停止监听并关闭通道..."
    kill $IPROXY_PID 2>/dev/null || true
    exit 0
}
trap cleanup INT TERM

start_iproxy

echo "--------------------------------------"
echo "🚀 iOS 通道就绪！"
echo "💡 请先启动 iPhone App，脚本会自动连接手机 WebSocket 服务"
echo "   （App 监听手机 localhost:${PORT}，按 Ctrl+C 退出）"
echo "--------------------------------------"

while true; do
    echo "🔌 正在连接 ws://127.0.0.1:${PORT} ..."
    connect_ws || true
    echo "⚠️  连接断开，3 秒后重试..."
    sleep 3
    start_iproxy
done
