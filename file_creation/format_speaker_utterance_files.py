# spkr utt_id1 utt_id2 utt_id3

path_to_all_vtd_files_document = 'all_vtd_filenames.txt'
path_to_sk2utt_file = '../data/vtd_decode_and_align/spk2utt'
path_to_utt2spk_file = '../data/vtd_decode_and_align/utt2spk'

speaker_utterance_pairs = {}

with open(path_to_all_vtd_files_document, 'r') as source_file:
	with open(path_to_utt2spk_file, 'w') as utt2spk_target_file:
		for line in source_file:
			if '._vtd' in line:
				continue
				
			file_id = line.split('.')[0]
			utterance_id = 'utt-' + file_id
			if 'rm3' in utterance_id or 'rm4' in utterance_id:
				continue

			file_parts = line.split('-') # [vtd, rm1, se01, mc14, ele.wav]
			speaker_id = file_parts[1] + '-' + file_parts[2]
			
			if speaker_id in speaker_utterance_pairs:
				speaker_utterance_pairs[speaker_id].append(utterance_id)
			else:
				speaker_utterance_pairs[speaker_id] = [utterance_id]

			utt2spk_target_file.write('{} {}\n'.format(utterance_id, speaker_id))

speaker_ids = sorted(speaker_utterance_pairs.keys())
# speaker_ids.sort()

with open(path_to_sk2utt_file, 'w') as target_file:
	for speaker_id in speaker_ids:
		new_line = speaker_id + ' ' + ' '.join(speaker_utterance_pairs[speaker_id]) + '\n'
		target_file.write(new_line)
