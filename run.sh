#!/usr/bin/env bash

. ./cmd.sh
[ -f path.sh ] && . ./path.sh
set -e

./set_up_directory.sh

cd file_creation
./create_vtd_files.sh
cd ../

./decode_and_align.sh
