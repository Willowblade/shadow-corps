extends Interactable


export(String, "instructions", "congratulations") var dialogue_name = "instructions"

func _ready():
	pass # Replace with function body.


func perform_interaction():
	NodeRegistry.ui.open_dialogue(dialogue_name)
