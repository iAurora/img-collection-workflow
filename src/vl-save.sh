#!/bin/bash

# Source the configuration file
dir="${BASH_SOURCE%/*}"
if [[ ! -d "$dir" ]]; then dir="$PWD"; fi
. "$dir/vl-config.sh"

# Make sure all checks below are case-insensitive
shopt -s nocasematch

# Get the URL from the clipboard
imgSrcURL="$(pbpaste)"

# Trim the Dropbox download suffix if present
if [[ $imgSrcURL = *?dl=* ]]; then 
  imgSrcURL="${imgSrcURL%?dl=*}"
fi

# URL validation pattern
urlPattern="^(https?|ftp|file).+(\.($allowedFileExtensions)+)$"

# URL validation check
if [[ ! $imgSrcURL =~ $urlPattern ]]; then 
  osascript -e 'display notification "Make sure your clipboard contains a direct link to a file with one of the accepted extensions." with title "Unacceptable URL"'
  exit 1
fi

# Get the URL of the frontmost window/tab in Safari
imgPageURL="$(osascript -e 'tell application "Safari" to set theURL to URL of front document')"

# Get the title of the frontmost window/tab of Safari
imgPageTitle="$(osascript -e 'tell application "Safari" to set theTitle to name of front document')"

# Get the extention of the linked image
imgExt=".${imgSrcURL##*.}"

# Generate the timestamp
imgDate=$(date '+%s')

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

# Download the file
curl -o "${imgPath}" "${imgSrcURL}"

# Download success check
if [[ $? -eq 1 ]]; then
 osascript -e 'display notification "Something is wrong with the file you are trying to download. Make sure the link is valid" with title "Failure!"'
 exit 1
fi

# Optimize the image if the type is jpg, png or gif
if [[ "$imgExt" == .jp*g ]]; then
  jpegtran -optimize -progressive -outfile "${imgPath}" "${imgPath}" || \
  osascript -e 'delay "3"' -e 'display notification "Something went wrong" with title "Optimisation failed"'
elif [[ "$imgExt" == .png ]]; then
  optipng "${imgPath}" || \
  osascript -e 'delay "3"' -e 'display notification "Something went wrong" with title "Optimisation failed"'
elif [[ "$imgExt" == .gif ]]; then
  gifsicle --colors 256 -O3 "${imgPath}" -o "${imgPath}" || \
  osascript -e 'delay "3"' -e 'display notification "Something went wrong" with title "Optimisation failed"'
fi

# Apply macOS tags to the file
tag -a "${imgTags}" "${imgPath}" || osascript -e 'delay "3"' -e 'display notification "Something went wrong" with title "Tagging failed"'

# Compose the Finder comment
imgComment="title: ${imgPageTitle}"$'\n\n'"page: ${imgPageURL}"$'\n\n'"url: ${imgSrcURL}"

# Apply the FInder comment
osascript -e 'on run {f, c}' -e 'tell app "Finder" to set comment of (POSIX file f as alias) to c' -e end "${imgPath}" "${imgComment}"