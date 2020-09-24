#!/usr/bin/env bash

. ./cmd.sh
[ -f path.sh ] && . ./path.sh
set -e

echo > custom_logs/log

# Acoustic model parameters
numLeavesTri1=2500
numGaussTri1=15000
numLeavesMLLT=2500
numGaussMLLT=15000
numLeavesSAT=2500
numGaussSAT=15000
numGaussUBM=400
numLeavesSGMM=7000
numGaussSGMM=9000

feats_nj=1
train_nj=1
decode_nj=1

# echo ============================================================================
# echo TIMIT Data Prep
# echo ============================================================================

# echo Timit Data Prep >> custom_logs/log
# date +"%T" >> custom_logs/log

# timit=/home/tvuong/Datasets/LDC93S1/TIMITcorpus/TIMIT

# local/timit_data_prep.sh $timit || exit 1

# local/timit_prepare_dict.sh

# utils/prepare_lang.sh --sil-prob 0.0 --position-dependent-phones false --num-sil-states 3 \
#  data/local/dict "sil" data/local/lang_tmp data/lang

# local/timit_format_data.sh

# echo Timit Data Prep Done >> custom_logs/log
# date +"%T" >> custom_logs/log
# echo  >> custom_logs/log

echo ============================================================================
echo VTD Data Prep
echo ============================================================================

echo VTD Data Prep >> custom_logs/log
date +"%T" >> custom_logs/log

file_creation/create_vtd_files.sh

echo VTD Data Prep Done >> custom_logs/log
date +"%T" >> custom_logs/log
echo  >> custom_logs/log

echo Done with VTD data prep.

echo ============================================================================
echo MFCC Feature Extration
echo ============================================================================

echo MFCCs >> custom_logs/log
date +"%T" >> custom_logs/log

mfccdir=mfcc

# for x in train vtd_decode_and_align; do
for x in vtd_decode_and_align; do
    echo $x >> custom_logs/log
    date +"%T" >> custom_logs/log
    steps/make_mfcc.sh --cmd "$train_cmd" --nj $feats_nj --mfcc-config custom_conf/mfcc.conf data/$x exp/make_mfcc/$x $mfccdir
    steps/compute_cmvn_stats.sh data/$x exp/make_mfcc/$x $mfccdir
    utils/data/validate_data_dir.sh --no-text data/$x
done

echo MFCCs Done >> custom_logs/log
date +"%T" >> custom_logs/log

echo  >> custom_logs/log

# echo ============================================================================
# echo "                     MonoPhone Training & Decoding                        "
# echo ============================================================================

# echo Monophone Training and Decoding >> custom_logs/log
# date +"%T" >> custom_logs/log

# steps/train_mono.sh  --nj "$train_nj" --cmd "$train_cmd" data/train data/lang exp/mono

# utils/mkgraph.sh data/lang_test_bg exp/mono exp/mono/graph

# echo Done >> custom_logs/log
# date +"%T" >> custom_logs/log

# echo  >> custom_logs/log

# echo ============================================================================
# echo "           tri1 : Deltas + Delta-Deltas Training                          "
# echo ============================================================================

# echo Tri1 Training >> custom_logs/log
# date +"%T" >> custom_logs/log

# steps/align_si.sh --boost-silence 1.25 --nj "$train_nj" --cmd "$train_cmd" \
#     data/train data/lang exp/mono exp/mono_ali

# steps/train_deltas.sh --cmd "$train_cmd" \
#     $numLeavesTri1 $numGaussTri1 data/train data/lang exp/mono_ali exp/tri1

# echo Tri1 Training Done >> custom_logs/log
# date +"%T" >> custom_logs/log

# echo  >> custom_logs/log

echo ============================================================================
echo "tri1 : Deltas + Delta-Deltas Decoding"
echo ============================================================================

echo Tri1 Decoding >> custom_logs/log
date +"%T" >> custom_logs/log

utils/mkgraph.sh data/lang_test_bg exp/tri1 exp/tri1/graph

custom_steps/decode.sh --nj "$decode_nj" --cmd "$decode_cmd" --skip-scoring true \
   exp/tri1/graph data/vtd_decode_and_align exp/tri1/vtd_decode_and_align

echo Tri1 Decoding Done >> custom_logs/log
date +"%T" >> custom_logs/log

echo  >> custom_logs/log

echo ============================================================================
echo Getting Transcript
echo ============================================================================

echo Getting Transcript >> custom_logs/log
date +"%T" >> custom_logs/log

lattice-best-path ark:'gunzip -c exp/tri1/vtd_decode_and_align/lat.1.gz |' 'ark,t:| int2sym.pl -f 2- exp/tri1/graph/words.txt > data/vtd_decode_and_align/text'

echo Getting Transcript Done >> custom_logs/log
date +"%T" >> custom_logs/log

echo ============================================================================
echo Aligning Data
echo ============================================================================

echo Aligning Data >> custom_logs/log
date +"%T" >> custom_logs/log

cp data/vtd_decode_and_align/text data/vtd_decode_and_align/split1/1/
steps/align_si.sh --nj 1 --cmd "$train_cmd" data/vtd_decode_and_align data/lang \
    exp/tri1 experiment_results/vtd_decode_and_align_rm2_se11/mc14 || exit 1;

echo Aligning Data Done >> custom_logs/log
date +"%T" >> custom_logs/log

echo ============================================================================
echo "Extracting Time-Marked Conversion File"
echo ============================================================================

for i in experiment_results/vtd_decode_and_align_rm2_se11/mc14/ali.*.gz; do
    $KALDI_ROOT/src/bin/ali-to-phones --ctm-output exp/tri1/final.mdl \
        ark:"gunzip -c $i|" -> ${i%.gz}.ctm;
done

cat experiment_results/vtd_decode_and_align_rm2_se11/mc14/*.ctm > experiment_results/vtd_decode_and_align_rm2_se11/mc14/merged_vtd_decode_and_align.txt

# python phone_id_to_phone.py