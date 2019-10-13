extends Node2D

onready var level: Node = null
onready var ui = $UI

onready var hub: PackedScene = preload("res://src/areas/JobBoardTestRoom.tscn")

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
