#!/usr/bin/env bash

path_to_vtd_data=/home/tvuong/Datasets/VTD
path_to_output_filenames=~/kaldi-decode-and-align/file_creation/all_vtd_filenames.txt
path_to_output_files_with_paths=~/kaldi-decode-and-align/file_creation/all_vtd_files_with_paths.txt

find $path_to_vtd_data -name \*-ele.wav -printf '%f\n' | sort > $path_to_output_filenames
find $path_to_vtd_data -name \*-ele.wav -print | sort > $path_to_output_files_with_paths
