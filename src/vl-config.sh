# Set the root directory for the library
rootDir="${HOME}/Pictures/VL"

# Create the labels for the subfolder structure.
# ==============================================
# Labels are shorthands for the folders the images can be saved to.
# Each folder can have any amount of labels (separated by "|" ) but they all must be unique.
# Labels are case-insensitive, so providing lowercase versions is sufficient.
# A sub-subfolder example: hd | hmd | home-deco ) subDir="/Home/Decoration/" ;;

setDestinationDir () {
  case $folderLabel in
    a | art ) subDir="/Art/" ;;
    b | brand ) subDir="/Brand/" ;;
    c | color ) subDir="/Color/" ;;
    f | fonts ) subDir="/Fonts/" ;;
    h | home ) subDir="/Home/" ;;
    i | illustration ) subDir="/Illustration/" ;;
    p | photo ) subDir="/Photo/" ;;
    s | style ) subDir="/Style/" ;;
    w | web ) subDir="/Web/"  ;;
    m | misc ) subDir="/Misc/" ;;
    * ) subDir="/Misc/"  
        osascript -e 'display notification "Image saved to a Misc folder" with title "Non-existing label"' ;;
  esac
}

# Set the accepted file extensions for web image downloads
# ===========================
# The script performs a basic sanity check and issues a warning if the contents
# of the clipboard do not look like a direct URL to a file. The setting below
# allows to further restrict the check to the provided file types (case insensitive).
# Use ".*" to make the check pass for a link ending with any extension
acceptedFileTypes="jpg|jpeg|png|tiff|gif|bmp|svg|webp|tga|pdf|eps|psd|ai|indd|sketch|afdesign|pxm|acorn|cr2|nef|ico|icns|zip|rar"

# Retina handling
# ===============
# On retina macs Quick Look displays the images at the size they would appear on the non-retina screens,
# which is ok for most photos but causes problems with the 2x-sized screenshots of the UI elements, 
# particularly when those screenshots were not taken on the mac itself (web downloads for example).
# Adding a "@2x" suffix to the end of the filename forces Quick Look to display the image in the retina mode.
# For image downloads using "-r" option adds the suffux to the particular image's filename.
# The setting below adds the suffix to all screenshots created on the local machine.
# The value for non-retina machines should be set to 'false'.
retinaMode=true

# Set the default width for the full page screenshots
defaultWidth=1280

# Set the widths for the responsive page screenshots
# ==================================================
# There's no limit on the number of widths but too many will make the proccess painfully slow.
# The first width in the list will be used for the primary screenshot.
responsiveWidths=( 1280 1600 768 320 )

# Turn image optimisation on and off.
# ===================================
# Turning it off will make jpegtran, pngcrush and gifsicle dependencies unnecessary.
# It will also speed up the saving proccess but images will occupy more space on a disk.
# Use "false" for turning the optimisation off.
optimiseImages=true

# Adjust optimisation settings.
# =============================
# The default settings are reasonably fast for single images, yet allow a noticeable reduction in file size.
# Check documentation for jpegtran, pngcrush and gifsicle for more options.
optimiseJPG () {
  /usr/local/bin/jpegtran -optimize -progressive -outfile "${filePath}" "${filePath}" || optimisationError
}
optimisePNG () {
  /usr/local/bin/pngcrush -reduce -ow "${filePath}" || optimisationError
}
optimiseGIF () {
  /usr/local/bin/gifsicle --colors 256 -O3 "${filePath}" -o "${filePath}" || optimisationError
}
