#!/usr/bin/env bash

f=$1
exe_name=$(sed -n 's|^.*generate-new/\([^/]*\)/.*$|\1|p' <<< "$f")
p=/home/j/projects/vulkan/generate-new/package.yaml
printf "%s\n" "$(yq < "$p" ".executables.$exe_name.\"source-dirs\"" --raw-output | sed 's|^|-i|')" >> $HIE_BIOS_OUTPUT
printf "%s\n" "$(yq < "$p" '.library."source-dirs"' --raw-output | sed 's|^|-i|')" >> $HIE_BIOS_OUTPUT
printf "%s\n" "$(yq < "$p" '.library."ghc-options"[]' --raw-output | sed '/-O./d')" >> $HIE_BIOS_OUTPUT
printf "%s\n" "$(yq < "$p" '.library."default-extensions"[]' --raw-output | sed 's|^|-X|')" >> $HIE_BIOS_OUTPUT
printf "%s\n" "$(yq < "$p" '."default-extensions"[]' --raw-output | sed 's|^|-X|')" >> $HIE_BIOS_OUTPUT
printf "%s\n" "$(yq < "$p" '."ghc-options"[]' --raw-output | sed '/-O/d')" >> $HIE_BIOS_OUTPUT
