#!/data/data/com.termux/files/usr/bin/bash

set -e

termux-setup-storage
export DEBIAN_FRONTEND=noninteractive

apt update -y
apt upgrade -y -o Dpkg::Options::="--force-confold"
apt install -y git termux-api ffmpeg libwebp mesa-vulkan-icd-swrast mesa-vulkan-icd-freedreno vulkan-loader

REPO_DIR="$HOME/rife-ncnn-vulkan-termux"
BRANCH="master"
REPO_URL="https://github.com/MikuDroid/rife-ncnn-vulkan-termux"

if [ -e "$REPO_DIR" ]; then
  if [ ! -d "$REPO_DIR/.git" ]; then
    echo "Refusing to overwrite '$REPO_DIR': it exists but is not a Git repository." >&2
    echo "Move it aside or choose another location, then rerun the installer. Nothing was deleted." >&2
    exit 1
  fi
  if [ -n "$(git -C "$REPO_DIR" status --porcelain)" ]; then
    echo "Refusing to update '$REPO_DIR': it contains local changes or untracked files." >&2
    echo "Back up or commit those files, then rerun. Nothing was deleted." >&2
    exit 1
  fi
  git -C "$REPO_DIR" fetch origin "$BRANCH"
  git -C "$REPO_DIR" switch "$BRANCH"
  git -C "$REPO_DIR" pull --ff-only origin "$BRANCH"
else
  git clone --branch "$BRANCH" "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"
mkdir -p "$PREFIX/bin"
cp rifevulkan "$PREFIX/bin/rifevulkan"
chmod +x "$PREFIX/bin/rifevulkan"

while true; do
  printf "Install custom font? (y/n): "
  read -r choice < /dev/tty
  case "$choice" in
    [Yy])
      mkdir -p "$HOME/.termux"
      cp "$REPO_DIR/font.ttf" "$HOME/.termux/font.ttf"
      termux-reload-settings >/dev/null 2>&1
      echo "Font installed."
      break ;;
    [Nn]) break ;;
  esac
done

clear
echo -e "type '\e[31mrifevulkan\e[0m' for video frame interpolation"
