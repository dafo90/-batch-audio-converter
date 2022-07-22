#!/bin/bash

#abort on error
set -e

function usage
{
    echo "usage: batch-audio-converter -i INPUT_FOLDER [-q CONVERSION_QUALITY || -h]"
    echo "   ";
    echo "  -i | --input             : Input folder which contains audio files";
    echo "  -q | --quality           : Quality of the output mp3 songs (default '192k')";
    echo "  -h | --help              : This message";
}

function parse_args
{
  # positional args
  args=()

  # named args
  while [ "$1" != "" ]; do
      case "$1" in
          -i | --input )                input="$2";              shift;;
          -q | --quality )              quality="$2";            shift;;
          -h | --help )                 usage;                   exit;; # quit and show usage
          * )                           args+=("$1")             # if no match, add it to the positional args
      esac
      shift # move to next kv pair
  done

  # restore positional args
  set -- "${args[@]}"

  # set positionals to vars
  positional_1="${args[0]}"

  # validate required args
  if [[ -z "${input}" ]]; then
      echo "Invalid arguments"
      usage
      exit;
  fi

  # set defaults
  if [[ -z "$quality" ]]; then
      quality="256k";
  fi
}

function run
{
  parse_args "$@"
  echo "Input folder: $input"
  echo "Quality: $quality"

  find $input -iname '*.m4a' -type f | while read line; do
    filename="${line%.*}"
    echo "Convert file '$filename'..."
    convertFrom=$line
    #convertTo=$(echo "$filename.mp3" | sed 's/\ /\\ /g')
    convertTo="$filename.mp3"
    #echo "Convert to '$convertTo'..."
    < /dev/null ffmpeg -loglevel panic -y -i "${convertFrom}" -acodec libmp3lame -ab $quality "${convertTo}"
    rm -rf "${convertFrom}"
  done
}

run "$@";
