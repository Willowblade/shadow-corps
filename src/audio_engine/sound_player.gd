extends AudioStreamPlayer


var currently_playing = null


func _ready():
	pass
	

func is_available():
	return currently_playing == null
	

func play_sound(track_path: String, loop: bool = true):
	# TODO might not be always desired...
		
	var sound_audio_stream = load(track_path)
	if sound_audio_stream is AudioStreamOGGVorbis:
		sound_audio_stream.loop = loop
	elif sound_audio_stream is AudioStreamSample:
		sound_audio_stream.loop_begin = 0.0
		sound_audio_stream.loop_end = sound_audio_stream.get_length()
		sound_audio_stream.loop_mode = AudioStreamSample.LOOP_FORWARD
	stream = sound_audio_stream
	currently_playing = track_path
	play()
	

func finish():
	currently_playing = null
	# TODO maybe clear audio track?

#func play_sound(track_path: String, loop: bool = true):
#    # TODO might not be always desired...
#
#    var sound_audio_stream = load(track_path)
#    if sound_audio_stream is AudioStreamOGGVorbis:
#        sound_audio_stream.loop = loop
#    elif sound_audio_stream is AudioStreamSample:
#        sound_audio_stream.loop_begin = 0.0
#        sound_audio_stream.loop_end = sound_audio_stream.get_length()
#        sound_audio_stream.loop_mode = LOOP_FORWARD
#    stream = sound_audio_stream
#    currently_playing = track_path
#    play()