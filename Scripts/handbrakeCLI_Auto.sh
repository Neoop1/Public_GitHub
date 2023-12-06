#!/bin/bash
# Batch convert videos with HandBrake CLI
# By Ralph Crisostomo - 2016.04.17
#
#    'sudo apt install ffmpeg'
#     'sudo apt install HandBrakeCLI'
# Usage :
#   'sudo ./handbrake.sh /source /destination'
#
# Reference :
#   https://forum.handbrake.fr/viewtopic.php?f=6&t=19426
#   https://gist.github.com/czj/1263872
#   https://trac.handbrake.fr/wiki/BuiltInPresets#universal
# 
#SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SOURCE=$1

##Logs

#[[ -d $(pwd -P)/logs ]] || mkdir -p $(pwd -P)/logs
[[ -d $(pwd -P)/logs ]] || mkdir -p ./logs
#find "$(pwd -P)" -type f -name "*.mp4" > $(pwd -P)/logs/Video_Files.txt
#find "$SOURCE" \( -iname '*.mp4' -or -iname '*.avi'  -or -iname '*.mkv' -or -iname '*.mts' \) >> $(pwd -P)/logs/Video_Files.txt
find "$SOURCE" \( -iname '*.mp4' -or -iname '*.avi'  -or -iname '*.mkv' -or -iname '*.mts' \) > ./logs/Video_Files.txt
find "$SOURCE" \( -iname '*.mp4' -or -iname '*.avi'  -or -iname '*.mkv' -or -iname '*.mts' \)  -print  -exec ffprobe -show_entries format=duration -v quiet -of csv="p=1" {} \; > ./logs/Time_before.txt


# Universal
# ref: https://trac.handbrake.fr/wiki/BuiltInPresets#universal
#
PRESET="Fast1080p30"


while IFS= read -d '' -r ITEM
do
  
  

  echo "$ITEM"
  #DESTINATION=./HandBrake"$(dirname "$(readlink -f "$ITEM")")"
  DESTINATION=~/HandBrake"/$(dirname  "$ITEM")"

  FILE=${ITEM##*/}
  EXT=${ITEM##*.}
  EXT=$(echo $EXT | tr "[:upper:]" "[:lower:]")
  OUTPUT="$DESTINATION/${FILE%.*}.$EXT"
  
  # Create directory
  [[ -d "$DESTINATION" ]] || mkdir -p "$DESTINATION"
  #echo "" | HandBrakeCLI -i "$ITEM" -o "$OUTPUT" $PRESET | tee 1>>$(pwd -P)/logs/success.log 2>>$(pwd -P)/logs/failed.log

  echo "" | HandBrakeCLI -i "$ITEM" -o "$OUTPUT" $PRESET  1>> ./logs/Fulllog.log 2>> ./logs/err.log | tee ./logs/Fulllog.log
  
  #Time_Log 
  #find "$(pwd -P)" -type f -name "*.mp4"  -print0  -exec ffprobe -show_entries format=duration -v quiet -of csv="p=1" {} \; > $(pwd -P)/logs/beforeTime.txt
  #find "$DESTINATION" -type f -name "*.mp4"  -print  -exec ffprobe -show_entries format=duration -v quiet -of csv="p=1" {} \; >> ./logs/Time_after.txt

  #find "$OUTPUT" -type f -name "*.mp4"  -print0  -exec ffprobe -show_entries format=duration -v quiet -of csv="p=1" {} \; >> ./logs/Time_after.txt
  
  find "$(readlink -f "$ITEM")" \( -iname '*.mp4' -or -iname '*.avi'  -or -iname '*.mkv' -or -iname '*.mts' \)  -print0  -exec ffprobe -show_entries format=duration -v quiet -of csv="p=1" {} \; >> "$DESTINATION"/"$FILE".log
  find "$OUTPUT" \( -iname '*.mp4' -or -iname '*.avi'  -or -iname '*.mkv' -or -iname '*.mts' \) -print0  -exec ffprobe -show_entries format=duration -v quiet -of csv="p=1" {} \; >> "$DESTINATION"/"$FILE".log
  

  # echo "$(readlink -f "$ITEM")"
  OriginalFile=`ffprobe -i "$(readlink -f "$ITEM")" -show_entries format=duration -v quiet -of csv="p=0" | xargs `
  OutputFile=`ffprobe -i "$OUTPUT" -show_entries format=duration -v quiet -of csv="p=0" | xargs `
  
  export T1=$OriginalFile
  export T2=$OutputFile

  echo "$OriginalFile"
  echo "$OutputFile"


   TIME1=$(printf "%.0f" $T1)
   TIME2=$(printf "%.0f" $T2)
  
    #echo $TIME1
    #echo $TIME2

       if [[ "$TIME1" -ne "$TIME2" ]]; then  
         echo "Time Error!"
       else
         echo "Time ok!"
       fi
  

  #echo $(realpath "$ITEM")

  #echo "$(dirname  "$ITEM")"
  




done< <(find "$SOURCE" \( -iname '*.mp4' -or -iname '*.avi'  -or -iname '*.mkv' -or -iname '*.mts' \) -print0)


