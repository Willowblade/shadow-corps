extends Node2D

onready var level: Node = null
onready var ui = $UI

onready var hub: PackedScene = preload("res://src/areas/GoblinTestLevel.tscn")

var key_pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	NodeRegistry.register_game(self)
	NodeRegistry.register_ui(ui)
	load_hub()
	
func load_hub():
	load_level(hub)
	
func load_level(level_scene: PackedScene):
	if level != null:
		level.queue_free()
		level = null
	level = level_scene.instance()
	add_child(level)
	NodeRegistry.register_level(level)
	
func _input(event):
	if not key_pressed:
		if Input.is_key_pressed(KEY_1):
			key_pressed = true
			load_level(load("res://src/areas/Stratae.tscn"))
		elif Input.is_key_pressed(KEY_2):
			key_pressed = true
			load_level(load("res://src/areas/CaveTestRoom.tscn"))
		elif Input.is_key_pressed(KEY_3):
			key_pressed = true
			load_level(load("res://src/areas/GoblinTestLevel.tscn"))
		elif Input.is_key_pressed(KEY_4):
			key_pressed = true
			load_level(load("res://src/areas/BatTestLevel.tscn"))
	else:
		key_pressed = false
	
