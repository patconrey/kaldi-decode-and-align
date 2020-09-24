path_to_all_vtd_files_document = '/home/pconrey/kaldi-decode-and-align/file_creation/all_vtd_files_with_paths.txt'
path_to_wav_scp = '/home/pconrey/kaldi-decode-and-align/data/vtd_decode_and_align/wav.scp'

with open(path_to_all_vtd_files_document, 'r') as source_file:
	with open(path_to_wav_scp, 'w') as target_file:
		for line in source_file:
			if '._vtd' in line:
				continue

			file_id = line.split('/')[-1].split('.')[0]
			if not ('rm2' in file_id):
				continue
			if not ('se11' in file_id):
				continue
			if not ('mc14' in file_id or 'mc15' in file_id):
				continue
				
			# new_line = '{} sox -r 11000 {} -t wav -r 16000 - |\n'.format(file_id, line.rstrip())
			new_line = '{} sox {} -t wav - |\n'.format(file_id, line.rstrip())
			target_file.write(new_line)
