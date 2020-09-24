#!/usr/bin/env bash

# ./get_all_vtd_files.sh

python file_creation/format_segments.py

sort data/vtd_decode_and_align/segments > data/vtd_decode_and_align/segments2 && cat data/vtd_decode_and_align/segments2 > data/vtd_decode_and_align/segments && rm data/vtd_decode_and_align/segments2
python file_creation/format_speaker_utterance_files.py
python file_creation/format_wav.py

# python file_creation/format_timit_wav.py
# cat data/train/wav.new.scp > data/train/wav.scp
# rm data/train/wav.new.scp
