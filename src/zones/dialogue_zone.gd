extends Area2D
class_name DialogueZone

onready var dialogue_panel = get_node("/root/Game/UI/Dialogue/DialoguePanel")
export (String, "dialogue1", "dialogue2", "dialogue3", "dialogue3-mid", "dialogue-retry", "dialogue3-over", "dialogue4", "dialogue5", "dialogue6", "Merly23", "Antony", "Willow", "Jordan", "Inherently", "Doggie", "Agent") var scene_name = "dialogue2"

var shown = false

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body is Player and not shown:
		play_dialogue()
		
func play_dialogue():
	get_node("/root/Game/Room/Player").start_dialogue()
	dialogue_panel.show_dialogue(scene_name)
	shown = true
	
func disable():
	get_node("CollisionShape2D").set_disabled(true)
	
	
func reset():
	shown = false
	get_node("CollisionShape2D").set_disabled(false)

