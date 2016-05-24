



# auto-hide dock, and show only active apps
# https://www.tekrevue.com/tip/the-complete-guide-to-customizing-mac-os-xs-dock-with-terminal/
defaults write com.apple.Dock autohide-delay -float 0 && killall Dock
defaults write com.apple.dock static-only -bool TRUE

# Keyboard repeats
defaults write -g InitialKeyRepeat -int 15 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 2 # normal minimum is 2 (30 ms)

# needs reboot after setting
# set Tap-to-click on
defaults -currentHost write -globalDomain com.apple.mouse.tapBehavior -int 1

