#!/usr/bin/env bash

. ./cmd.sh
[ -f path.sh ] && . ./path.sh
set -e

./set_up_directory.sh

decode_nj=4

echo ============================================================================
echo "MFCC Feature Extration"
echo ============================================================================

mfccdir=mfcc

for x in decode_and_align; do
    steps/make_mfcc.sh --cmd "$train_cmd" --nj 1 data/$x exp/make_mfcc/$x $mfccdir
	steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
done

utils/data/validate_data_dir.sh --no-text data/decode_and_align

echo ============================================================================
echo "SGMM2 Decoding"
echo ============================================================================

PRETRAINED_MODEL_DIR=exp/tri3

utils/mkgraph.sh data/lang_test_bg $PRETRAINED_MODEL_DIR exp/decode_and_align/graph

# Copy final.mdl over to exp/decode_and_align
if [ -f "exp/decode_and_align/final.mdl" ]; then
    echo Not copying over final.mdl
else
    cp $PRETRAINED_MODEL_DIR/final.mdl exp/decode_and_align/
    cp $PRETRAINED_MODEL_DIR/tree exp/decode_and_align/
    cp $PRETRAINED_MODEL_DIR/final.mat exp/decode_and_align/
    cp $PRETRAINED_MODEL_DIR/splice_opts exp/decode_and_align/
    cp $PRETRAINED_MODEL_DIR/cmvn_opts exp/decode_and_align/
    echo Copied final.mdl and tree to exp/decode_and_align/final.mdl
fi

steps/decode_fmllr.sh --nj "$decode_nj" --cmd "$decode_cmd" --skip-scoring true \
    exp/decode_and_align/graph data/decode_and_align exp/decode_and_align/decode

echo ============================================================================
echo "Getting Transcript"
echo ============================================================================

lattice-best-path ark:'gunzip -c exp/decode_and_align/decode/lat.1.gz |' 'ark,t:| int2sym.pl -f 2- exp/decode_and_align/graph/words.txt > exp/decode_and_align/text.1.txt'
lattice-best-path ark:'gunzip -c exp/decode_and_align/decode/lat.2.gz |' 'ark,t:| int2sym.pl -f 2- exp/decode_and_align/graph/words.txt > exp/decode_and_align/text.2.txt'
lattice-best-path ark:'gunzip -c exp/decode_and_align/decode/lat.3.gz |' 'ark,t:| int2sym.pl -f 2- exp/decode_and_align/graph/words.txt > exp/decode_and_align/text.3.txt'
lattice-best-path ark:'gunzip -c exp/decode_and_align/decode/lat.4.gz |' 'ark,t:| int2sym.pl -f 2- exp/decode_and_align/graph/words.txt > exp/decode_and_align/text.4.txt'

echo ============================================================================
echo "Aligning Data"
echo ============================================================================

steps/align_si.sh --nj 2 --cmd "$train_cmd" data/decode_and_align data/lang \
    exp/tri3 experiment_results/decode_and_align || exit 1;

echo ============================================================================
echo "Extracting Time-Marked Conversion File"
echo ============================================================================

for i in  experiment_results/decode_and_align/ali.*.gz; do
    $KALDI_ROOT/src/bin/ali-to-phones --ctm-output exp/tri3/final.mdl \
        ark:"gunzip -c $i|" -> ${i%.gz}.ctm;
done

cat experiment_results/decode_and_align/*.ctm > experiment_results/decode_and_align/merged_decode_and_align.txt

python phone_id_to_phone.py
