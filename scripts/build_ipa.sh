#!/usr/bin/env bash
# 打出 IPA 时注入 [BuildInfo]（lib/utils/build_info_manager.dart）所需的编译期常量：
#   APP_EVN、BUILD_GIT_COMMIT_SUFFIX8、BUILD_GIT_ISO_TIME、BUILD_ISO_TIME
# 与 scripts/flutter_build_apk_with_git.sh 使用同一套 --env / dart-define 逻辑。
#
# 用法（在项目根目录）：
#   ./scripts/build_ipa.sh
#   ./scripts/build_ipa.sh --env PRO
#   ./scripts/build_ipa.sh --env TEST
#   ./scripts/build_ipa.sh --env PRO_TEST
#   ./scripts/build_ipa.sh --env=UAT --obfuscate   # 在默认参数后再追加其它 flutter build ios 选项
#
# 本脚本产出为「未签名」IPA（--no-codesign + 手动 zip），无法直接装到真机。
# 需要本地真机可安装的签名包，请使用 ./scripts/build_ipa_signed.sh
#
set -euo pipefail

# 兼容用户用 `sh ./scripts/build_ipa.sh` 启动的情况。
if [[ -z "${BASH_VERSION:-}" ]]; then
  exec bash "$0" "$@"
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# --- 环境初始化 ---
# 勿 source ~/.zshrc：非交互 bash 下 zshrc 常会 exit，导致脚本无任何输出即退出。
START_TIME=$(date +%s)

usage() {
  cat <<'EOF'
Usage:
  ./scripts/build_ipa.sh [--env <ENV>|--env=<ENV>] [--help] [-- <flutter build ios args...>]

Options:
  --env <ENV>        注入 APP_EVN（BuildInfo.appEnv）。
                     未指定时使用 $APP_EVN，再 $APP_ENV，否则默认 "TEST"。
  --help, -h         显示帮助。

说明:
  - 自动注入构建元数据：BUILD_GIT_COMMIT_SUFFIX8 / BUILD_GIT_ISO_TIME / BUILD_ISO_TIME（BuildInfo.buildTime）。
  - 其余参数会透传给 `flutter build ios`（在默认 --release --no-codesign 之后）。
  - 产物默认输出到 /Users/app/Documents/ipa，并在 macOS 上用 Finder 打开该目录。
EOF
}

APP_EVN_VALUE=""
forward_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --env)
      if [[ $# -lt 2 ]]; then
        echo "error: --env requires a value" >&2
        exit 2
      fi
      APP_EVN_VALUE="$2"
      shift 2
      ;;
    --env=*)
      APP_EVN_VALUE="${1#--env=}"
      shift 1
      ;;
    --)
      shift
      forward_args+=("$@")
      break
      ;;
    *)
      forward_args+=("$1")
      shift 1
      ;;
  esac
done

if [[ ! -d "$ROOT/.git" ]]; then
  echo "error: not a git repository: $ROOT" >&2
  exit 1
fi

FULL_HASH="$(git -C "$ROOT" rev-parse HEAD)"
COMMIT_SUFFIX8="${FULL_HASH: -8}"
COMMIT_ISO="$(git -C "$ROOT" log -1 --format=%ci --no-patch)"

if [[ -z "$APP_EVN_VALUE" ]]; then
  APP_EVN_VALUE="${APP_EVN:-${APP_ENV:-}}"
fi
if [[ -z "$APP_EVN_VALUE" ]]; then
  APP_EVN_VALUE="TEST"
fi

export ROOT COMMIT_SUFFIX8 COMMIT_ISO APP_EVN_VALUE

echo ">>> build_ipa.sh  APP_EVN=${APP_EVN_VALUE}  Git=${COMMIT_SUFFIX8}"

write_dart_defines() {
  # 本地打包时刻，格式：2026-05-20 16:56:39
  BUILD_ISO="$(date '+%Y-%m-%d %H:%M:%S')"
  export BUILD_ISO
  mkdir -p "$ROOT/build"
  python3 << 'PY'
import json
import os
from pathlib import Path

root = Path(os.environ["ROOT"])
suffix = os.environ["COMMIT_SUFFIX8"]
iso_time = os.environ["COMMIT_ISO"]
build_iso = os.environ["BUILD_ISO"]
app_evn = os.environ.get("APP_EVN_VALUE", "")
defines = {
    "APP_EVN": app_evn,
    "BUILD_GIT_COMMIT_SUFFIX8": suffix,
    "BUILD_GIT_ISO_TIME": iso_time,
    "BUILD_ISO_TIME": build_iso,
}
out_path = root / "build" / "build_git_dart_defines.json"
out_path.parent.mkdir(parents=True, exist_ok=True)
out_path.write_text(json.dumps(defines, ensure_ascii=False), encoding="utf-8")
print(f"Wrote dart-defines file: {out_path}")
print(f"  APP_EVN={app_evn!r}")
print(f"  BUILD_GIT_COMMIT_SUFFIX8={suffix!r}")
print(f"  BUILD_GIT_ISO_TIME={iso_time!r}")
print(f"  BUILD_ISO_TIME={build_iso!r}")
PY
}

# --- 配置变量 ---
APP_NAME="Pay"
TIMESTAMP="$(date +%Y_%m_%d_%H_%M_%S)"
EXPORT_DIR="/Users/app/Documents/ipa"
TEMP_OUTPUT="$HOME/Desktop/${APP_NAME}_Temp"
APP_PATH="build/ios/iphoneos/Runner.app"
DART_DEFINES_FILE="$ROOT/build/build_git_dart_defines.json"

mkdir -p "$EXPORT_DIR"

# pubspec: version: 1.0.0+1 → 1.0.0
ver_semver="$(python3 << 'PY'
import re
from pathlib import Path

text = Path("pubspec.yaml").read_text(encoding="utf-8")
m = re.search(r"(?m)^version:\s*(.+?)\s*$", text)
if not m:
    raise SystemExit(1)
v = m.group(1).strip().strip("'\"")
v = v.split("+", 1)[0]
print(v)
PY
)"
if [[ -z "$ver_semver" ]]; then
  echo "error: failed to parse version from pubspec.yaml (^version:)" >&2
  exit 1
fi

env_slug="${APP_EVN_VALUE//[^[:alnum:]_.-]/_}"
if [[ -z "$env_slug" ]]; then
  env_slug="UNKNOWN"
fi

IPA_NAME="${APP_NAME}_v${ver_semver}_${env_slug}_${TIMESTAMP}_${COMMIT_SUFFIX8}.ipa"

FLUTTER_CMD=(flutter)
if command -v fvm >/dev/null 2>&1; then
  FLUTTER_CMD=(fvm flutter)
fi

echo "🧹 正在深度清理 (包括 FVM 缓存)..."
"${FLUTTER_CMD[@]}" clean > /dev/null
rm -rf ios/Flutter/App.framework
rm -rf ios/Flutter/Flutter.framework
rm -rf build/ios

echo "📦 1. 正在获取依赖..."
"${FLUTTER_CMD[@]}" pub get > /dev/null

# flutter clean 会删掉 build/，必须在 clean 之后再写 dart-defines
write_dart_defines

flutter_build_cmd=(
  "${FLUTTER_CMD[@]}"
  build ios
  --dart-define-from-file="$DART_DEFINES_FILE"
  --release
  --no-codesign
)
if [[ ${#forward_args[@]} -gt 0 ]]; then
  flutter_build_cmd+=("${forward_args[@]}")
fi

echo "🔨 2. 开始 Flutter Release 编译 (AOT 模式)..."
echo "Build command:"
printf '  %q' "${flutter_build_cmd[@]}"
echo
"${flutter_build_cmd[@]}"

if [[ ! -d "$APP_PATH" ]]; then
  echo "❌ 错误: 编译失败，未在 $APP_PATH 找到产物"
  exit 1
fi

echo "🚀 3. 提取并打包 IPA..."
rm -rf "$TEMP_OUTPUT"
mkdir -p "$TEMP_OUTPUT/Payload"
cp -r "$APP_PATH" "$TEMP_OUTPUT/Payload/"

# --- 验证逻辑 ---
echo "🔍 正在验证二进制特征..."
KERNEL_FILE="$TEMP_OUTPUT/Payload/Runner.app/Frameworks/App.framework/flutter_assets/kernel_blob.bin"
BINARY_FILE="$TEMP_OUTPUT/Payload/Runner.app/Frameworks/App.framework/App"

if [[ -f "$KERNEL_FILE" ]]; then
  RESULT_MODE="DEBUG (含有 JIT 字节码)"
  COLOR="\033[0;31m"
elif nm "$BINARY_FILE" 2>/dev/null | grep -q "_kDartIsolateSnapshotInstructions"; then
  RESULT_MODE="RELEASE (纯 AOT 机器码)"
  COLOR="\033[0;32m"
else
  RESULT_MODE="UNKNOWN"
  COLOR="\033[0;33m"
fi

cd "$TEMP_OUTPUT"
zip -r -q "$IPA_NAME" Payload
mv -f "$IPA_NAME" "$EXPORT_DIR/"
cd - > /dev/null
rm -rf "$TEMP_OUTPUT"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo -e "------------------------------------------------"
echo -e "✅ 处理完成！"
echo -e "🕒 执行总耗时: ${MINUTES}分${SECONDS}秒"
echo -e "📦 最终路径: ${EXPORT_DIR}/${IPA_NAME}"
echo -e "🌐 APP_EVN: ${APP_EVN_VALUE}"
echo -e "🔖 Git: ${COMMIT_SUFFIX8} @ ${COMMIT_ISO}"
echo -e "🛡️  验证结果: ${COLOR}${RESULT_MODE}\033[0m"
echo -e "------------------------------------------------"

if [[ "$(uname -s)" == "Darwin" ]] && [[ -d "$EXPORT_DIR" ]]; then
  open "$EXPORT_DIR"
fi
