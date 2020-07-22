import numpy as np

kaldi_root = '/home/ubuntu/kaldi'
s5_root = kaldi_root + '/egs/timit/s5'

path_to_phones = s5_root + '/data/lang/phones.txt'
path_to_segments = s5_root + '/data/decode_and_align/segments.txt'
path_to_alignments = s5_root + '/exp/tri3_ali_decode_and_align/merged_decode_and_align.txt'

path_to_final_alignment = s5_root + '/exp/tri3_ali_decode_and_align/final_alignments.txt'

phones = np.genfromtxt(path_to_phones, dtype=str, delimiter=' ')[:, 0] # (51,) vector of phones strings
segments = np.genfromtxt(path_to_segments, dtype=str, delimiter=' ')
alignments = np.genfromtxt(path_to_alignments, dtype=str, delimiter=' ')

final_alignments = np.zeros((alignments.shape[0], 4)).astype(str)

for row_index in range(0, alignments.shape[0]):
	row = alignments[row_index, :]
	utterance_id = row[0]
	phone_start_time = float(row[2])
	phone_duration = float(row[3])
	phone_id = int(row[4])

	file_start_time = 0.
	if (utterance_id == 'fast_001'):
		file_start_time = 0.78
	else:
		file_start_time = 0.67

	start_time = phone_start_time + file_start_time
	end_time = start_time + phone_duration
	phone_readable = phones[phone_id]

	final_alignments[row_index, 0] = utterance_id
	final_alignments[row_index, 1] = str(start_time)
	final_alignments[row_index, 2] = str(end_time)
	final_alignments[row_index, 3] = phone_readable

np.savetxt(path_to_final_alignment, final_alignments, fmt='%s', delimiter=' ')
