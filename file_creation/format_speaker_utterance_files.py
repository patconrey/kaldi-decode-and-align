# spkr utt_id1 utt_id2 utt_id3

path_to_segments_file = '/home/pconrey/kaldi-decode-and-align/data/vtd_decode_and_align/segments'
path_to_sk2utt_file = '/home/pconrey/kaldi-decode-and-align/data/vtd_decode_and_align/spk2utt'
path_to_utt2spk_file = '/home/pconrey/kaldi-decode-and-align/data/vtd_decode_and_align/utt2spk'

speaker_utterance_pairs = {}

with open(path_to_segments_file, 'r') as source_file:
	with open(path_to_utt2spk_file, 'w') as utt2spk_target_file:
		for line in source_file:
			if '._vtd' in line:
				continue
			
			line_parts = line.split(' ')
			file_id = line_parts[1]
			utterance_id = line_parts[0]

			file_parts = file_id.split('-') # [vtd, rm1, se01, mc14, ele.wav]
			speaker_id = file_parts[1] + '-' + file_parts[2]
			
			if speaker_id in speaker_utterance_pairs:
				speaker_utterance_pairs[speaker_id].append(utterance_id)
			else:
				speaker_utterance_pairs[speaker_id] = [utterance_id]

			utt2spk_target_file.write('{} {}\n'.format(utterance_id, speaker_id))

speaker_ids = sorted(speaker_utterance_pairs.keys())

with open(path_to_sk2utt_file, 'w') as target_file:
	for speaker_id in speaker_ids:
		new_line = speaker_id + ' ' + ' '.join(speaker_utterance_pairs[speaker_id]) + '\n'
		target_file.write(new_line)
