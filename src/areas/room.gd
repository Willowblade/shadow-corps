extends Node2D
class_name BaseRoom


export var player_camera = false

onready var projectiles = $Projectiles

onready var audio_zones = $Zones/Audio
onready var dialogue_zones = $Zones/Dialogue

onready var tilesets = $Layout/Tilesets

onready var zone = $RoomZone
onready var camera_anchor_point = $CameraAnchorPoint

export(AudioStreamOGGVorbis) var background_music = null

func _ready():
	for zone in audio_zones.get_children():
		zone.connect("body_exited", self, "_on_audio_zone_exited")
		
	
		
func enter():
	if background_music:
		AudioEngine.play_background_music(background_music)

func _on_audio_zone_exited(body):
	if body is Player:
		print("Playing background music")
#		AudioEngine.play_background_music(default_track)
		pass
		
		
func camera_anchor_position():
	return camera_anchor_point.position
	
func zone_extents():
	for zone_collision_shape in zone.get_children():
		return {
			"top_left": zone_collision_shape.global_position - zone_collision_shape.shape.extents,
			"bottom_right": zone_collision_shape.global_position + zone_collision_shape.shape.extents,
		}
	