#!/usr/bin/env bash

. ./cmd.sh
[ -f path.sh ] && . ./path.sh
set -e

echo ============================================================================
echo "         MFCC Feature Extration & CMVN for Training						"
echo ============================================================================

mfccdir=mfcc

for x in decode_and_align; do
    steps/make_mfcc.sh --cmd "$train_cmd" --nj 1 data/$x exp/make_mfcc/$x $mfccdir
    utils/fix_data_dir.sh data/$x
	steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
    utils/fix_data_dir.sh data/$x
done

utils/data/validate_data_dir.sh data/decode_and_align

echo ============================================================================
echo "         Aligning Data Maybe												"
echo ============================================================================

steps/align_si.sh --nj 2 --cmd "$train_cmd" data/decode_and_align data/lang \
    exp/tri3_ali exp/tri3_ali_decode_and_align || exit 1;

echo ============================================================================
echo "         Extracting Time-Marked Conversion File												"
echo ============================================================================

for i in  exp/tri3_ali_decode_and_align/ali.*.gz; do
    $KALDI_ROOT/src/bin/ali-to-phones --ctm-output exp/tri3_ali/final.mdl \
        ark:"gunzip -c $i|" -> ${i%.gz}.ctm;
done

cat exp/tri3_ali_decode_and_align/*.ctm > exp/tri3_ali_decode_and_align/merged_alignments.txt

python phone_id_to_phone.py