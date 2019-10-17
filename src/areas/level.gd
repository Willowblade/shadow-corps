extends Node2D

onready var player = $Player

onready var camera = $Camera
onready var player_camera = player.camera

onready var rooms = $Rooms.get_children()

var current_room = null

func _ready():
		
	player.connect("death", self, "_on_player_death")
	
	for interactable in get_tree().get_nodes_in_group("interactive"):
		player.connect("interact", interactable, "_on_player_interacted")
		
	for room in rooms:
		room.zone.connect("body_entered", self, "_on_body_entered_room_zone", [room])
	
func _on_player_death():
	pass
	
func _on_body_entered_room_zone(body, room):
	if body is Player:
		var zone_extents = room.zone_extents()
		if room.player_camera:
			player_camera.limit_left = zone_extents.top_left.x
			player_camera.limit_top = zone_extents.top_left.y
			player_camera.limit_right = zone_extents.bottom_right.x
			player_camera.limit_bottom = zone_extents.bottom_right.y
			player_camera.current = true
		else:
			camera.limit_left = zone_extents.top_left.x
			camera.limit_top = zone_extents.top_left.y
			camera.limit_right = zone_extents.bottom_right.x
			camera.limit_bottom = zone_extents.bottom_right.y
			camera.current = true
			camera.position = room.camera_anchor_position()

		current_room = room

		print(room)
	
	