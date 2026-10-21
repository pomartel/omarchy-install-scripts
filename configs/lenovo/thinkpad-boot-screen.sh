if [ ! -d ~/.config/omarchy/themes/thinkpad ]; then
  git clone https://github.com/Yilmaz41/Thinkpad-boot-screen ~/.config/omarchy/themes/thinkpad
  omarchy-plymouth-set-by-theme thinkpad
fi
