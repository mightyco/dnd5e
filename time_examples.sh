#!/bin/bash

EXAMPLES_DIR="/Users/chuckmcintyre/src/dnd5e/examples"
OUTPUT_FILE="execution_times.txt"

echo "Timing execution of scripts in $EXAMPLES_DIR" > "$OUTPUT_FILE"
echo "------------------------------------------" >> "$OUTPUT_FILE"

for script in "$EXAMPLES_DIR"/*.rb; do
  script_name=$(basename "$script")
  echo "Timing $script_name..."
  
  # Capture the real time using /usr/bin/time -p for portability and simplicity
  # We use a subshell to capture only the time output of the time command
  exec_time=$({ /usr/bin/time -p bundle exec ruby "$script" > /dev/null 2>&1; } 2>&1 | grep real | awk '{print $2}')
  
  echo "$script_name: $exec_time seconds" >> "$OUTPUT_FILE"
  echo "$script_name: $exec_time seconds"
done

echo "------------------------------------------" >> "$OUTPUT_FILE"
echo "Done." >> "$OUTPUT_FILE"
