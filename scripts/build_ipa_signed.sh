#!/usr/bin/env bash
# 打出「已签名、可本地真机安装」的 IPA。
# 与 scripts/build_ipa.sh 共用同一套 APP_EVN / Git dart-define 注入逻辑，但走 Xcode 签名 + flutter build ipa。
#
# 前置条件（本机一次性配置）：
#   1. 安装 Xcode，并在 Xcode 登录 Apple ID（Settings → Accounts）。
#   2. ios/Runner.xcodeproj 已配置 DEVELOPMENT_TEAM（Automatic Signing）。
#   3. 目标 iPhone 用数据线连 Mac，在 Xcode → Window → Devices and Simulators 中信任设备；
#      Automatic Signing 会自动把该设备注册到 Development Profile。
#
# 用法（在项目根目录）：
#   ./scripts/build_ipa_signed.sh
#   ./scripts/build_ipa_signed.sh --env PRO
#   ./scripts/build_ipa_signed.sh --env TEST --export-method ad-hoc
#   ./scripts/build_ipa_signed.sh --export-method development -- <其它 flutter build ipa 参数>
#
set -euo pipefail

if [[ -z "${BASH_VERSION:-}" ]]; then
  exec bash "$0" "$@"
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

START_TIME=$(date +%s)

usage() {
  cat <<'EOF'
Usage:
  ./scripts/build_ipa_signed.sh [--env <ENV>|--env=<ENV>] [--export-method <METHOD>] [--help] [-- <flutter build ipa args...>]

Options:
  --env <ENV>              注入 APP_EVN（BuildInfo.appEnv）。未指定时用 $APP_EVN / $APP_ENV，否则默认 TEST。
  --export-method <METHOD> 导出方式，默认 development（本地真机安装推荐）。
                           可选: development | ad-hoc | app-store | enterprise
  --help, -h               显示帮助。

说明:
  - 自动注入构建元数据：BUILD_GIT_COMMIT_SUFFIX8 / BUILD_GIT_ISO_TIME / BUILD_ISO_TIME（BuildInfo.buildTime）。
  - 使用 `flutter build ipa` 完成 Archive + 签名 + Export，产物可复制到真机安装。
  - development：本机开发证书，适合连过 Xcode 的测试机（默认）。
  - ad-hoc：需在 Apple Developer 后台预先注册设备 UDID。
  - 产物默认输出到 /Users/app/Documents/ipa，并在 macOS 上用 Finder 打开该目录。

安装 IPA 到真机（任选其一）：
  - Xcode → Window → Devices and Simulators → 选中设备 → Installed Apps → 「+」选 IPA
  - Apple Configurator 2 拖入 IPA
  - 命令行: ideviceinstaller -i /path/to/app.ipa  （需 brew install ideviceinstaller）
EOF
}

APP_EVN_VALUE=""
EXPORT_METHOD="development"
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
    --export-method)
      if [[ $# -lt 2 ]]; then
        echo "error: --export-method requires a value" >&2
        exit 2
      fi
      EXPORT_METHOD="$2"
      shift 2
      ;;
    --export-method=*)
      EXPORT_METHOD="${1#--export-method=}"
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

case "$EXPORT_METHOD" in
  development|ad-hoc|app-store|enterprise) ;;
  *)
    echo "error: invalid --export-method: $EXPORT_METHOD" >&2
    exit 2
    ;;
esac

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

echo ">>> build_ipa_signed.sh  APP_EVN=${APP_EVN_VALUE}  export=${EXPORT_METHOD}  Git=${COMMIT_SUFFIX8}"

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

APP_NAME="WmPay"
TIMESTAMP="$(date +%Y_%m_%d_%H_%M_%S)"
EXPORT_DIR="/Users/app/Documents/ipa"
DART_DEFINES_FILE="$ROOT/build/build_git_dart_defines.json"

mkdir -p "$EXPORT_DIR"

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

IPA_NAME="${APP_NAME}_v${ver_semver}_${env_slug}_${EXPORT_METHOD}_${TIMESTAMP}_${COMMIT_SUFFIX8}.ipa"

FLUTTER_CMD=(flutter)
if command -v fvm >/dev/null 2>&1; then
  FLUTTER_CMD=(fvm flutter)
fi

echo "📦 1. 获取依赖..."
"${FLUTTER_CMD[@]}" pub get > /dev/null

write_dart_defines

flutter_build_cmd=(
  "${FLUTTER_CMD[@]}"
  build ipa
  --dart-define-from-file="$DART_DEFINES_FILE"
  --release
  --export-method="$EXPORT_METHOD"
)
if [[ ${#forward_args[@]} -gt 0 ]]; then
  flutter_build_cmd+=("${forward_args[@]}")
fi

echo "🔨 2. Archive + 签名 + Export IPA（export-method=${EXPORT_METHOD}）..."
echo "Build command:"
printf '  %q' "${flutter_build_cmd[@]}"
echo
"${flutter_build_cmd[@]}"

BUILT_IPA=""
if [[ -f "build/ios/ipa/${APP_NAME}.ipa" ]]; then
  BUILT_IPA="build/ios/ipa/${APP_NAME}.ipa"
elif [[ -f "build/ios/ipa/wm_pay_flutter.ipa" ]]; then
  BUILT_IPA="build/ios/ipa/wm_pay_flutter.ipa"
else
  BUILT_IPA="$(find build/ios/ipa -maxdepth 1 -name '*.ipa' -print -quit 2>/dev/null || true)"
fi

if [[ -z "$BUILT_IPA" || ! -f "$BUILT_IPA" ]]; then
  echo "❌ 错误: 未在 build/ios/ipa/ 找到导出的 IPA" >&2
  exit 1
fi

FINAL_IPA="${EXPORT_DIR}/${IPA_NAME}"
cp -f "$BUILT_IPA" "$FINAL_IPA"

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo "------------------------------------------------"
echo "✅ 签名 IPA 已生成"
echo "🕒 执行总耗时: ${MINUTES}分${SECONDS}秒"
echo "📦 最终路径: ${FINAL_IPA}"
echo "🌐 APP_EVN: ${APP_EVN_VALUE}"
echo "🔏 Export method: ${EXPORT_METHOD}"
echo "🔖 Git: ${COMMIT_SUFFIX8} @ ${COMMIT_ISO}"
echo "------------------------------------------------"
echo ""
echo "真机安装提示:"
echo "  - 首次安装需在 iPhone：设置 → 通用 → VPN与设备管理 → 信任开发者证书"
echo "  - 若 export-method=development，请确保该 iPhone 曾通过 Xcode 连接并完成信任"

if [[ "$(uname -s)" == "Darwin" ]] && [[ -d "$EXPORT_DIR" ]]; then
  open "$EXPORT_DIR"
fi
