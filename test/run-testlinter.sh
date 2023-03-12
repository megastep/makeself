#!/bin/bash
set -eu
THIS="$(readlink -f "$0")"
THISDIR="$(dirname "${THIS}")"

cd "$THISDIR"

is_windows_os=false
[[ $(uname) == Windows_NT* ]] && is_windows_os=true
[[ $(uname) == MINGW64_NT* ]] && is_windows_os=true

testShStartsWith() {
  if [[ $is_windows_os == true ]]; then
    return
  fi

  for test_sh in ./*test; do
    file_name="$(basename -- "$test_sh")"
    if [[ -f "${test_sh}" ]]; then
      echo ">> Test $file_name"
      local etalon_head="$(printf '#!/bin/bash
set -eu
THIS="$(readlink -f "$0")"
THISDIR="$(dirname "${THIS}")"
')"
      assertEquals  "$etalon_head" "$(cat "${test_sh}" | head -4)"
    fi
  done
}

# Load and run shUnit2.
source "./shunit2/shunit2"
