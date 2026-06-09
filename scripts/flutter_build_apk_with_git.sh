#!/usr/bin/env bash
# 在打出 APK 时把当前 Git 分支最近一次提交的**后 8 位 commit id** 与**提交时间**写入编译期常量（不写 commit message，避免敏感信息）。
# Flutter 代码中读取：[BuildGitInfo]（lib/utils/build_git_info.dart）。
#
# 用法（在项目根目录）：
#   ./scripts/flutter_build_apk_with_git.sh
#     固定带：--release --target-platform android-arm64 --split-per-abi（仅 arm64-v8a 分包）
#     成功后会把 build/app/outputs/flutter-apk/*-release.apk 重命名为
#     *-release_v{pubspec 版本号}_yyyy_mm_dd_hh_mm_ss.apk（版本取自 pubspec.yaml 的 version，去掉 +build）
#     并复制到 ~/Documents/apk（文稿/apk，目录不存在则自动创建）
#     ./scripts/flutter_build_apk_with_git.sh --env PRO
#      ./scripts/flutter_build_apk_with_git.sh --env TEST
#      ./scripts/flutter_build_apk_with_git.sh --env PRO_TEST
#     ./scripts/flutter_build_apk_with_git.sh --env=UAT --obfuscate   # 在默认参数后再追加其它 flutter build apk 选项
#   macOS 上成功后会用 `open` 打开 ~/Documents/apk 目录
#
set -euo pipefail

# 兼容用户用 `sh ./scripts/...` 启动的情况：sh 不支持 bash 数组等语法。
# 正常情况下请直接运行：./scripts/flutter_build_apk_with_git.sh
if [[ -z "${BASH_VERSION:-}" ]]; then
  exec bash "$0" "$@"
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/flutter_build_apk_with_git.sh [--env <ENV>|--env=<ENV>] [--help] [-- <flutter build apk args...>]

Options:
  --env <ENV>        Inject build-time env to Dart define key "APP_EVN" (BuildInfo.appEnv).
                     If omitted, uses $APP_EVN, then $APP_ENV, otherwise defaults to "TEST".
  --help, -h         Show this help.

Notes:
  - This script also injects build metadata via --dart-define-from-file:
    BUILD_GIT_COMMIT_SUFFIX8 / BUILD_GIT_ISO_TIME / BUILD_ISO_TIME (BuildInfo.buildTime).
  - Any extra args are forwarded to `flutter build apk`.
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

# 本地打包时刻，格式：2026-05-20 16:56:39
BUILD_ISO="$(date '+%Y-%m-%d %H:%M:%S')"
export ROOT COMMIT_SUFFIX8 COMMIT_ISO BUILD_ISO APP_EVN_VALUE

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
PY

# 与本项目常用命令对齐：fvm flutter build apk --release --target-platform android-arm64 --split-per-abi
FLUTTER_CMD=(flutter)
if command -v fvm >/dev/null 2>&1; then
  FLUTTER_CMD=(fvm flutter)
fi

flutter_build_cmd=(
  "${FLUTTER_CMD[@]}"
  build apk
  --dart-define-from-file="$ROOT/build/build_git_dart_defines.json"
  --release
  --target-platform android-arm64
  --split-per-abi
)
# bash 3.2 + `set -u`：空数组展开 "${arr[@]}" 会报 unbound；这里做长度判断兼容。
if [[ ${#forward_args[@]} -gt 0 ]]; then
  flutter_build_cmd+=("${forward_args[@]}")
fi
echo "Build command:"
printf '  %q' "${flutter_build_cmd[@]}"
echo
"${flutter_build_cmd[@]}"

apk_dir="$ROOT/build/app/outputs/flutter-apk"
ts="$(date +%Y_%m_%d_%H_%M_%S)"

# pubspec: version: 1.0.0+1 → v1.0.0
# version: 1.0.0+1 → 1.0.0（丢弃 +build；支持引号）
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
pkg_ver_label="v${ver_semver}"

env_slug="${APP_EVN_VALUE//[^[:alnum:]_.-]/_}"
if [[ -z "$env_slug" ]]; then
  env_slug="UNKNOWN"
fi

docs_apk_dir="${HOME}/Documents/apk"
mkdir -p "$docs_apk_dir"

shopt -s nullglob
renamed=0
for f in "$apk_dir"/*-release.apk; do
  base="${f%.apk}"
  dest="${base}_${pkg_ver_label}_${env_slug}_${ts}.apk"
  mv -f -- "$f" "$dest"
  echo "Renamed APK: $dest"
  docs_dest="${docs_apk_dir}/$(basename "$dest")"
  cp -f -- "$dest" "$docs_dest"
  echo "Saved APK to: $docs_dest"
  renamed=1
done
shopt -u nullglob

if [[ "$renamed" -eq 0 ]]; then
  echo "warning: no *-release.apk found under $apk_dir to rename" >&2
fi

# macOS：在 Finder 中打开文稿/apk 目录
if [[ "$(uname -s)" == "Darwin" ]] && [[ -d "$docs_apk_dir" ]]; then
  open "$docs_apk_dir"
fi
