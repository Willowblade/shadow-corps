extends Button
class_name MissionButton

export(bool) var locked = false
export(String) var title = "Placeholder"
export(String, MULTILINE) var description = "We must go deeper"
export(Texture) var thumbnail
export(PackedScene) var mission

func _ready():
	pass
