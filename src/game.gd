extends Node2D

onready var cutscene: Node = null
onready var level: Node = null
onready var ui = $UI

onready var hub: PackedScene = preload("res://src/areas/StrataeLevel.tscn")

onready var cutscenes = {
	"start": {
		"name": "start",
		"scene": preload("res://src/cutscene/CutsceneStart.tscn"),
		"next": "middle"
		# not implemented
#		"text": "It's the first day at Stratae, and Klaus is anxious to receive his familiar."
	},
	"middle": {
		"name": "middle",
		"scene": preload("res://src/cutscene/CutsceneMiddle.tscn"),
		"next": "end"
	},
	"end": {
		"name": "end",
		"scene": preload("res://src/cutscene/CutsceneEnd.tscn"),
	},
}

var key_pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	NodeRegistry.register_game(self)
	NodeRegistry.register_ui(ui)
#	load_cutscene("start")
#	load_hub()
	load_level(load("res://src/areas/GoblinTestLevel.tscn"))
	
func reset_contents():
	if cutscene != null:
		cutscene.stop()
		cutscene.queue_free()
		cutscene = null
	if level != null:
		level.queue_free()
		level = null
	
func load_cutscene(cutscene_name: String):
	var cutscene_data = cutscenes[cutscene_name]
	if level != null or cutscene != null:
		Transitions.fade_to_opaque()
		yield(Transitions, "transition_completed")
	reset_contents()
	cutscene = cutscene_data.scene.instance()
	add_child(cutscene)
	cutscene.connect("finished", self, "_on_cutscene_finished", [cutscene_data])
	Transitions.fade_to_transparant()
	yield(Transitions, "transition_completed")
	cutscene.start()
	
func _on_cutscene_finished(cutscene_data):
	var next_cutscene = cutscene_data.get("next")
	if next_cutscene:
		load_cutscene(next_cutscene)
	else:
		load_hub()

func load_hub():
	load_level(hub)
	
func load_level(level_scene: PackedScene):
	if level != null or cutscene != null:
		Transitions.fade_to_opaque()
		yield(Transitions, "transition_completed")
	reset_contents()
	level = level_scene.instance()
	add_child(level)
#	level.trigger_camera()
	NodeRegistry.register_level(level)
	NodeRegistry.register_player(level.player)
	Transitions.fade_to_transparant()
	yield(Transitions, "transition_completed")
	
func insta_load(level_scene: PackedScene):
	reset_contents()
	ui.dialogue_panel.end_dialogue()
	level = level_scene.instance()
	add_child(level)
#	level.trigger_camera()
	NodeRegistry.register_level(level)
	NodeRegistry.register_player(level.player)
	
func _input(event):
	if not key_pressed:
		if Input.is_key_pressed(KEY_2):
			key_pressed = true
			insta_load(load("res://src/areas/CaveLevel.tscn"))
		elif Input.is_key_pressed(KEY_3):
			key_pressed = true
			insta_load(load("res://src/areas/GoblinTestLevel.tscn"))
		elif Input.is_key_pressed(KEY_4):
			key_pressed = true
			insta_load(load("res://src/areas/BatTestLevel.tscn"))
		elif Input.is_key_pressed(KEY_5):
			key_pressed = true
			insta_load(load("res://src/areas/JobBoardTestLevel.tscn"))

		elif Input.is_key_pressed(KEY_6):
			key_pressed = true
			insta_load(load("res://src/cutscene/Cutscene.tscn"))
	else:
		key_pressed = false
		
	
