# Set the root directory for the library
imgRootDir="${HOME}/Pictures/VL"

# Create the labels for the subfolder structure.
# ==============================================
# Labels are shorthands for the folders the images can be saved to.
# Each folder can have any amount of labels but they all must be unique.
# Labels are case-insensitive, so providing lowercase versions is sufficient.
# A sub-subfolder example: hd | home-deco ) imgFolder="/Home/Decoration/" ;;

case $(echo "$1" | tr '[:upper:]' '[:lower:]') in
  a | art ) imgFolder="/Art/" ;;
  b | br | brand ) imgFolder="/Brand/" ;;
  c | color ) imgFolder="/Color/" ;;
  f | fonts ) imgFolder="/Fonts/" ;;
  h | home ) imgFolder="/Home/" ;;
  i | il | illustration ) imgFolder="/Illustration/" ;;
  p | photo ) imgFolder="/Photo/" ;;
  s | style ) imgFolder="/Style/" ;;
  w | web ) imgFolder="/Web/"  ;;
  m | misc ) imgFolder="/Misc/" ;;
  * ) imgFolder="/Misc/"  
      osascript -e 'display notification "Image saved to a Misc folder" with title "Non-existing label"' ;;
esac

# Set the allowed file extensions
# ===========================
# The script performs a basic sanity check and issues a warning if the contents
# of the clipboard do not look like a direct URL to a file. The setting below
# allows to further restrict the check to the provided file types (case insensitive).
# Use ".*" to make the check pass for a link ending with any extension
allowedFileExtensions="jpg|jpeg|png|tiff|gif|bmp|svg|webp|tga|pdf|eps|psd|ai|indd|sketch|afdesign|pxm|acorn|cr2|nef|ico|icns|zip|rar"