#!/bin/bash

# Source the configuration file
dir="${BASH_SOURCE%/*}"
if [[ ! -d "$dir" ]]; then dir="$PWD"; fi
. "$dir/vl-config.sh"

# Get the URL of the frontmost window/tab in Safari
imgPageURL="$(osascript -e 'tell application "Safari" to set theURL to URL of front document')"

# Get the title of the frontmost window/tab of Safari
imgPageTitle="$(osascript -e 'tell application "Safari" to set theTitle to name of front document')"

# Generate the timestamp
imgDate=$(date '+%s')

# Screenshot image extension
imgExt=".png"

# Get provided tags or set the default one
if [[ -n $2 ]]; then
  imgTags="$2"
else
  imgTags="untagged"
fi

# Set the title of the image
if [[ ${#3} -gt 3 && ${#4} -le 3 && -z $5 ]]; then
  imgTitle="$3"
elif [[ ${#4} -gt 3 && ${#3} -le 3 && -z $5 ]]; then
  imgTitle="$4"
elif [[ ${#3} -gt 3 && ${#4} -gt 3 || ${#3} -ge 1 && ${#3} -le 3 && ${#4} -ge 1 && ${#4} -le 3 || $5 ]]; then
   osascript -e 'display notification "The provided custom title doesn'"'"'t look right. Using the frontmost browser tab title instead." with title "Ooops!"'
  imgTitle="${imgPageTitle}"
else
  imgTitle="${imgPageTitle}"
fi

# Compose the full name for the file (with retina handling)
if [[ "$3" =~ (r|2x|@2x) || "$4" =~ (r|2x|@2x) ]]; then
  imgName="${imgTitle} ${imgDate} @2x${imgExt}"
else 
  imgName="${imgTitle} ${imgDate}${imgExt}"
fi

# Compose the absolute path for the file
imgPath=$imgRootDir$imgFolder$imgName

# Take an fullscreen screenshot
screencapture "${imgPath}"

# Optimize the image
/usr/local/bin/pngcrush -reduce -ow "${imgPath}" || \
  osascript -e 'delay "0.5"' -e 'display notification "Something went wrong" with title "Optimisation failed"'

# Apply macOS tags to the file
/usr/local/bin/tag -a "${imgTags}" "${imgPath}" || osascript -e 'delay "0.5"' -e 'display notification "Something went wrong" with title "Tagging failed"'

# Compose the Finder comment
imgComment="title: ${imgPageTitle}"$'\n\n'"page: ${imgPageURL}"

# Apply the Finder comment
osascript -e 'on run {f, c}' -e 'tell app "Finder" to set comment of (POSIX file f as alias) to c' -e end "${imgPath}" "${imgComment}"

# Confirm success
osascript -e 'display notification "All went well. Hopefully." with title "Job complete!"'