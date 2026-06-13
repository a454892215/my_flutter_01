#!/usr/bin/env bash

PORT=8081
LOCK_DIR="/tmp/ios_debug_log_listener_${PORT}.lock"

if ! command -v iproxy &> /dev/null; then
    echo "❌ 未检测到 iproxy，请先安装 libimobiledevice:"
    echo "   brew install libimobiledevice"
    exit 1
fi

if ! command -v websocat &> /dev/null; then
    echo "❌ 未检测到 websocat，请先安装:"
    echo "   brew install websocat"
    exit 1
fi

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "❌ 端口 ${PORT} 已有监听进程在运行，无法重复启动"
    echo "   请先关闭已有终端中的脚本；若确认无旧进程，可执行:"
    echo "   rm -rf ${LOCK_DIR}"
    exit 1
fi

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

# 仅接收 App 日志；勿开 WebSocket ping（经 iproxy pong 易丢导致 1006）。
# --no-line：原样输出 WebSocket 消息，换行由 App 端 payload 决定。
# -n + </dev/null：stdin EOF 时不关闭连接（勿用 tail|websocat，websocat 退出后 tail 会挂住管道导致无法重连）。
# 断线后由外层 while 循环负责重连。
connect_ws() {
    websocat -q --no-line -n "ws://127.0.0.1:${PORT}" < /dev/null
}

cleanup() {
    echo -e "\n🛑 正在停止监听并关闭通道..."
    kill $IPROXY_PID 2>/dev/null || true
    rm -rf "$LOCK_DIR"
    exit 0
}
trap cleanup INT TERM
trap 'rm -rf "$LOCK_DIR"' EXIT

start_iproxy

echo "--------------------------------------"
echo "🚀 iOS 通道就绪！"
echo "💡 请先启动 iPhone App，脚本会自动连接手机 WebSocket 服务"
echo "   （App 监听手机 localhost:${PORT}，按 Ctrl+C 退出）"
echo "--------------------------------------"

FAIL_COUNT=0
while true; do
    echo "🔌 正在连接 ws://127.0.0.1:${PORT} ..."
    if connect_ws; then
        FAIL_COUNT=0
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    echo "⚠️  连接断开，3 秒后重试..."
    sleep 3
    # 连续失败才重启 iproxy，避免每次断线都 pkill 隧道加剧 ECONNRESET
    if [ "$FAIL_COUNT" -ge 3 ]; then
        echo "🔄 iproxy 连续失败 ${FAIL_COUNT} 次，正在重启隧道..."
        start_iproxy
        FAIL_COUNT=0
    fi
done
