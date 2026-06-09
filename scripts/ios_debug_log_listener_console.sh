#!/usr/bin/env bash

PORT=8081

if ! command -v iproxy &> /dev/null; then
    echo "❌ 未检测到 iproxy，请先安装 libimobiledevice:"
    echo "   brew install libimobiledevice"
    exit 1
fi

if ! command -v wscat &> /dev/null; then
    echo "❌ 未检测到 wscat，请先安装:"
    echo "   npm install -g wscat"
    exit 1
fi

echo "🧹 正在清理旧的转发和监听进程..."
kill -9 $(lsof -t -i:${PORT}) 2>/dev/null || true
pkill -f "iproxy.*${PORT}" 2>/dev/null || true
pkill -f "wscat.*${PORT}" 2>/dev/null || true
sleep 1

echo "🔗 正在建立 iOS USB 端口转发 (Mac:${PORT} -> 手机:${PORT})..."
# iproxy 方向: Mac 连 localhost:PORT 会转发到手机 PORT（App 在该端口监听 WebSocket）
iproxy ${PORT}:${PORT} > /dev/null 2>&1 &
IPROXY_PID=$!

cleanup() {
    echo -e "\n🛑 正在停止监听并关闭通道..."
    kill $IPROXY_PID 2>/dev/null || true
    exit 0
}
trap cleanup INT TERM

echo "--------------------------------------"
echo "🚀 iOS 通道就绪！"
echo "💡 请先启动 iPhone App，脚本会自动连接手机 WebSocket 服务"
echo "   （App 监听手机 localhost:${PORT}，按 Ctrl+C 退出）"
echo "--------------------------------------"

while true; do
    echo "🔌 正在连接 ws://127.0.0.1:${PORT} ..."
    wscat -c "ws://127.0.0.1:${PORT}" || true
    echo "⚠️  连接断开，3 秒后重试（请确认 App 已启动）..."
    sleep 3
done
