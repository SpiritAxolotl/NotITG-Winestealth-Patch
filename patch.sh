#!/bin/sh
set -ex

NOTITG_EXE=""
NO_CHECKSUM=false
PATCHED_EXE="NotITG-v4.3.1"
while getopts 'i:no' OPTION; do
  case "$OPTION" in
  i)
    NOTITG_EXE="$OPTARG" ;;
  o)
    PATCHED_EXE=${OPTARG%.exe} ;;
  n)
    NO_CHECKSUM=true
    PATCHED_EXE="NotITG"
    ;;
  esac
done
PROGRAM_FOLDER=${NOTITG_EXE%/*}

if [ "$NOTITG_EXE" = "" ]; then
  echo "usage: $0 [-i <path-to-nitg-executable>] [-o <patched-exe-name>] [-n]" >&2
  exit 1
fi

PRE_CHECKSUM="4e681b30899475214e6b00d472d11d7d0baecc399dcc657d0338937efcea5f48"
POST_CHECKSUM="1a8948190ae119df887a59754cb6e9dad61f6d9aebadd0a3290c24ffd703d223"

if ! $NO_CHECKSUM && ! echo "$PRE_CHECKSUM $NOTITG_EXE" | sha256sum --check --status; then
  echo "$NOTITG_EXE has an unexpected checksum. Are you sure it's the right file?
(Run the command with -n to disable the checksum.)" >&2
  exit 1
fi

### we are patching:
###                             undefined FUN_006befc0()
###                               assume FS_OFFSET = 0xffdff000
###             undefined         AL:1           <RETURN>
###                             FUN_006befc0
###        006befc0 80 3d 28        CMP        byte ptr [DAT_00a8cf28],0x0
###                 cf a8 00 00
###        006befc7 75 0e           JNZ        LAB_006befd7
ORIG_BYTES="803d28cfa80000750e"

### with:
###                             undefined FUN_006befc0()
###                               assume FS_OFFSET = 0xffdff000
###             undefined         AL:1           <RETURN>
###                             FUN_006befc0
###        006befc0 66 90           NOP
###        006befc2 90              NOP
###        006befc3 90              NOP
###        006befc4 90              NOP
###        006befc5 90              NOP
###        006befc6 90              NOP
###        006befc7 eb 0e           JMP        LAB_006befd7
PATCH_BYTES="66909090909090eb0e"

xxd -p -c0 "$NOTITG_EXE" | sed "s/$ORIG_BYTES/$PATCH_BYTES/" | xxd -r -p > "${PROGRAM_FOLDER}/${PATCHED_EXE}.exe"

if ! $NO_CHECKSUM && ! echo "$POST_CHECKSUM ${PROGRAM_FOLDER}/${PATCHED_EXE}.exe" | sha256sum --check --status; then
  echo "The file was not patched properly." >&2
  exit 1
fi

echo "Done! Enjoy stealth!"
exit 0