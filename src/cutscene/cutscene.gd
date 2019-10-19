extends Node2D

export(String, "start", "middle", "end") var cutscene = "start"

signal finished

var cutscenes = {
	"start": {
		"dialogue": "start"
	},
	"middle": {
		"dialogue": "middle"
	},
	"end": {
		"dialogue": "end"
	}
}


func _ready():
	NodeRegistry.ui.dialogue_panel.connect("finished", self, "_on_dialogue_finished")

func start():
	NodeRegistry.ui.open_dialogue(cutscenes[cutscene].dialogue)
	# NodeRegistry.ui.dialogue_panel.show_dialogue(cutscenes[cutscene].dialogue)
	
func stop():
	NodeRegistry.ui.dialogue_panel.end_dialogue()
	
func _on_dialogue_finished():
	emit_signal("finished")
