#!/usr/bin/env bash

set -eo pipefail

movs_dir=$1
pro_res_dir=$2
quality=$3

# Check for ffmpeg and show version
if command -v ffmpeg &> /dev/null
then
    echo "Found ffmpeg: $(ffmpeg -version | head -n1)"

    sleep 1
else
    echo "Error: ffmpeg is not installed or not in PATH"

    echo "Install with:"
    
    echo "  macOS: brew install ffmpeg"
    echo "  Ubuntu/Debian: sudo apt install ffmpeg"
    echo "  RHEL/Fedora: sudo dnf install ffmpeg"
    
    exit 1
fi

if [[ "$quality" == "422HQ" ]]
then
    quality="3"

    echo "Preparing to convert to ProRes 422 HQ: ~700 Mbps @ 4k"

    sleep 2
elif [[ "$quality" == "422" ]]
then
    quality="2"

    echo "Preparing to convert to ProRes 422: ~470 Mbps @ 4k"

    sleep 2
else
    echo "Error: quality (the third argument) must be 422 or 422HQ"

    exit 1
fi

# Check if directories exist
if [ ! -d "$movs_dir" ]
then
    echo "Error: MOV directory '$movs_dir' does not exist"

    exit 1
fi

if [ ! -d "$pro_res_dir" ]
then
    echo "Creating ProRes directory: $pro_res_dir"

    mkdir -p "$pro_res_dir"
fi

# Count total video files (MOV and MP4)
total_files=$(find "$movs_dir" -maxdepth 1 \( -name "*.MOV" -o -name "*.mov" -o -name "*.MP4" -o -name "*.mp4" \) | wc -l)

if [ "$total_files" -eq 0 ]
then
    echo "No video files (.MOV or .MP4) found in $movs_dir"

    exit 1
fi

echo "Found $total_files video files to convert"

current=0

# Loop through all video files in the directory
for video_file in "$movs_dir"/*.MOV "$movs_dir"/*.mov "$movs_dir"/*.MP4 "$movs_dir"/*.mp4
do
    # Skip if no files match the pattern
    [ -e "$video_file" ] || continue
    
    current=$((current + 1))
    
    # Extract filename without path and extension
    filename=$(basename "$video_file")

    name_without_ext="${filename%.*}"
    
    output_file="$pro_res_dir/${name_without_ext}_PRORES.MOV"
    
    echo "[$current/$total_files] Converting: $filename"
    
    # Convert to ProRes
    if ffmpeg -i "$video_file" \
        -c:v prores_ks \
        -profile:v $quality \
        -pix_fmt yuv422p10le \
        -c:a pcm_s24le \
        -map_metadata 0 \
        -movflags use_metadata_tags \
        "$output_file" -y
    then
        # Preserve both creation and modification dates
        if [[ "$OSTYPE" == "darwin"* ]]
        then
            echo "---"

            # macOS - preserve both dates
            # Method 1: Using SetFile (if Xcode tools installed)
            if command -v SetFile &> /dev/null
            then
                SetFile -d "$(GetFileInfo -d "$video_file")" "$output_file"

                SetFile -m "$(GetFileInfo -m "$video_file")" "$output_file"

                echo "Original Creation and Modification dates preserved using SetFile"
            else
                # Method 2: Using touch and xattr
                touch -r "$video_file" "$output_file"  # Copies modification time
                
                # Try to preserve creation date using xattr
                creation_date=$(stat -f "%SB" -t "%Y%m%d%H%M.%S" "$video_file")
                
                touch -t "$creation_date" "$output_file"

                # Reset modification time after
                touch -r "$video_file" "$output_file"

                echo "Original Creation and Modification dates preserved using touch and xattr"
            fi
        elif [[ "$OSTYPE" == "linux"* ]]
        then
            echo "---"
            
            # Linux - at least preserve modification time
            touch -r "$video_file" "$output_file"

            echo "Original Modification date preserved!"
        fi

        echo "Successfully converted: $filename -> ${name_without_ext}_PRORES.MOV"

        sleep 1
    else
        echo "Failed to convert: $filename"
    fi
    echo ""
done

echo "Conversion complete! Processed $current files."
