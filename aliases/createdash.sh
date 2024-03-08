#!/bin/bash

# Check if an input file was specified
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

INPUT_FILE="$1"

# Check if the ffmpeg command is available
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg could not be found. Please install ffmpeg."
    exit 1
fi

# Get the input file name without the extension
INPUT_FILENAME=$(basename -- "$INPUT_FILE")
INPUT_NAME="${INPUT_FILENAME%.*}"

# Define the base output directory based on the input file name
BASE_OUTPUT_DIR="$(dirname "$INPUT_FILE")/${INPUT_NAME}_dash"

# Check if the base output directory exists and create a new one with an incremented suffix if necessary
OUTPUT_DIR="${BASE_OUTPUT_DIR}"
count=1
while [ -d "${OUTPUT_DIR}" ]; do
    OUTPUT_DIR="${BASE_OUTPUT_DIR}_${count}"
    ((count++))
done

# Create the output directory
mkdir -p "${OUTPUT_DIR}"

# Create a subdirectory for DASH files
DASH_DIR="${OUTPUT_DIR}/dash"
mkdir -p "${DASH_DIR}"

# Define an array of resolutions
declare -a resolutions=("640x360" "1280x720" "1920x1080")

# Loop through each resolution and create a corresponding video file
for resolution in "${resolutions[@]}"; do
    # Extract width and height
    IFS='x' read -r width height <<< "$resolution"

    # Output file name based on resolution
    output_file="${OUTPUT_DIR}/${width}x${height}.mp4"

    echo "Creating ${output_file} with crf 22 and slowest preset..."

    # Run ffmpeg to convert the input file to the desired resolution using the scale filter
    # and compress the video with the slowest preset and crf 22
    ffmpeg -i "${INPUT_FILE}" -vf "scale=${width}:${height}" -preset slower -crf 22 \
           -c:v libx264 -b:v 1000k -keyint_min 150 -g 150 -sc_threshold 0 \
           -c:a aac -b:a 128k -ar 48000 -ac 2 -f mp4 "${output_file}"
done

# Generate the DASH manifest and segments
MPD_FILE="${DASH_DIR}/${INPUT_NAME}.mpd"

# Ensure that the -map options correctly map video and audio streams to the adaptation sets
ffmpeg -i "${OUTPUT_DIR}/640x360.mp4" -i "${OUTPUT_DIR}/1280x720.mp4" -i "${OUTPUT_DIR}/1920x1080.mp4" \
-map 0:v -map 1:v -map 2:v -map 0:a -map 1:a -map 2:a \
-c copy -use_timeline 1 -use_template 1 \
-adaptation_sets "id=0,streams=v id=1,streams=a" -f dash "${MPD_FILE}"

echo "DASH content created at ${DASH_DIR}"