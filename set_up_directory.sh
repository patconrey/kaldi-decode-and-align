#!/usr/bin/env bash

if [[ -z "${KALDI_ROOT}" ]]; then
	echo KALDI_ROOT must be set.
	exit 1;
fi

path_to_timit_recipe=$KALDI_ROOT/egs/timit/s5

echo Creating top-level symlinks from Kaldi\'s timit recipe.

for directory_to_link in steps utils conf local; do
	ln -s $path_to_timit_recipe/$directory_to_link $directory_to_link
	echo \-\>	Linked $path_to_timit_recipe/$directory_to_link to $directory_to_link/
done

mkdir exp
mkdir exp/tri3
mkdir experiment_results

echo Downloading top-level data directory from S3.

curl --silent -O https://pats-public-d66bc4c3.s3-us-west-2.amazonaws.com/kaldi/kaldi_timit_recipe_data_directory.tar.gz

tar -xzf kaldi_timit_recipe_data_directory.tar.gz
rm kaldi_timit_recipe_data_directory.tar.gz
mv kaldi_timit_recipe_data_directory/data ./
rm -rf kaldi_timit_recipe_data_directory/

echo Downloading tri3 final models directory from S3.

curl --silent -O https://pats-public-d66bc4c3.s3-us-west-2.amazonaws.com/kaldi/kaldi_timit_recipe_tri3_models.tar.gz

tar -xzf kaldi_timit_recipe_tri3_models.tar.gz
rm kaldi_timit_recipe_tri3_models.tar.gz
mv kaldi_timit_recipe_tri3_models/* exp/tri3/
rm -rf kaldi_timit_recipe_tri3_models/

cp -r ~/kaldi/egs/timit/s5/data/decode_and_align ./data/