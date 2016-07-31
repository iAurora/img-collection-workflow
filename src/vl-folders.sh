# Set the root directory for the visual library
imgRootDir="${HOME}/Pictures/Images"

# Create labels for the subfolder structure within the library root.
#
# Initial example accepts a single letter (must be unique) OR a full name 
# spelled in any combination of uppercase and lowercase letters.
#   a ) imgFolder="/Art/" ;;
#   art ) imgFolder="/Art/" ;;
#   Br ) imgFolder="/Brand/" ;;
# etc would be eqally acceptable but would require a more precise input.
#
# "Misc" is where images go if no label was provided or provided label does not exist.

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
      osascript -e 'display notification "Image saved to a Misc folder" with title "Non-existing label"' ;;
esac