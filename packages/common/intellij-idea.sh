# IntelliJ IDEA : distribution officielle de JetBrains
if pacman -Q intellij-idea-oss &>/dev/null; then
  sudo pacman -R --noconfirm intellij-idea-oss
elif pacman -Q intellij-idea-community-edition &>/dev/null; then
  sudo pacman -R --noconfirm intellij-idea-community-edition
fi

yay -S --needed --noconfirm intellij-idea-ultimate-edition
