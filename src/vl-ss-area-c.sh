#!/bin/bash

# Take an interactive screenshot
screencapture -ioc

# Confirm success
osascript -e 'display notification "The screenshot was saved to your clipboard." with title "Shot taken!"'