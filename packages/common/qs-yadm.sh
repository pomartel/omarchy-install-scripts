# Native filesystem notifications for the qs-yadm plugin, isolated from system Python.
python3 -m venv "$HOME/.local/share/qs-yadm/venv"
"$HOME/.local/share/qs-yadm/venv/bin/python" -m pip install 'watchdog>=6,<7'
