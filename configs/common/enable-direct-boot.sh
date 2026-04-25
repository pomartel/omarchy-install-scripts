existing_entry=$(efibootmgr | grep -E "^Boot[0-9A-Fa-f]+\*? Omarchy([[:space:]]|$)" | head -1)

if [[ -z $existing_entry ]]; then
  omarchy-config-direct-boot
fi
