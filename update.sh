#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
git pull --ff-only
exec ./apply-migrations.sh
