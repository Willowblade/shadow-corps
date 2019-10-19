extends Node2D

onready var player = $Player

onready var camera = $Camera
onready var player_camera = player.camera

onready var rooms = $Rooms.get_children()

var room_history = []

var current_room = null

func _ready():
		
	player.connect("death", self, "_on_player_death")
	
	for interactable in get_tree().get_nodes_in_group("interactive"):
		player.connect("interact", interactable, "_on_player_interacted")
		
	for room in rooms:
		room.zone.connect("body_entered", self, "_on_body_entered_room_zone", [room])
		room.zone.connect("body_exited", self, "_on_body_exited_room_zone", [room])
		
	for upgrade in get_tree().get_nodes_in_group("upgrade"):
		upgrade.connect("consume", player, "_on_upgrade_consumed")

	
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
		var zone_extents = room.zone_extents()

		set_room(room)
		room_history.append(room)
		
func _on_body_exited_room_zone(body, room):
	if body is Player:
		print(room_history)
		print("exited room", room)
		room_history.erase(room)
		if room == current_room:
			print("Oh my")
			if len(room_history):
				set_room(room_history[0])
		
	
	