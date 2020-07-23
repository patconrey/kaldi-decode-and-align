path_to_all_vtd_files_document = 'all_vtd_filenames.txt'
path_to_segments_file = '../data/vtd_decode_and_align/segments'

with open(path_to_all_vtd_files_document, 'r') as source_file:
	with open(path_to_segments_file, 'w') as target_file:
		for line in source_file:
			if '._vtd' in line:
				continue
			
			file_id = line.split('.')[0]
			utterance_id = 'utt-' + file_id

			if 'rm3' in utterance_id or 'rm4' in utterance_id:
				continue
				
			start_time = '0.0'
			end_time = '0.0'
			room_id = int(file_id.split('-')[1][-1])
			if room_id == 1:
				end_time = '28800.0'
			elif room_id == 2:
				end_time = '43200.0'
			else:
				end_time = '43200.0'
			new_line = '{} {} {} {}\n'.format(utterance_id, file_id, start_time, end_time)
			target_file.write(new_line)

