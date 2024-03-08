#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 -f response_format -l language glob_pattern"
  echo "  -f  Response format for transcription (default: vtt)"
  echo "  -l  Language for transcription (default: en)"
  echo "  glob_pattern  Glob pattern to match files (required)"
  exit 1
}

# Default values for optional arguments
response_format="vtt"
language="en"

# Parse command-line options
while getopts "f:l:h" opt; do
  case $opt in
    f) response_format="$OPTARG" ;;
    l) language="$OPTARG" ;;
    h) usage ;;
    ?) usage ;;
  esac
done

# Remove the options from the positional parameters
shift $((OPTIND - 1))

# Check if the glob pattern argument was provided
if [ "$#" -ne 1 ]; then
  echo "Error: Glob pattern not specified."
  usage
fi

# The glob pattern is the last argument
glob_pattern="$1"

# Your OpenAI API key
API_KEY="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"

# Loop through all files matching the glob pattern
shopt -s nullglob
for video_file in $glob_pattern; do
  # Get the file extension
  ext="${video_file##*.}"
  
  # Skip files with extensions .md or .mp3
  if [[ $ext == "md" || $ext == "mp3" ]]; then
    continue
  fi
  
  # Extract the filename without the extension
  base_name=$(basename "$video_file" | cut -d. -f1)

  # Define the output directory based on the video file's directory
  OUTPUT_DIR=$(dirname "$video_file")

  # Convert video to MP3
  # Define the MP3 file path
  mp3_file="$OUTPUT_DIR/$base_name.mp3"

  # Check if the MP3 file already exists
  if [ ! -f "$mp3_file" ]; then
    # Convert video to MP3
    ffmpeg -i "$video_file" -vn -ar 44100 -ac 2 -ab 192k -f mp3 "$mp3_file"
  else
    echo "MP3 file for $base_name already exists, skipping conversion."
  fi

  # Send the MP3 file to OpenAI for transcription
  curl -s https://api.openai.com/v1/audio/transcriptions \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: multipart/form-data" \
    -F file=@"$mp3_file" \
    -F model="whisper-1" \
    -F response_format="$response_format" \
    -F language="$language" >> "$OUTPUT_DIR/$base_name.$response_format"
done

echo "Transcriptions have been written to files in the respective directories."