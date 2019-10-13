extends Panel

const DICT_UTIL = preload("res://src/util/dict_util.gd")

var file : String = "res://src/data/dialogues.json"

onready var text_label = $RichTextLabel
onready var player_portrait = $PlayerPortait
onready var target_portrait = $TargetPortrait

onready var portraits = {
	"klaus": preload("res://assets/graphics/portraits/klaus.png"),
}
	
var current_dialogue_name = ""
var current_dialogue = {}
var current_line = 0

signal finished

func _ready():
	text_label.set_override_selected_font_color(true)
	visible = false

func _process(delta):
	if Input.is_action_just_pressed("enter"):
		continue_dialogue()

func show_dialogue(dialogue_name):
	current_dialogue_name = dialogue_name
	var data_text = DICT_UTIL.load_dictionary_from_json(file)
	
	current_dialogue = data_text[dialogue_name]
	
	current_line = 0
	visible = true
	show_line()
	
	
func show_line():
	if current_line < len(current_dialogue.parts):
		var current_part = current_dialogue.parts[current_line]
		var speaker = current_part.speaker

		text_label.text = current_part.text

		if speaker == "klaus":
			player_portrait.show()
			target_portrait.hide()
		else:
			player_portrait.hide()
			var target_texture = portraits.get(speaker)
			if target_texture:
				target_portrait.show()
				target_portrait.texture = target_texture
	else:
		visible = false
		trigger_event()
		emit_signal("finished")
		get_node("/root/Game/Room/Player").end_dialogue()

func continue_dialogue():
	current_line += 1
	show_line()

func trigger_event():
	match current_dialogue_name:
		"start":
			pass
		_:
			pass
