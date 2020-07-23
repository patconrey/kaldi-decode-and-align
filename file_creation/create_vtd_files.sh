#!/usr/bin/env bash

./get_all_vtd_files.sh

python format_segments.py
python format_speaker_utterance_files.py
python format_wav.py
