boot_entries=$(efibootmgr)

if ! grep -E '^Boot[0-9A-Fa-f]+\*? Omarchy([[:space:]]|$)' <<<"$boot_entries" >/dev/null; then
  omarchy setup direct-boot
fi
unset boot_entries
