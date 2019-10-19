extends Interactable


func _ready():
	pass # Replace with function body.


func perform_interaction():
	NodeRegistry.ui.open_dialogue("instructions")
