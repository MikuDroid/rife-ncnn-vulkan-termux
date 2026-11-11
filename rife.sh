#!/bin/bash
export LD_LIBRARY_PATH=/system/lib64:$LD_LIBRARY_PATH

SUCCESS=0
TMPFILE="__input.tmp"
INPUT=""
TMPVID="__tmpvid.mp4"
cleanup() {
  rm -f "$TMPFILE" "$TMPVID"
  [ "$SUCCESS" -eq 1 ] && [ -n "$INPUT" ] && rm -f "$INPUT"
  rm -rf frames tmp out
}
trap cleanup EXIT
trap 'exit 1' INT TERM

echo "Pick video from system... (Ctrl+C to cancel)"
rm -f "$TMPFILE"
termux-storage-get "$TMPFILE" &
while [ ! -f "$TMPFILE" ]; do sleep 1; done
sleep 1

while true; do
  echo -n "Enter output name (no extension): "
  read NAME
  [[ -n "$NAME" ]] || { echo "Name cannot be empty." >&2; continue; }
  INPUT="${NAME}.source"
  DEST="/sdcard/rifevulkan/${NAME}_x2.mp4"
  if [ -e "$INPUT" ] || [ -e "$DEST" ]; then
    echo -e "\e[33mWarning: '${NAME}' already exists; choose a different name.\e[0m"
  else
    break
  fi
done
mv "$TMPFILE" "$INPUT"

# Fixed 2x workflow: approximately 30 FPS input to approximately 60 FPS output.
FPS=$(ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate -of default=nw=1:nk=1 "$INPUT")
[[ "$FPS" =~ ^([0-9]+)/([0-9]+)$ ]] || { echo "Could not determine a valid input frame rate: $FPS" >&2; exit 1; }
NUM=${BASH_REMATCH[1]}
DEN=${BASH_REMATCH[2]}
(( DEN > 0 )) || { echo "Invalid input frame-rate denominator: $DEN" >&2; exit 1; }
if ! awk -v n="$NUM" -v d="$DEN" 'BEGIN { f=n/d; exit !(f>=29 && f<=31) }'; then
  echo "This script expects approximately 30 FPS input to produce approximately 60 FPS. Detected: $FPS" >&2
  exit 1
fi
NEWFPS="$((NUM * 2))/$DEN"
HAS_AUDIO=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$INPUT")

printf "\nInput: ~%s FPS; output: ~%s FPS (RIFE 2x)\n" "$FPS" "$NEWFPS"
echo "Output is MP4. Choose an encoding preset:"
echo "1) H.265, CRF 24, medium — smaller output; requires HEVC playback support [default]"
echo "2) H.264, CRF 22, slow — broader compatibility; may be larger"
read -r -p "Encoder [1/2]: " ENCODE_MODE
[ -z "$ENCODE_MODE" ] && ENCODE_MODE=1
case "$ENCODE_MODE" in
  1) VCODEC=libx265; CRF=24; PRESET=medium; EXTRA=(-tag:v hvc1) ;;
  2) VCODEC=libx264; CRF=22; PRESET=slow; EXTRA=() ;;
  *) echo "Invalid encoder choice." >&2; exit 1;;
esac

printf "\nOutput: %s\nEncoder: %s -preset %s -crf %s\nAudio: %s\n" "$DEST" "$VCODEC" "$PRESET" "$CRF" "${HAS_AUDIO:-none}"
echo "CRF is preset by the selected variant; it is quality-based, not a hard size limit."

rm -rf frames tmp out
mkdir -p frames tmp out

echo "Extracting and normalizing source frames..."
if ! ffmpeg -i "$INPUT" -vf "fps=$FPS" -fps_mode passthrough frames/%08d.png; then
  echo "Frame extraction failed." >&2
  exit 1
fi
if ! find frames -maxdepth 1 -type f -name '*.png' -print -quit | grep -q .; then
  echo "No frames were extracted; stopping before interpolation." >&2
  exit 1
fi
cp frames/*.png tmp/

mkdir out
echo "RIFE GPU interpolation: 2x..."
if ! ./rife-ncnn-vulkan -i tmp -o out -m rife-v4.6; then
  echo "Interpolation failed." >&2
  exit 1
fi
if ! find out -maxdepth 1 -type f -name '*.png' -print -quit | grep -q .; then
  echo "RIFE produced no frames; stopping before encoding." >&2
  exit 1
fi

echo "Encoding MP4..."
if ! ffmpeg -framerate "$NEWFPS" -pattern_type glob -i "out/*.png" \
  -c:v "$VCODEC" -preset "$PRESET" -crf "$CRF" "${EXTRA[@]}" \
  -pix_fmt yuv420p -r "$NEWFPS" -an -movflags +faststart "$TMPVID"; then
  echo "Video encoding failed." >&2
  exit 1
fi

mkdir -p /sdcard/rifevulkan
if [ -n "$HAS_AUDIO" ]; then
  echo "Muxing original audio into MP4..."
  if ! ffmpeg -i "$TMPVID" -i "$INPUT" -map 0:v:0 -map 1:a:0 \
    -c:v copy -c:a copy -movflags +faststart "$DEST"; then
    echo "Audio muxing failed." >&2
    exit 1
  fi
  rm -f "$TMPVID"
else
  mv "$TMPVID" "$DEST"
fi

SUCCESS=1
termux-media-scan "$DEST"
echo -e "\e[32mDone: $DEST\e[0m"
