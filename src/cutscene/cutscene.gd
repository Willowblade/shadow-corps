extends Node2D

export(String, "start", "middle", "end") var cutscene = "start"

signal finished

var cutscenes = {
	"start": {
		"dialogue": "start"
	}
}


func _ready():
	NodeRegistry.ui.dialogue_panel.connect("finished", self, "_on_dialogue_finished")
	NodeRegistry.ui.dialogue_panel.show_dialogue(cutscenes[cutscene].dialogue)

func _on_dialogue_finished():
	emit_signal("finished")
