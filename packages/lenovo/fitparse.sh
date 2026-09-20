# Python FIT-file parser used for RunGap activity analysis
fitparse_venv="${XDG_DATA_HOME:-$HOME/.local/share}/fitparse-venv"

if [[ ! -x "$fitparse_venv/bin/python" ]]; then
  python -m venv "$fitparse_venv"
fi

if ! "$fitparse_venv/bin/python" -c 'import fitparse' >/dev/null 2>&1; then
  "$fitparse_venv/bin/python" -m pip install fitparse
fi

unset fitparse_venv
