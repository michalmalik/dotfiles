#!/bin/sh

# QWERTZ keyboard
setxkbmap sk

# Remap CMD (Apple Keyboard) to AltGr
# xmodmap -e 'keycode 134 = ISO_Level3_Shift'

# Switch backslash with semicolon (needed in Wheezy)
#xmodmap -e 'keycode 49 = backslash bar backslash bar slash brokenbar slash'
#xmodmap -e 'keycode 94 = semicolon dead_abovering semicolon dead_abovering grave asciitilde grave'

#conky -q
dropbox start

/etc/init.d/xflux.d start

# Set background
eval `cat $HOME/.fehbg`

export EDITOR=gvim

# Load my color settings
xrdb -merge ~/.Xdefaults

# Everything below this won't work
exec awesome
