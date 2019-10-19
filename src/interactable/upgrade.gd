extends Area2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(String, "attack") var upgrade = "attack"

var consumed = false

signal consume

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_on_body_entered")
	

func _on_body_entered(body):
	if body is Player:
		if not consumed:
			consumed = true
			emit_signal("consume", upgrade)
			hide()
			NodeRegistry.ui.open_dialogue("attack_powerup")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
