extends Node

onready var menu = preload("res://src/menus/MainMenu.tscn")
onready var game = preload("res://src/Game.tscn")


func _ready():
	pass
	
func go_to_game():
	AudioEngine.reset()
	Flow.resume()
	get_tree().change_scene_to(game)
	
func go_to_main_menu():
	AudioEngine.reset()
	Flow.resume()
	get_tree().change_scene_to(menu)
	
func pause():
	get_tree().paused = true

func resume():
	get_tree().paused = false
	
func quit():
	get_tree().quit()