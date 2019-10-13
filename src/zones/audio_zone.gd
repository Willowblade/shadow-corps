extends Area2D

export(String, "background", "sound", "effect") var type = "background"
export(String, FILE, "*.ogg") var audio_track

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	connect("body_exited",get_parent(), "_on_body_exited")

func _on_body_entered(body):
	if body is Player:
		match type:
			"background":
				AudioEngine.play_background_music(audio_track)
			"sound":
				AudioEngine.play_sound(audio_track)

func _on_body_exited(body):
	if body is Player:
		pass