#!/bin/sh
echo -ne '\033c\033]0;Swordigo V2- Extended Edition\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/SwordigoV2-Linux.x86_64" "$@"
