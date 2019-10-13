extends KinematicBody2D
class_name Player

# Signals
signal upgrade_gained
signal health_lost
signal reset_health
signal death

# Constants
const DASH_DIST = 450
const SLOPE_SLIDE_STOP = 4
const SNAP_DOWN = Vector2(0, 48)
const SNAP_ANGLE = 1.55
const FRIC = 1
const GRAV = 10
const GRAV_CAP = 1000

# Stats that can change with upgrades
var ACCEL = 200
var JUMP_SPEED = -230
var DOUBLE_JUMP_SPEED = (JUMP_SPEED * 0.925)

onready var effect_player = AudioEngine.effects.effect_players[9]

# Instance variables
var hp : int = 1
var hp_current : int = 1

enum State {IDLE, RUN, ATTACK, JUMP, TAKE_DAMAGE, DYING, REVIVING, DIALOGUE, DASH}
var state = State.IDLE

# jump related
var in_air : bool
var remaining_jumps : int = 2

var last_checkpoint

var speed = 0

var invincible = false

# Upgrades the player can collect over time
var upgrades = {
	"double_jump" : false,
	"dash" : false
}

# Player sprite elements
var motion: Vector2 = Vector2()
onready var animation_player = $AnimationPlayer
onready var sprites = $AnimatedSprite
onready var hitboxes = {}

var jump_boosting = false
var jump_boost_speed = 0

var spawn_location: Vector2 = Vector2(0, 0)


func check_hit_enemies(hitbox: NodePath):
	for body in get_node(hitbox).get_overlapping_bodies():
		if body.is_in_group("enemies"):
			body.take_damage(5)

func _ready():
	
	# Setup player stats
	hp = 4
	hp_current = hp
	
	# Create an initial point to teleport to on death
	spawn_location = position
	
	# Connect signals to health bar
	var health_bar = get_node("/root/Game/UI/Overlay/HealthBar")
	connect("upgrade_gained", health_bar, "_on_upgrade_gained")
	connect("health_lost", health_bar, "_on_health_lost")
	connect("reset_health", health_bar, "_on_health_reset")
	
func start_dialogue():
	state = State.DIALOGUE

func end_dialogue():
	state = State.IDLE

func _physics_process(delta):
	if state == State.DASH:
		return
	
	_gravity(delta)
		
	if state == State.TAKE_DAMAGE:
		motion = move_and_slide(motion, Vector2.UP, true)
		return
	if state == State.DIALOGUE:
		update_animation()
		motion.x = 0
		motion = move_and_slide(motion, Vector2.UP, true)
		return
	if state == State.ATTACK:
		return
	if state == State.DYING:
		motion.x = 0
		motion = move_and_slide(motion, Vector2.UP, true)
		return 
	if state == State.REVIVING:
		motion.x = 0
		motion = move_and_slide(motion, Vector2.UP, true)
		return
	
	if is_on_floor():
		in_air = false
		_reset_jumps()
	else:
		in_air = true
		
	if state == State.IDLE or state == State.RUN or state == State.JUMP:
		update_animation()
		set_orientation()
		process_controls(delta)
		
		motion = move_and_slide(motion, Vector2.UP, true)

	debug_actions()

func debug_actions():	
	if Input.is_action_just_pressed("debug_death"):
		_player_death()
	
	if Input.is_action_just_pressed("debug_upgrade"):
		toggle_upgrades()
		
	# Doesn't do the trick
	# motion.y = max(motion.y, JUMP_SPEED)

func _check_HP():
	
	if hp_current <= 0:
		_player_death()

# Reset the number of jumps the player has, called when player hits floor
func _reset_jumps():
	if upgrades["double_jump"]:
		remaining_jumps = 2
	else:
		remaining_jumps = 1

func wait_for_animation(animation: String):
	sprites.play(animation)
	yield(sprites, "animation_finished")

func _player_death():
	# Death animation
	state = State.DYING
	wait_for_animation("die")
	yield(get_tree().create_timer(1),"timeout")
	
	# Teleport player back to last checkpoint
	if last_checkpoint != null:
		position = last_checkpoint.position
	
	state = State.REVIVING
	# Reset health and anim
	hp_current = hp
	wait_for_animation("revive")
	emit_signal("death")
	emit_signal("reset_health")
	state = State.IDLE

func play_effect(effect: String):
	effect_player.play_effect(effect, global_position)

func update_animation():
	match state:
		State.DIALOGUE:
			if is_on_floor():
				sprites.play("idle")
		State.IDLE:
			sprites.play("idle")
		State.RUN:
			sprites.offset.x = 0
			sprites.play("walk")
		State.JUMP:
			sprites.play("idle")
#			sprites.play("jump")

func set_orientation():
	if motion.x < 0:
		sprites.scale.x = -1
		for hitbox in hitboxes.values():
			hitbox.scale.x = -1
	if motion.x > 0:
		sprites.scale.x = 1
		for hitbox in hitboxes.values():
			hitbox.scale.x = 1

func stop_hold_jump():
	jump_boosting = false
	
func _on_fall_jump():
	remaining_jumps = max(0, remaining_jumps - 1)

func process_controls(delta):
	# Get player input
	var left_pressed = Input.is_action_pressed("ui_left")
	var right_pressed = Input.is_action_pressed("ui_right")
	var jump_pressed = Input.is_action_just_pressed("jump")
	var jump_held = not jump_pressed and Input.is_action_pressed("jump")
	var attack_pressed = Input.is_action_just_pressed("basic_attack")
	
	# x movement
	var speed_change = (int(right_pressed) - int(left_pressed)) * ACCEL * delta * 12
	if sign(motion.x) != sign(speed_change):
		motion.x = speed_change
	else:
		motion.x += speed_change
	
	if in_air and right_pressed == left_pressed:
		motion.x = 0
	if not in_air and right_pressed == left_pressed:
		motion.x = 0
		state = State.IDLE
	else:
		speed = ACCEL
		if (left_pressed or right_pressed) and not in_air:
			state = State.RUN
	
	motion.x = clamp(motion.x, -ACCEL, ACCEL)
	
	# y movement
	if jump_boosting and not jump_held:
		jump_boosting = false
	
	if jump_pressed:			
		if remaining_jumps > 0:
			jump_boosting = true
			if upgrades["double_jump"] and in_air:
				motion.y = DOUBLE_JUMP_SPEED
			else:
				motion.y = JUMP_SPEED
			remaining_jumps -= 1
			var index = (randi() % 3) + 1
			play_effect("res://assets/audio/sfx/SFX_Jump" + str(index) + ".ogg")
			jump_boost_speed = motion.y
			get_tree().create_timer(0.45).connect("timeout", self, "stop_hold_jump")
			state = State.JUMP
		
	# jump boost by pressing
	if jump_held:
		if jump_boosting:
			motion.y = jump_boost_speed
			
	# falling shortly by for example falling off a ledge allows a jump...
	if in_air and state != State.JUMP:
		state = State.JUMP
		get_tree().create_timer(0.1).connect("timeout", self, "_on_fall_jump")
	
	if state == State.IDLE or state == State.RUN:
		if attack_pressed:
			attack()
	
	motion.normalized()
	
func attack():
	state = State.ATTACK
	wait_for_animation("attack")
	if state == State.ATTACK:
		state = State.IDLE


func take_damage_animation():
	animation_player.play("take_damage")
	state = State.TAKE_DAMAGE

func _gravity(delta):
	motion.y += GRAV
	if motion.y > GRAV_CAP:
		motion.y = GRAV_CAP


# Triggers when a new upgrade is found
func unlock_upgrade(power_gained : String):
	print("Upgrade signal received for %s" % power_gained)
	
	if upgrades.has(power_gained):
		upgrades[power_gained] = true
		emit_signal("upgrade_gained", power_gained)
	else:
		print("Error: No such upgrade as %s" % power_gained)

func can_not_take_damage():
	return invincible or state == State.DYING or state == State.REVIVING or state == State.DIALOGUE

# Called when player takes damage
func take_damage(damage : int):
	if can_not_take_damage():
		return
	# if stateMachine != "taking_damage":
	# 	stateMachine = "taking_damage"
		
	emit_signal("health_lost", damage)
	hp_current -= damage
	if hp_current <= 0:
		_player_death()
	else:
		state = State.TAKE_DAMAGE
		$AnimatedSprite.material = load("res://src/player/shader.tres")
		invincible = true
		sprites.play("damage")
		yield(get_tree().create_timer(0.45), "timeout")
		state = State.IDLE
		yield(get_tree().create_timer(0.6), "timeout")
		invincible = false
		$AnimatedSprite.material = null

func take_enemy_damage(damage: int):
	if not can_not_take_damage():
		print("Taking enemy damage...")
		if animation_player.is_playing():
			animation_player.stop(true)
		take_damage(damage)
		var direction = sprites.scale.x
		motion.y = -120
		motion.x = direction * -80
		print("motion in function", motion)
		motion = move_and_slide(motion, Vector2.UP, true)

func hit_spikes():
	if not can_not_take_damage():
		take_damage(1)
		var direction = sprites.scale.x
		motion.y = -120
		motion.x = direction * -80
		print("motion in function", motion)
		motion = move_and_slide(motion, Vector2.UP, true)

func set_checkpoint(point):
	spawn_location = point.position

# DEBUG function to test upgrades
func toggle_upgrades():
	for key in upgrades.keys():
		unlock_upgrade(key)


