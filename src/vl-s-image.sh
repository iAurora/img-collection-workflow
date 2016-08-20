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


# Get the extention of the linked file
fileExtension=".${resourceURL##*.}"

# Generate the timestamp
timeStamp=$(date '+%s')

# Set the default custom title
customTitle=""

# Set an empty retina suffix
retinaSuffix=""

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

    -r )    retinaSuffix=" @2x"
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


# Apply macOS tags to the file
/usr/local/bin/tag -a "${macTags}" "${filePath}" || osascript -e 'delay "0.5"' -e 'display notification "Something went wrong" with title "Tagging failed"'


# Add Finder comments
if $finderComments; then

  # Get the URL of the frontmost tab in Safari
  pageURL="$(osascript -e 'tell application "Safari" to set pageURL to URL of front document')"

  # Get the title of the frontmost tab of Safari
  pageTitle="$(osascript -e 'tell application "Safari" to set pageTitle to name of front document')"

  # Compose Finder Comments
  finderComments="title: ${pageTitle}"$'\n\n'"page: ${pageURL}"$'\n\n'"url: ${resourceURL}"

  # Apply Finder Comments
  osascript -e 'on run {f, c}' -e 'tell app "Finder" to set comment of (POSIX file f as alias) to c' -e end "${filePath}" "${finderComments}"

fi


# Confirm success
osascript -e 'delay "1"' -e 'display notification "All went well. Hopefully." with title "Job complete!"'