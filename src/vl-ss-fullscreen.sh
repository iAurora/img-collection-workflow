#!/bin/bash

# Source the configuration file
dir="${BASH_SOURCE%/*}"
if [[ ! -d "$dir" ]]; then dir="$PWD"; fi
. "$dir/vl-config.sh"

# Make sure all checks below are case-insensitive
shopt -s nocasematch


# Screenshot image extension
fileExtension=".png"

# Generate the timestamp
timeStamp=$(date '+%s')

# Set the retina suffix
if $retinaMode; then
  retinaSuffix=" @2x"
else
  retinaSuffix=""
fi

# Set the default tag
macTags="untagged"

# Set the default Finder comments status
finderComments=true


# Process the supplied options
while [ "$1" != "" ]; do
  case $1 in
    '@'* )  folderLabel="${1#@}"
            ;;

    '+'* )  macTags="${1#+}"
            ;;

    -t )    shift
            customTitle="$1 "
            ;;

    -c )    finderComments=false
            ;;
            
    * )     osascript -e 'display notification "One or more of the provided options doesn'"'"'t look right. Using the defaults instead." with title "Ooops!"'
  esac
  shift
done


# Call the "label > subdir" mapping function from the config
setDestinationDir

# Compose the full filename
fileName="${customTitle}${timeStamp}${retinaSuffix}${fileExtension}"

# Compose the absolute path to the file
filePath=$rootDir$subDir$fileName


# Take an interactive screenshot
screencapture "${filePath}"


# Optimize the image
if $optimiseImages; then 

  optimisationError () { 
    osascript -e 'delay "0.5"' -e 'display notification "Something went wrong" with title "Optimisation failed"' 
  }

  optimisePNG

fi


# Apply macOS tags to the file
/usr/local/bin/tag -a "${macTags}" "${filePath}" || osascript -e 'delay "0.5"' -e 'display notification "Something went wrong" with title "Tagging failed"'


# Add Finder comments
if $finderComments; then

  # Get the URL of the frontmost tab in Safari
  pageURL="$(osascript -e 'tell application "Safari" to set pageURL to URL of front document')"

  # Get the title of the frontmost tab of Safari
  pageTitle="$(osascript -e 'tell application "Safari" to set pageTitle to name of front document')"

  # Compose Finder Comments
  finderComments="title: ${pageTitle}"$'\n\n'"page: ${pageURL}"

  # Apply Finder Comments
  osascript -e 'on run {f, c}' -e 'tell app "Finder" to set comment of (POSIX file f as alias) to c' -e end "${filePath}" "${finderComments}"

fi


# Confirm success
osascript -e 'display notification "All went well. Hopefully." with title "Job complete!"'