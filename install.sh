#!/data/data/com.termux/files/usr/bin/bash

termux-setup-storage
cd "$HOME"
export DEBIAN_FRONTEND=noninteractive

apt update -y
apt upgrade -y -o Dpkg::Options::="--force-confold"
apt install -y git termux-api ffmpeg libwebp mesa-vulkan-icd-swrast mesa-vulkan-icd-freedreno vulkan-loader

REPO_DIR="$HOME/rife-ncnn-vulkan-termux"
BRANCH="copilot/rife-ffmpeg9-size-encoding"
if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" fetch origin "$BRANCH"
  git -C "$REPO_DIR" checkout "$BRANCH"
  git -C "$REPO_DIR" pull --ff-only origin "$BRANCH"
else
  git clone --branch "$BRANCH" https://github.com/MikuDroid/rife-ncnn-vulkan-termux "$REPO_DIR"
fi

cd "$REPO_DIR"
rm -f 191.mp4 191.gif
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

yes | termux-setup-storage
clear
echo -e "type '\e[31mrifevulkan\e[0m' for video frame interpolation"
