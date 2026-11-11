# RIFE-ncnn-vulkan for video interpolation

![Demo](./mqdefault.jpg)

## Notes
- If stuck at “Pick video from system…”, press Ctrl+C, launch the Termux:API app, return to Termux, and run `rifevulkan` again.
- Android 10 may not work.
- Low-end devices may freeze or take a long time to interpolate.
- Long videos are not recommended.
- This branch targets approximately 30 FPS input and outputs approximately 60 FPS with RIFE 2x. It accepts videos selected through Android's picker and always creates an MP4. Choose one of two fixed encoding variants; no CRF prompt is shown. CRF is quality-based and does not guarantee a particular file size.

## Requirements
- [Termux](https://github.com/termux/termux-app/releases/download/v0.118.3/termux-app_v0.118.3+github-debug_arm64-v8a.apk)
- [Termux:API](https://github.com/termux/termux-api/releases/download/v0.53.0/termux-api-app_v0.53.0+github.debug.apk)

## Installation
Open Termux and run:

```bash
curl -fsSL https://raw.githubusercontent.com/MikuDroid/rife-ncnn-vulkan-termux/master/install.sh | bash
```

Then run `rifevulkan` to select and interpolate a video. The installer preserves existing home files and stops instead of overwriting a repo directory with local changes. The temporary input copy is removed only after successful processing.

## Test
8x interpolation demo from the original project:

![Demo](./191.gif)

## Original projects
- [RIFE](https://github.com/hzwer/ECCV2022-RIFE)
- [RIFE-ncnn-vulkan](https://github.com/nihui/rife-ncnn-vulkan)
