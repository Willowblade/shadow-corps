extends Control

var should_pause = true

onready var dialog = $ConfirmationDialog

onready var mission_buttons = $MissionButtons

onready var dialog_contents = {
	"title": $ConfirmationDialog/Control/Title,
	"thumbnail": $ConfirmationDialog/Control/Thumbnail,
	"description": $ConfirmationDialog/Control/Description,
}

onready var return_button = $ReturnButton

var selected_mission = null

signal close(menu)

func _ready():
	# configure custom accept strings
	return_button.connect("pressed", self, "_return_button_pressed")
	
	var cancel_button = dialog.get_cancel()
	var ok_button = dialog.get_ok()
	cancel_button.text = "Reconsider"
	ok_button.text = "Depart"
	
	dialog.connect("confirmed", self, "_on_mission_accepted")
	cancel_button.connect("pressed", self, "_on_mission_rejected")
	
	for button in mission_buttons.get_children():
		button.connect("pressed", self, "_on_mission_button_pressed", [button])
		# TODO move away from locked as export, make var in MissionButton
		# also add completed. Keep these in save file?
		if button.locked:
			button.disabled = true
			button.set_tooltip("Currently locked, complete previous missions")
		else:
			button.set_tooltip("Go ahead...")
		
func _on_mission_button_pressed(button: MissionButton):
	selected_mission = button.mission
	
	dialog_contents.title.text = button.title
	dialog_contents.thumbnail.texture = button.thumbnail
	dialog_contents.description.text = button.description
	
	dialog.show()
	
func _on_mission_accepted():
	print("Should start mission ", selected_mission)
	emit_signal("close")
	NodeRegistry.game.load_level(selected_mission)

	
func _on_mission_rejected():
	print("Cancel pressed")
	selected_mission = null
	
func _return_button_pressed():
	emit_signal("close")
	