#!/bin/bash

set -euo pipefail

start_time=$(date +%s.%N)

source ./set-target.sh

./packages/add-packages.sh
./configs/apply-configs.sh

end_time=$(date +%s.%N)
elapsed_seconds=$(awk -v start="$start_time" -v end="$end_time" 'BEGIN { printf "%.1f", end - start }')

echo "All install scripts completed in ${elapsed_seconds}s"
