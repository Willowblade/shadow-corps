extends Node2D
class_name BaseRoom

onready var projectiles = $Projectiles

onready var audio_zones = $Zones/Audio
onready var dialogue_zones = $Zones/Dialogue

onready var tilesets = $Tilesets


func _ready():
	for zone in audio_zones.get_children():
		zone.connect("body_exited", self, "_on_audio_zone_exited")
		
#	AudioEngine.play_background_music(default_track)
		
	$Player.connect("death", self, "_on_player_death")
	
	
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.global_position.y < $Levels/First.global_position.y:
			enemy.level = "Regular"
		else:
			if enemy.name.begins_with("Mushroom"):
				enemy.level = "Transform"
			elif enemy.name.begins_with("Slime"):
				enemy.level = "Monster"
				enemy._transform()

	
func get_tile_under_player_position():
	var player_position = $Player.global_position
	for tileset in tilesets.get_children():
		var tilemap: TileMap = tileset
		for i in range(6):
			print(tilesets.position)
			var vector = (player_position + Vector2(0, 48 * i) - position) / 3
			var cell = tilemap.get_cellv(tilemap.world_to_map(vector))
			if cell != -1:
#				print("tile ", cell, " exists in tilemap ", tilemap.name, "at vector ", vector, " on index ", i)
				return tilemap.map_to_world(tilemap.world_to_map(vector)) * 3 + position
		tilemap.world_to_map(player_position)
	
	
func _on_audio_zone_exited(body):
	if body is Player:
		print("Playing background music")
#		AudioEngine.play_background_music(default_track)
		pass
	