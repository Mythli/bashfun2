#!/bin/bash

# Check if a directory argument was provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 /path/to/your/video/files"
  exit 1
fi

# Get the video directory from the command-line argument
VIDEO_DIR="$1"

# Define the output directory for the MP3 and markdown files
OUTPUT_DIR="$1"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Your OpenAI API key
API_KEY="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"

# Output markdown file
MARKDOWN_FILE="$VIDEO_DIR/captions.md"

# Clear the markdown file content
> "$MARKDOWN_FILE"

# Loop through all video files in the directory
for video_file in "$VIDEO_DIR"/*; do
   # Get the file extension
  ext="${video_file##*.}"
  
  # Skip files with extensions .md or .mp3
  if [[ $ext == "md" || $ext == "mp3" ]]; then
    continue
  fi
  
  # Extract the filename without the extension
  base_name=$(basename "$video_file" | cut -d. -f1)

  # Convert video to MP3
  # Define the MP3 file path
  mp3_file="$VIDEO_DIR/$base_name.mp3"

  # Check if the MP3 file already exists
  if [ ! -f "$mp3_file" ]; then
    # Convert video to MP3
    ffmpeg -i "$video_file" -vn -ar 44100 -ac 2 -ab 192k -f mp3 "$mp3_file"
  else
    echo "MP3 file for $base_name already exists, skipping conversion."
  fi

  # Send the MP3 file to OpenAI for transcription
  response=$(curl -s https://api.openai.com/v1/audio/transcriptions \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: multipart/form-data" \
    -F file=@"$mp3_file" \
    -F model="whisper-1" \
    -F language="de")

  # Extract the 'text' property from the JSON response
  subtitle_text=$(echo "$response" | jq -r '.text')

  # Append the subtitles to the markdown file with the filename as a heading
  echo -e "# $base_name\n$subtitle_text\n" >> "$MARKDOWN_FILE"
done

echo "Subtitles have been written to markdown files in $OUTPUT_DIR."