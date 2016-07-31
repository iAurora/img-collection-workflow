#!/bin/bash


# Include the folders configuration script
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/vl-folders.sh"


# Get the URL from the clipboard
imgSrcURL=$(pbpaste)


urlPattern="^(https?|ftp|file).+(\.[a-z]+)$"

# test for regex match
# echo "http://unsplash.com/photos/gvLRWYcPEs4/download" | egrep "^(https?|ftp|file).+(\.[a-z]+)$"


if [[ "$imgSrcURL" =~ $urlPattern ]]
then 
    echo "Link valid"
else
    echo "Link not valid"
fi

# Get the URL of the frontmost window/tab in Safari
imgPageURL=$(osascript -e 'tell application "Safari" to set theURL to URL of front document')

# Get the title of the frontmost window/tab of Safari
imgPageTitle=$(osascript -e 'tell application "Safari" to set theTitle to name of front document')

# Get the extention of the linked image
imgExt=".${imgSrcURL##*.}"

# Generate the timestamp
imgDate=$(date '+%s')

# Get the 2nd provided argument as tags
imgTags="$2"


# Pick the title
#
# ~ Custom title option
# If argument 3 or 4 is provided and is longer than 3 characters, use it as a title for the saved image.
#
# Otherwise, use the title of the frontmost page in Safari
if [[ ${#3} -gt 3 && ${#4} -le 3 && -z $5 ]]; then
  imgTitle="$3"
elif [[ ${#4} -gt 3 && ${#3} -le 3 && -z $5 ]]; then
  imgTitle="$4"
elif [[ ${#3} -gt 3 && ${#4} -gt 3 || ${#3} -le 3 && ${#4} -le 3 || $5 ]]; then
   osascript -e 'display notification "The provided custom title doesn'"'"'t look right. Using the frontmost browser tab title instead." with title "Ooops!"'
  imgTitle="${imgPageTitle}"
else 
  imgTitle="${imgPageTitle}"
fi

# Compose the full filename
#
# ~ Retina handling
# If either of the arguments 3 or 4 equals "r", "R" or "@2x", append "@2x" to the end of the filename
# This makes Quick look show retina images sharper rather than larger
if [[ "$3" == [rR] || "$3" == "@2x" || "$4" == [rR] || "$4" == "@2x" ]]; then
  imgName="${imgTitle} ${imgDate} @2x${imgExt}"
else 
  imgName="${imgTitle} ${imgDate}${imgExt}"
fi

# Compose the absolute path for the file
imgPath=$imgRootDir$imgFolder$imgName


# Download the file
curl -o "${imgPath}" "${imgSrcURL}" || osascript -e 'display notification "Make sure the image URL is in the clipboard and a frontmost tab in Safari has an adequate title." with title "Failure!"' # && exit 0


# image optimization
if [[ "$imgExt" == .[jJ][pP]*[gG] ]]; then
  jpegtran -optimize -progressive -outfile "${imgPath}" "${imgPath}" || \
  osascript -e 'delay "4"' -e 'display notification "Something went wrong" with title "Optimisation failed"'
elif [[ "$imgExt" == .[pP][nN][gG] ]]; then
  optipng "${imgPath}" || \
  osascript -e 'display notification "Something went wrong" with title "Optimisation failed"'
elif [[ "$imgExt" == .[gG][iI][fF] ]]; then
  gifsicle --colors 256 -O3 "${imgPath}" -o "${imgPath}" || \
  osascript -e 'display notification "Something went wrong" with title "Optimisation failed"'
fi

tag -a "${imgTags}" "${imgPath}" || osascript -e 'display notification "Something went wrong" with title "Tagging failed"'

# Compose the Finder comment
imgComment="title: ${imgPageTitle}"$'\n\n'"page: ${imgPageURL}"$'\n\n'"url: ${imgSrcURL}"

osascript -e 'on run {f, c}' -e 'tell app "Finder" to set comment of (POSIX file f as alias) to c' -e end "${imgPath}" "${imgComment}"