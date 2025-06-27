#!/bin/bash

# Check required commands
for cmd in amdgpu_top jq; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "{\"error\": \"$cmd command not found\"}"
    exit 1
  fi
done

# Get amdgpu_top JSON output
INFO=$(amdgpu_top -d -J 2>/dev/null)

if [[ -z "$INFO" ]]; then
  echo '{"error": "Failed to retrieve amdgpu_top info"}'
  exit 1
fi

# Extract VRAM used and total (MiB)
VRAM_USED=$(echo "$INFO" | jq -r '.[0].VRAM["Total VRAM Usage"].value // empty')
VRAM_TOTAL=$(echo "$INFO" | jq -r '.[0].VRAM["Total VRAM"].value // empty')

# Extract overall GPU usage (%) — GFX usage
GPU_UTIL=$(echo "$INFO" | jq -r '.[0].gpu_activity.GFX.value // empty')

# Validate extracted values
if [[ -z "$VRAM_USED" || -z "$VRAM_TOTAL" || -z "$GPU_UTIL" ]]; then
  echo '{"error": "Failed to parse VRAM or GPU usage"}'
  exit 1
fi

format_gb() {
  local val=$1
  # If val starts with '.', prepend '0'
  if [[ $val == .* ]]; then
    echo "0$val"
  else
    echo "$val"
  fi
}


VRAM_USED_GB=$(echo "scale=1; $VRAM_USED / 1024" | bc)
VRAM_USED_GB=$(format_gb "$VRAM_USED_GB")

VRAM_TOTAL_GB=$(echo "scale=1; $VRAM_TOTAL / 1024" | bc)
VRAM_TOTAL_GB=$(format_gb "$VRAM_TOTAL_GB")

# Output JSON with VRAM usage and GPU usage percentage
echo "GPU:$GPU_UTIL% VRAM:$VRAM_USED_GB/$VRAM_TOTAL_GB GB"
