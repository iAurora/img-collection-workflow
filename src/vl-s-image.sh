#!/bin/bash

# Source the configuration file
dir="${BASH_SOURCE%/*}"
if [[ ! -d "$dir" ]]; then dir="$PWD"; fi
. "$dir/vl-config.sh"

# Make sure all checks below are case-insensitive
shopt -s nocasematch


# Get the URL from the clipboard
resourceURL="$(pbpaste)"

# Trim the Dropbox download suffix if present
if [[ $resourceURL = *?dl=* ]]; then 
  resourceURL="${resourceURL%?dl=*}"
fi

# Make sure that $resourceURL contains an URL with an accepted file extension
checkPattern="^(https?|ftp|file).+(\.($acceptedFileTypes)+)$"

if [[ ! $resourceURL =~ $checkPattern ]]; then 
  osascript -e 'display notification "Make sure your clipboard contains a direct link to a file with one of the accepted extensions." with title "Unacceptable URL"'
  exit 1
fi


# Get the extention of the linked image
fileExtension=".${resourceURL##*.}"

# Generate the timestamp
timeStamp=$(date '+%s')


# Pick the title for the file (custom from arg 3/4 or default)
if [[ ${#3} -gt 3 && ${#4} -le 3 && -z $5 ]]; then
  fileTitle="${3} ${timeStamp}"

elif [[ ${#4} -gt 3 && ${#3} -le 3 && -z $5 ]]; then
  fileTitle="${4} ${timeStamp}"

elif [[ ${#3} -gt 3 && ${#4} -gt 3 || ${#3} -ge 1 && ${#3} -le 3 && ${#4} -ge 1 && ${#4} -le 3 || $5 ]]; then
  fileTitle="${timeStamp}"
  osascript -e 'display notification "The provided custom title doesn'"'"'t look right. Using the default title instead." with title "Ooops!"'

else fileTitle="${timeStamp}"

fi


# Compose the filename with retina option
if [[ "$3" =~ (r|2x|@2x) || "$4" =~ (r|2x|@2x) ]]; then
  fileName="${fileTitle} @2x${fileExtension}"

else 
  fileName="${fileTitle}${fileExtension}"
  
fi


# Compose the absolute path to the file
filePath=$rootDir$subDir$fileName

# Download the file
curl -o "${filePath}" "${resourceURL}"


# Check the download success status
if [[ $? -eq 1 ]]; then
 osascript -e 'delay "0.5"' -e 'display notification "Something is wrong with the file you are trying to download. Make sure the link is valid" with title "Failure!"'
 exit 1
fi


# Optimize the image if the type is jpg, png or gif
if $optimiseImages; then 

  optimisationError () { 
    osascript -e 'delay "0.5"' -e 'display notification "Something went wrong" with title "Optimisation failed"' 
  }

  if [[ "$fileExtension" == .jp*g ]]; then optimiseJPG

  elif [[ "$fileExtension" == .png ]]; then optimisePNG

  elif [[ "$fileExtension" == .gif ]]; then optimiseGIF

  fi

fi


# Get provided tags or set the default one
if [[ -n $2 ]]; then
  macTags="$2"
else
  macTags="untagged"
fi

# Apply macOS tags to the file
/usr/local/bin/tag -a "${macTags}" "${filePath}" || osascript -e 'delay "0.5"' -e 'display notification "Something went wrong" with title "Tagging failed"'


# Get the URL of the frontmost tab in Safari
pageURL="$(osascript -e 'tell application "Safari" to set pageURL to URL of front document')"

# Get the title of the frontmost tab of Safari
pageTitle="$(osascript -e 'tell application "Safari" to set pageTitle to name of front document')"

# Compose the Finder Comments
finderComments="title: ${pageTitle}"$'\n\n'"page: ${pageURL}"$'\n\n'"url: ${resourceURL}"

# Apply the Finder Comments
osascript -e 'on run {f, c}' -e 'tell app "Finder" to set comment of (POSIX file f as alias) to c' -e end "${filePath}" "${finderComments}"


# Confirm success
osascript -e 'delay "1"' -e 'display notification "All went well. Hopefully." with title "Job complete!"'