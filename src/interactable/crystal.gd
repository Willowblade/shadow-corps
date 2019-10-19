extends Interactable


enum State {BREAK1, BREAK2, BREAK3, STABLE, UPGRADE}

onready var sprites = $AnimatedSprite
var state = State.STABLE

onready var UpgradeScene = preload("res://src/interactable/Upgrade.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	sprites.play("stable")
	yield(sprites, "animation_finished")
	sprites.playing = false
	pass # Replace with function body.
	
func add_powerup():
	var upgrade = UpgradeScene.instance()
	add_child(upgrade)
	upgrade.position = Vector2(0, -12)
	print(NodeRegistry.player)
	upgrade.connect("consume", NodeRegistry.player, "_on_upgrade_consumed")

func perform_interaction():
	if state == State.STABLE:
		enabled = false
		sprites.play("break1")
		yield(sprites, "animation_finished")
		sprites.playing = false
		state = State.BREAK1
		enabled = true
		
	elif state == State.BREAK1:
		enabled = false
		sprites.play("break2")
		yield(sprites, "animation_finished")
		sprites.playing = false
		state = State.BREAK2
		enabled = true
		
	elif state == State.BREAK2:
		enabled = false
		sprites.play("break3")
		state = State.BREAK3
		yield(sprites, "animation_finished")
		sprites.playing = false
		enabled = true
		
	if state == State.BREAK3:
		enabled = false
		Transitions.fade_to_opaque(Color(1, 1, 1, 0))
		sprites.play("upgrade")
		state = State.UPGRADE
		yield(sprites, "animation_finished")
		sprites.playing = false
		$Tooltip.hide()
		yield(Transitions, "transition_completed")
		add_powerup()
		# instantiate upgrade
		Transitions.fade_to_transparant()
		yield(Transitions, "transition_completed")

	