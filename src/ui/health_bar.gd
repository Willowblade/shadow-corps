extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var health = $Health

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func enable():
	set_process(true)
	show()
	
func disable():
	set_process(false)
	hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = NodeRegistry.player
	if player:
		health.scale.x = max(float(player.hp_current) / player.hp, 0)
