#!/bin/bash

# set root directory for the image collection
imgRootDir="${HOME}/Pictures/Images"

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/folders.sh"

# store the URL of the image contained in the clipboard
imgSrcURL=$(pbpaste)

# get the URL of the frontmost window/tab in Safari
imgPageURL=$(osascript -e 'tell application "Safari" to set theURL to URL of front document')
imgPageTitle=$(osascript -e 'tell application "Safari" to set theTitle to name of front document')
imgExt=".${imgSrcURL##*.}"
imgDate=$(date '+%s')
imgTags="$2"
imgRes="$3"

# if arg3 or arg4 are longer than 3 chars, use them for the title
# otherwise, use the title of the frontmost page in Safari
if [[ ${#3} -gt 3 ]]; then
  imgTitle="$3"
elif [[ ${#4} -gt 3 ]]; then
  imgTitle="$4"
else 
  imgTitle="${imgPageTitle}"
fi

# retina handling
if [[ "$3" == [rR] || "$3" == "2" || "$3" == "@2x" || "$4" == [rR] || "$4" == "2" || "$4" == "@2x" ]]; then
  imgName="${imgTitle} ${imgDate} @2x${imgExt}"
else 
  imgName="${imgTitle} ${imgDate}${imgExt}"
fi

imgComment="title: ${imgPageTitle}"$'\n\n'"page: ${imgPageURL}"$'\n\n'"url: ${imgSrcURL}"

imgPath=$imgRootDir$imgFolder$imgName

# download to a chosen folder with an assigned name
curl -o "${imgPath}" "${imgSrcURL}" && osascript -e 'display notification "done" with title "Yep!"' || osascript -e 'display notification "Done" with title "Nope!"'

# image optimization
if [[ "$imgExt" == .[jJ][pP]*[gG] ]]; then
  jpegtran -optimize -progressive -outfile "${imgPath}" "${imgPath}" || \
  osascript -e 'display notification "Something went wrong" with title "Optimisation failed"'
elif [[ "$imgExt" == .[pP][nN][gG] ]]; then
  optipng "${imgPath}" || \
  osascript -e 'display notification "Something went wrong" with title "Optimisation failed"'
elif [[ "$imgExt" == .[gG][iI][fF] ]]; then
  gifsicle --colors 256 -O3 "${imgPath}" -o "${imgPath}" || \
  osascript -e 'display notification "Something went wrong" with title "Optimisation failed"'
fi

tag -a "${imgTags}" "${imgPath}" || osascript -e 'display notification "Something went wrong" with title "Tagging failed"'

osascript -e 'on run {f, c}' -e 'tell app "Finder" to set comment of (POSIX file f as alias) to c' -e end "${imgPath}" "${imgComment}"