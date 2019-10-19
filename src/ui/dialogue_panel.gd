extends Panel

const DICT_UTIL = preload("res://src/util/dict_util.gd")

var file : String = "res://assets/data/dialogues.json"

export var use_portraits = false

onready var text_label = $RichTextLabel
onready var player_portrait = $PlayerPortait
onready var target_portrait = $TargetPortrait

onready var player_sprite = $"../PlayerSprite"
onready var target_sprite = $"../TargetSprite"

onready var speaker_name = $SpeakerName

onready var portraits = {
	"klaus": preload("res://assets/graphics/portraits/klaus.png"),
	"orubo": preload("res://assets/graphics/portraits/orubo.png"),
	"kai": preload("res://assets/graphics/portraits/kai.png"),
	"lythe": preload("res://assets/graphics/portraits/lythe.png"),
	"jute": preload("res://assets/graphics/portraits/jute.png"),
}

onready var statues = {
	"klaus": preload("res://assets/graphics/player/idle/idle.png"),
	"orubo": preload("res://assets/graphics/npc/orubo.png"),
	"kai": preload("res://assets/graphics/npc/kai.png"),
	"lythe": preload("res://assets/graphics/npc/lythe.png"),
	"jute": preload("res://assets/graphics/npc/jute.png"),
}

onready var names = {
	"klaus": "Klaus",
	"orubo": "Orubo",
	"kai": "Kai",
	"lythe": "Lythe",
	"jute": "Jute",
}
	
var current_dialogue_name = ""
var current_dialogue = {}
var current_line = 0

signal finished

func _ready():
	text_label.set_override_selected_font_color(true)
	visible = false

func _process(delta):
	if Input.is_action_just_pressed("ui_progress_dialogue"):
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

		if use_portraits:
			if speaker == "klaus":
				player_portrait.show()
				target_portrait.hide()
			else:
				player_portrait.hide()
				var target_texture = portraits.get(speaker)
				if speaker == "kai":
					target_portrait.scale.x = -1
				else:
					target_portrait.scale.x = 1
				if target_texture:
					target_portrait.show()
					target_portrait.texture = target_texture
		else:
			if speaker == "klaus":
				
				player_sprite.show()
				target_sprite.hide()
			else:
				player_sprite.hide()
				var target_texture = statues.get(speaker)
				if speaker == "kai":
					target_sprite.scale.x = -abs(target_sprite.scale.y)
				else:
					target_sprite.scale.x = abs(target_sprite.scale.y)
				if target_texture:
					target_sprite.show()
					target_sprite.texture = target_texture
		
		var speaker_name_string = names.get(speaker, "???")
		speaker_name.show()
		speaker_name.text = speaker_name_string
			
	else:
		visible = false
		trigger_event()
		emit_signal("finished")
#		NodeRegistry.player.end_dialogue()

func continue_dialogue():
	player_sprite.hide()
	target_sprite.hide()
	current_line += 1
	show_line()

func trigger_event():
	match current_dialogue_name:
		"start":
			pass
		_:
			pass
