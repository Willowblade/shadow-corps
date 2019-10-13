extends Area2D
class_name Interactable

export var enabled_at_start: bool = true

var enabled = enabled_at_start
var currently_active = false

onready var tooltip = $Tooltip


signal interacted

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	

func toggle_active():
	pass
	
func toggle_inactive():
	pass
	
func perform_interaction():
	pass

func enable():
	enabled = true
	if currently_active:
		toggle_active()

func disable():
	enabled = false
	if currently_active:
		toggle_inactive()
	
func _on_body_entered(body: PhysicsBody2D):
	if body is Player:
		currently_active = true
		if enabled:
			tooltip.show()
			toggle_active()

func _on_body_exited(body: PhysicsBody2D):
	if body is Player:
		currently_active = false
		if enabled:
			tooltip.hide()
			toggle_inactive()
		
func _on_player_interacted():
	if currently_active and enabled:
		print("Interacted!")
		emit_signal("interacted")
		perform_interaction()