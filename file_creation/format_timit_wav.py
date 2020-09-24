path_to_wav_scp = '/home/pconrey/kaldi-decode-and-align/data/train/wav.scp'
path_to_new_wav_scp = '/home/pconrey/kaldi-decode-and-align/data/train/wav.new.scp'

with open(path_to_wav_scp, 'r') as source_file:
	with open(path_to_new_wav_scp, 'w') as target_file:
		for line in source_file:
			line_parts = line.split(' ')
			file_id = line_parts[0]
			file_path = line_parts[-2]
			
			new_line = '{} sox {} -t wav -r 11025 - |\n'.format(file_id, file_path)
			target_file.write(new_line)
