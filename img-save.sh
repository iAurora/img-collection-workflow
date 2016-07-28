imgRootDir=$HOME/Pictures/Images
imgSrcURL=$(pbpaste)
imgExt=".${imgSrcURL##*.}"
imgDate=$(date '+%s')
imgPageURL=$(osascript -e 'tell application "Safari" to set theURL to URL of front document')
imgPageTitle=$(osascript -e 'tell application "Safari" to set theTitle to name of front document')
imgName="${imgPageTitle} ${imgDate}${imgExt}"
imgTags=$2
imgComment="title: ${imgPageTitle}"$'\n\n'"page: ${imgPageURL}"$'\n\n'"url: ${imgSrcURL}"

case $1 in
  [aA] | [aA][rR][tT] ) imgFolder="/Art/" ;;
  [bB] | [bB][rR][aA][nN][dD] ) imgFolder="/Brand/" ;;
  [cC] | [cC][oO][lL][oO][rR] ) imgFolder="/Color/" ;;
  [fF] | [fF][oO][nN][tT][sS] ) imgFolder="/Fonts/" ;;
  [hH] | [hH][oO][mM][eE] ) imgFolder="/Home/" ;;
  [iI] | [iI][lL][lL][uU][sS][tT][rR][aA][tT][iI][oO][nN] ) imgFolder="/Illustration/" ;;
  [pP] | [pP][hH][oO][tT][oO] ) imgFolder="/Photo/" ;;
  [sS] | [sS][tT][yY][lL][eE] ) imgFolder="/Style/" ;;
  [wW] | [wW][eE][bB] ) imgFolder="/Web/"  ;;
  [mM] | [mM][iI][sS][cC] ) imgFolder="/Misc/" ;;
  * ) imgFolder="/Misc/"  
      osascript -e 'display notification "Image saved to a Misc folder" with title "Wrong label"' ;;
esac

imgPath=$imgRootDir$imgFolder$imgName

curl -o "${imgPath}" "${imgSrcURL}" && osascript -e 'display notification "done" with title "Yep!"' || osascript -e 'display notification "Done" with title "Nope!"'

tag -a "${imgTags}" "${imgPath}"

osascript -e 'on run {f, c}' -e 'tell app "Finder" to set comment of (POSIX file f as alias) to c' -e end "${imgPath}" "${imgComment}"