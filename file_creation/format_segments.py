import numpy as np

path_to_all_vtd_files_document = '/home/pconrey/kaldi-decode-and-align/file_creation/all_vtd_filenames.txt'
path_to_segments_file = '/home/pconrey/kaldi-decode-and-align/data/vtd_decode_and_align/segments'
path_to_SRI_VAD = '/home/pconrey/kaldi-decode-and-align/file_creation/vad.vtd-rm2-se11-mc17-ele.txt'

window_to_consider_s = 15.0
window_to_consider_ms = window_to_consider_s * 1000
resolution_of_vad_ms = 10
number_of_scores_in_window = int(window_to_consider_ms / resolution_of_vad_ms)
all_utterances = []
scores = []
lines_for_segment_file = []

print('\nCreating Segments File.')

print('- Reading SRI data')
with open(path_to_SRI_VAD, 'r') as file:
	next(file)
	for line in file:
		scores.append(float(line.split(',')[1]))

scores = np.asarray(scores)

print('- Computing gathered SRI statistics')
mean_vad_scores = []
for time_stamp in range(0, len(scores), number_of_scores_in_window):
	score_window = scores[time_stamp : time_stamp + number_of_scores_in_window]
	mean_vad_scores.append(np.mean(score_window))

mean_vad_scores = np.asarray(mean_vad_scores)
percent_needed = int(100 * len(mean_vad_scores[mean_vad_scores > -3]) / len(mean_vad_scores))

print('- Percent kept of file: {}%'.format(percent_needed))
with open(path_to_all_vtd_files_document, 'r') as source_file:
	# with open(path_to_segments_file, 'w') as target_file:
	for line in source_file:
		if '._vtd' in line:
			continue
		
		file_id = line.split('.')[0]

		if not ('rm2' in line):
			continue
		if not ('se11' in line):
			continue
		if not ('mc14' in line or 'mc15' in line):
			continue
		
		room_id = int(file_id.split('-')[1][-1])
		session_id = int(file_id.split('-')[2][-1])
		end_time = 0.0
		if room_id == 1:
			end_time = 28800.0
			if session_id == 3:
				end_time = 25800.0
			elif session_id == 8:
				end_time = 21600.0
			elif session_id == 1:
				end_time = 12600.0

		elif room_id == 2:
			end_time = 43200.0
		elif room_id == 3:
			end_time = 32400.0
		elif room_id == 4:
			end_time = 50400.0

		number_of_utterances = int(end_time // window_to_consider_s)
		utterance_start_times = window_to_consider_s * np.arange(0, number_of_utterances)
		assert (len(utterance_start_times) == len(mean_vad_scores)), 'The lengths of both vectors must be the same:\nUtterance Start Times : {}\nMean VAD Scores: {}'.format(utterance_start_times, mean_vad_scores)

		for start_time_index in range(0, len(utterance_start_times)):
			if mean_vad_scores[start_time_index] < -3:
				continue

			start_time = str(utterance_start_times[start_time_index])
			utterance_id = file_id + '-utt-' + str(start_time_index)
			end_time = str(utterance_start_times[start_time_index] + window_to_consider_s)
			new_line = '{} {} {} {}\n'.format(utterance_id, file_id, start_time, end_time)

			lines_for_segment_file.append(new_line)

print('- Writing to file')
with open(path_to_segments_file, 'w') as target_file:
	for line_to_write in lines_for_segment_file:
		target_file.write(line_to_write)			


# for index in range(0, number_of_utterances):
# 	
# 	start_time = str(index * 15.0)
# 	end_time = str((index + 1) * 15.0)
# 	new_line = '{} {} {} {}\n'.format(utterance_id, file_id, start_time, end_time)
	
# 	all_utterances.append(new_line)
# 	# target_file.write(new_line)



