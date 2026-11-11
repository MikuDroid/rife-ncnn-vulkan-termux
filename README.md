# RIFE-ncnn-vulkan for video interpolation
# Tutorial
![Demo](./mqdefault.jpg)
# ⚠️ Note
- `Stuck at 'Pick video from system…'? Ctrl+C > launch Termux API > back to Termux > run rifevulkan`

- `Android 10? Possibly broken`

- `Don’t try on low end devices may freeze or interpolation takes ages`

- `Interpolation of long videos is NOT RECOMMENDED`
# 📋 Requirements
- [Termux](https://github.com/termux/termux-app/releases/download/v0.118.3/termux-app_v0.118.3+github-debug_arm64-v8a.apk)
- [TermuxAPI](https://github.com/termux/termux-api/releases/download/v0.53.0/termux-api-app_v0.53.0+github.debug.apk)
# 📦 Installation
- Open Termux and paste:
```bash
curl -fsSL https://raw.githubusercontent.com/MikuDroid/rife-ncnn-vulkan-termux/master/install.sh -o /tmp/rife-install.sh && bash /tmp/rife-install.sh
```
Type `rifevulkan` in Termux for video frame interpolation.
# Test
8X interpolation:

![Demo](./191.gif)

# Original RIFE Project
- [RIFE](https://github.com/hzwer/ECCV2022-RIFE)
- [RIFE-NCNN-VULKAN](https://github.com/nihui/rife-ncnn-vulkan)
