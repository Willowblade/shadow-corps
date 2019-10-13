extends Control


onready var alraune = get_node("/root/Game/Room/Enemies/DetectionZone/Alraune")

onready var sprite = get_node("Sprite")

func _ready():
	deactivate()

func activate():
	set_process(true)
	show()
	
func deactivate():
	set_process(false)
	hide()

func _process(delta):
	var health = 1
	if alraune.stats.transformed:
		health = alraune.stats.health * 1.0 / alraune.MONSTER_HEALTH
	else:
		health = alraune.stats.health * 1.0 / alraune.REGULAR_HEALTH
	sprite.region_rect.size.x = max(health * 100, 0)