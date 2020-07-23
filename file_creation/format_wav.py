path_to_all_vtd_files_document = 'all_vtd_files_with_paths.txt'
path_to_wav_scp = '../data/vtd_decode_and_align/wav.scp'

with open(path_to_all_vtd_files_document, 'r') as source_file:
	with open(path_to_wav_scp, 'w') as target_file:
		for line in source_file:
			if '._vtd' in line:
				continue

			file_id = line.split('/')[-1].split('.')[0]
			if 'rm3' in file_id or 'rm4' in file_id:
				continue
			
			new_line = '{} {}'.format(file_id, line)
			target_file.write(new_line)
