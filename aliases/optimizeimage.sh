#!/bin/bash

# Usage: ./convert_image.sh <image_path> --quality [quality] --dimensions [dimensions] --size [max_size_kb] [--no-optimize]

# Function to check if required commands are available
check_required_commands() {
    local commands=("magick" "jpegoptim" "cwebp" "pngquant" "pngcrush")
    for cmd in "${commands[@]}"; do
        command -v "$cmd" >/dev/null 2>&1 || { echo >&2 "$cmd is required but it's not installed. Aborting."; exit 1; }
    done
}

# Function to parse command-line arguments
parse_arguments() {
    optimize=true # Default is to optimize
    image_paths=() # Initialize array to hold image paths
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --quality)
                quality="$2"
                shift 2
                ;;
            --dimensions)
                dimensions="$2"
                shift 2
                ;;
            --size)
                max_size_kb="$2"
                shift 2
                ;;
            --no-optimize)
                optimize=false
                shift
                ;;
            *)
                image_paths+=("$1") # Add to image paths array
                shift
                ;;
        esac
    done
}

get_file_size() {
    local file_path="$1"
    local file_size

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS uses a different version of stat
        file_size=$(stat -f%z "$file_path")
    else
        # Linux and other Unix-like systems
        file_size=$(stat -c%s "$file_path")
    fi

    echo "$file_size"
}

# Function to create image files
create_images() {
    local input_file="$1"
    local initial_quality="$2"
    local dimensions="$3"
    local max_size_kb="$4"
    local max_size=$((max_size_kb * 1024)) # Convert KB to bytes

    # Get the file name without the extension and the directory path
    local filename_with_extension=$(basename -- "$input_file")
    local filename="${filename_with_extension%.*}"
    local directory=$(dirname -- "$input_file")

    # Function to adjust quality to meet max_size
    adjust_quality() {
        local output_file="$1"
        local file_type="$2"
        local current_quality="$3"
        local current_size



        current_size=$(get_file_size "$output_file")

        while [ "$current_size" -gt "$max_size" ]; do
            current_quality=$((current_quality - 5))
            if [ "$current_quality" -le 0 ]; then
                echo "Unable to meet size requirement for $file_type."
                return 1
            fi
            case "$file_type" in
                "JPG")
                    magick convert "$input_file" -resize "${dimensions}%" -quality "$current_quality" "$output_file"
                    ;;
                "WebP")
                    magick convert "$input_file" -resize "${dimensions}%" -quality "$current_quality" "$output_file"
                    ;;
                "PNG")
                    pngquant --force --quality="$current_quality" --output "$output_file" -- "$output_file"
                    ;;
            esac
            current_size=$(get_file_size "$output_file")
        done
        echo "$current_quality"
    }

    # Create and optimize JPG file with white background
    local output_jpg="${directory}/${filename}_${initial_quality}_${dimensions}.jpg"
    magick convert "$input_file" -background white -alpha remove -alpha off -resize "${dimensions}%" -quality "$initial_quality" "$output_jpg"
    if [ -n "$max_size_kb" ]; then
        final_quality=$(adjust_quality "$output_jpg" "JPG" "$initial_quality")
        if [ $? -eq 0 ]; then
            local new_output_jpg="${directory}/${filename}_${final_quality}_${dimensions}.jpg"
            mv "$output_jpg" "$new_output_jpg"
            output_jpg="$new_output_jpg"
        fi
    fi
    if [ "$optimize" = true ]; then
        jpegoptim "$output_jpg"
    fi
    echo "JPG file created: $output_jpg"

    # Create and optimize WebP file preserving transparency
    local output_webp="${directory}/${filename}_${initial_quality}_${dimensions}.webp"
    magick convert "$input_file" -resize "${dimensions}%" -quality "$initial_quality" "$output_webp"
    if [ -n "$max_size_kb" ]; then
        final_quality=$(adjust_quality "$output_webp" "WebP" "$initial_quality")
        if [ $? -eq 0 ]; then
            local new_output_webp="${directory}/${filename}_${final_quality}_${dimensions}.webp"
            mv "$output_webp" "$new_output_webp"
            output_webp="$new_output_webp"
        fi
    fi

    if [ "$optimize" = true ]; then
        echo "compressing!!!"
        cwebp "$output_webp" -o "$output_webp"
    fi

    # Create and optimize PNG file preserving transparency
    local output_png="${directory}/${filename}_${initial_quality}_${dimensions}.png"
    magick convert "$input_file" -resize "${dimensions}%" "$output_png"
    if [ -n "$max_size_kb" ]; then
        final_quality=$(adjust_quality "$output_png" "PNG" "$initial_quality")
        if [ $? -eq 0 ]; then
            local new_output_png="${directory}/${filename}_${final_quality}_${dimensions}.png"
            mv "$output_png" "$new_output_png"
            output_png="$new_output_png"
        fi
    fi

    if [ "$optimize" = true ]; then
        echo "YEAH"
        pngcrush "$output_png" "$output_png.tmp"
        rm "$output_png"
        cp "$output_png.tmp" "$output_png"
    fi

    echo "PNG file created: $output_png"
}

# Default values for quality and dimensions
quality=100
dimensions=100
max_size_kb=

# Check if required commands are available
check_required_commands

# Parse command-line arguments
parse_arguments "$@"

# Check if at least one image file is provided
if [ ${#image_paths[@]} -eq 0 ]; then
    echo "Please provide at least one path to an image file."
    exit 1
fi

# Process each image file
for image_path in "${image_paths[@]}"; do
    if [ -f "$image_path" ]; then
        # Create image files for each provided file path
        create_images "$image_path" "$quality" "$dimensions" "$max_size_kb"
    else
        echo "File $image_path does not exist."
    fi
done