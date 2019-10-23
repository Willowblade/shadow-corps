extends KinematicBody2D
class_name Player

# Signals
signal upgrade_gained
signal health_lost
signal reset_health
signal interact
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
onready var camera = $Camera2D

export var emits_light = false
export var follow_camera = true

# Instance variables
var hp : int = 1
var hp_current : int = 1

enum State {IDLE, RUN, ATTACK, AERIAL_ATTACK, JUMP, TAKE_DAMAGE, DYING, REVIVING, DIALOGUE, DASH}
var state = State.IDLE

# jump related
var in_air : bool
var remaining_jumps : int = 2

var last_checkpoint

var speed = 0

var invincible = false

# Upgrades the player can collect over time
var upgrades = {
	"attack": true,
	"aerial_attack": true,
	"double_jump" : false,
	"dash" : false
}

# Player sprite elements
var motion: Vector2 = Vector2()
onready var animation_player = $AnimationPlayer
onready var sprites = $AnimatedSprite
onready var hitboxes = {
	"attack": $Hitboxes/Attack,
	"aerial_attack": $Hitboxes/AerialAttack,
}

var jump_boosting = false
var jump_boost_speed = 0

var spawn_location: Vector2 = Vector2(0, 0)


func check_hit_enemies(hitbox_name: String):
	var hitbox = hitboxes[hitbox_name]
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("enemies"):
			body.take_player_damage(5)

func _ready():
	if not emits_light:
		$Light2D.hide()
	# Setup player stats
	hp = 4
	hp_current = hp
	
	# Create an initial point to teleport to on death
	spawn_location = position
	
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
	
	if state == State.AERIAL_ATTACK:
		process_controls(delta)
		motion = move_and_slide(motion, Vector2.UP, true)
	
	if state == State.JUMP:
		update_animation()
		set_orientation()
		process_controls(delta)
		
		motion = move_and_slide(motion, Vector2.UP, true)
		
	if state == State.IDLE or state == State.RUN:
		update_animation()
		set_orientation()
		process_controls(delta)

		motion = move_and_slide_with_snap(motion, Vector2(0, 6), Vector2.UP, true)
		
		# motion = move_and_slide_with_snap(motion, Vector2.UP, true)

	debug_actions()


func _on_upgrade_consumed(upgrade: String):
	print("Unlocked ", upgrade, self)
	unlock_upgrade(upgrade)

func debug_actions():	
	if Input.is_action_just_pressed("debug_death"):
		_player_death()
	
	if Input.is_action_just_pressed("debug_upgrade"):
		toggle_upgrades()
		
	# Doesn't do the trick
	# motion.y = max(motion.y, JUMP_SPEED)

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
	invincible = true
	state = State.DYING
	print("waiting for animation")
	wait_for_animation("die")
	print("waited for animation")
	yield(get_tree().create_timer(1),"timeout")
	
	# Teleport player back to last checkpoint
	if last_checkpoint != null:
		position = last_checkpoint
	
	state = State.REVIVING
	# Reset health and anim
	hp_current = hp
#	wait_for_animation("revive")
	emit_signal("death")
	emit_signal("reset_health")
	state = State.IDLE
	yield(get_tree().create_timer(0.5),"timeout")
	invincible = false



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
			var run_pressed = Input.is_action_pressed("ui_run")
			if run_pressed:
				sprites.play("run")
			else:
				sprites.play("walk")
		State.JUMP:
			if sprites.animation != "jump":
				sprites.animation = "jump"
			sprites.playing = false
			if not in_air:
				sprites.frame = 0
			else:
				if abs(motion.y) < 40: 
					sprites.frame = 2
				elif motion.y > 0:
					sprites.frame = 3
				else:
					sprites.frame = 1
				

func set_orientation():
	if motion.x < -1:
		sprites.scale.x = -1
		for hitbox in hitboxes.values():
			hitbox.scale.x = -1
	if motion.x > 1:
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
	var jump_pressed = Input.is_action_just_pressed("ui_jump")
	var jump_held = not jump_pressed and Input.is_action_pressed("ui_ump")
	var attack_pressed = Input.is_action_just_pressed("ui_attack")
	var interact_pressed = Input.is_action_just_pressed("ui_interact")
	
	var run_pressed = Input.is_action_pressed("ui_run")
	if run_pressed:
		ACCEL = 250
	else:
		ACCEL = 125
	
	if interact_pressed:
		emit_signal("interact")
	
	# x movement
	var speed_change = (int(right_pressed) - int(left_pressed)) * ACCEL * delta * 12
	if sign(motion.x) != sign(speed_change):
		motion.x = speed_change
	else:
		motion.x += speed_change
		
	if not in_air and state == State.AERIAL_ATTACK:
		if animation_player.is_playing():
			animation_player.stop(true)
	
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
#			play_effect("res://assets/audio/sfx/SFX_Jump" + str(index) + ".ogg")
			jump_boost_speed = motion.y
			get_tree().create_timer(0.45).connect("timeout", self, "stop_hold_jump")
			state = State.JUMP
		
	# jump boost by pressing
	if jump_held:
		if jump_boosting:
			motion.y = jump_boost_speed
			
	# falling shortly by for example falling off a ledge allows a jump...
	if in_air and state != State.JUMP and state != State.AERIAL_ATTACK:
		state = State.JUMP
		get_tree().create_timer(0.1).connect("timeout", self, "_on_fall_jump")
	
	if state == State.IDLE or state == State.RUN:
		if attack_pressed and upgrades.attack:
			attack()
	if state == State.JUMP:
		if attack_pressed and upgrades.attack:
			aerial_attack()
	
	motion.normalized()
	
func aerial_attack():
	state = State.AERIAL_ATTACK
	animation_player.play("aerial_attack", -1, 1.7)
	yield(animation_player, "animation_finished")
	if state == State.AERIAL_ATTACK:
		state = State.IDLE
	
func attack():
	state = State.ATTACK
	animation_player.play("attack", -1, 1.7)
	yield(animation_player, "animation_finished")
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

func is_alive():
	return hp_current > 0

# Called when player takes damage
func take_damage(damage : int):
	if can_not_take_damage():
		return
	# if stateMachine != "taking_damage":
	# 	stateMachine = "taking_damage"
		
	emit_signal("health_lost", damage)
	hp_current -= damage
	if not is_alive():
		_player_death()
	else:
		state = State.TAKE_DAMAGE
		$AnimatedSprite.material = load("res://src/player/shader.tres")
		invincible = true
		sprites.play("damage")
		yield(get_tree().create_timer(0.4), "timeout")
		state = State.IDLE
		motion.x = 0
		yield(get_tree().create_timer(0.9), "timeout")
		invincible = false
		$AnimatedSprite.material = null

func take_enemy_damage(damage: int):
	if not can_not_take_damage():
		if animation_player.is_playing():
			animation_player.stop(true)
		take_damage(damage)
		if is_alive():
			var direction = sprites.scale.x
			motion.y = -80
			motion.x = direction * -60
			motion = move_and_slide(motion, Vector2.UP, true)

func set_checkpoint(point):
	spawn_location = point.position

# DEBUG function to test upgrades
func toggle_upgrades():
	for key in upgrades.keys():
		unlock_upgrade(key)


