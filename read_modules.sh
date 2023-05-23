#!/bin/bash

read_modules() {
  local modules=()
  while IFS= read -r line; do
    # Eliminar espacios en blanco al principio y al final de la línea
    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    # Ignorar líneas que comienzan con #
    if [[ $line != \#* ]]; then
      modules+=("$line")
    fi
  done < modules.txt
  echo "${modules[@]}"
}