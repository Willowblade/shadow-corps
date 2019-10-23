extends Node2D

onready var player = $Player

onready var camera = $Camera
onready var player_camera = player.camera

onready var rooms = $Rooms.get_children()

var room_history = []

var current_room = null

func _ready():
	var js_return = JavaScript.eval("var myNumber = 1; myNumber + 2;")
	if js_return:
		for lamp in get_tree().get_nodes_in_group("lamp"):
			lamp.queue_free()
			
	NodeRegistry.ui.health_bar.enable()
	
	player.connect("death", self, "_on_player_death")
	
	for interactable in get_tree().get_nodes_in_group("interactive"):
		player.connect("interact", interactable, "_on_player_interacted")
		
	for room in rooms:
		room.zone.connect("body_entered", self, "_on_body_entered_room_zone", [room])
		room.zone.connect("body_exited", self, "_on_body_exited_room_zone", [room])
		
	for upgrade in get_tree().get_nodes_in_group("upgrade"):
		upgrade.connect("consume", player, "_on_upgrade_consumed")
		
	for killzone in get_tree().get_nodes_in_group("killzone"):
		killzone.connect("body_entered", self, "_on_killzone_entered")
		
	for crystal in get_tree().get_nodes_in_group("crystal"):
		crystal.connect("broken", self, "_on_crystal_broken")

func _on_crystal_broken():
	for destroyable in get_tree().get_nodes_in_group("destroy"):
		destroyable.queue_free()
		
func _on_killzone_entered(body):
	if body is Player:
		body.take_damage(999)
		
func _on_player_death():
	pass
	
func set_room(room):
	var zone_extents = room.zone_extents()

	player_camera.limit_left = zone_extents.top_left.x
	player_camera.limit_top = zone_extents.top_left.y
	player_camera.limit_right = zone_extents.bottom_right.x
	player_camera.limit_bottom = zone_extents.bottom_right.y
	player_camera.current = true

	current_room = room
	
func _on_body_entered_room_zone(body, room):
	print("entered room", room)
	if body is Player:
		if room.background_music:
			AudioEngine.play_background_music(room.background_music)
		var zone_extents = room.zone_extents()
		set_room(room)
		room_history.append(room)
		print(room_history)
		if len(room_history) == 1:
			player.last_checkpoint = player.position
		
func _on_body_exited_room_zone(body, room):
	if body is Player:
		print(room_history)
		print("exited room", room)
		room_history.erase(room)
		if room == current_room:
			print("Oh my")
			if len(room_history):
				set_room(room_history[0])
				
		if len(room_history):
			player.last_checkpoint = player.position
		
	
	