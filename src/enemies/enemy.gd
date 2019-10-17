extends KinematicBody2D
class_name Enemy

const UP = Vector2(0, -1)

onready var death_sound = null

enum State {IDLE, PATROL, CHASE, ATTACK, TAKE_DAMAGE, DYING, TAKE_DAMAGE, DIALOGUE, DEATH}

export(bool) var invincible = false

export(int) var HEALTH = 10

export (int) var ATTACK = 1

export(bool) var moves = true
export(bool) var only_chases = false

export(float) var ATTACK_COOLDOWN = 1.0

export var CHASE_SPEED = 150
export var PATROL_SPEED = 100
export var SPEED = 100
export var FRICTION = 0
export var GRAVITY = 10
export var MAX_GRAVITY = 1000

var state = State.PATROL

var can_attack: bool = true

signal animation_event


## Vector Variables and ETC ##
var motion: Vector2 = Vector2(0, 0)


## Nodes variables ##
onready var animation_player = $AnimationPlayer
onready var sprite = $AnimatedSprite

onready var rays = {
	"up": $RayCasts/Up,
	"down": $RayCasts/Down,
	"right": $RayCasts/Right,
	"left": $RayCasts/Left,
	"right_corner": $RayCasts/RightCorner,
	"left_corner": $RayCasts/LeftCorner
}

onready var detection_zone = $DetectionZone

onready var hit_detection_area = $AttackDetectionArea
onready var touch_damage_area = $TouchDamageArea

onready var attack_hit_boxes = {
	"attack": $Hitboxes/Attack
}

onready var attack_timer = $AttackTimer as Timer

var stats = {
	"health": 1,
}


var chasing = null


func play_effect(effect: String):
	AudioEngine.play_positioned_effect(effect, global_position)

func activate():
	if state != State.DEATH:
		if chasing:
			state = State.CHASE
		else:
			state = State.PATROL


func deactivate():
	if state != State.DEATH:
		state = State.IDLE

func check_touch_damage():
	if state == State.DEATH or state == State.DYING:
		return
		
	if touch_damage_area.overlaps_body(chasing):
		chasing.take_enemy_damage(1)

func _ready():
	detection_zone.connect("body_entered", self, "_on_body_entered")
	detection_zone.connect("body_exited", self, "_on_body_exited")
	stats.health = HEALTH
	
	attack_timer.connect("timeout", self, "_on_attack_timer_timeout")
		
	randomize()
	set_physics_process(false)
	_initialize()
	set_physics_process(true)
	
func _on_body_entered(body):
	if body is Player:
		set_chase(body)
				
func _on_body_exited(body):
	if body is Player:
		set_patrol()
	
func _on_attack_timer_timeout():
	can_attack = true

func reboot_horizontal_motion():
	var math = [1,-1]
	var pick_math = math[randi() % math.size()]
	motion.x = (pick_math * SPEED)

func restore_speed():
	if motion.x > 0:
		if motion.x < SPEED:
			motion.x  = SPEED
	elif motion.x < 0:
		if motion.x > -SPEED:
			motion.x  = -SPEED

func is_alive():
	return stats.health > 0
	
func set_patrol():
	chasing = null
	if state == State.CHASE:
		state = State.PATROL
	
func set_chase(player):
	chasing = player
	if state == State.PATROL:
		state = State.CHASE
	
	
func _initialize():	
	# random placement
	reboot_horizontal_motion()

func take_damage(damage: int):
	if invincible:
		return
		
	if is_alive():
		stats.health -= damage
		
		if not is_alive():
			_die()
		else:
			if state != State.ATTACK:
				motion.x = 0
				state = State.TAKE_DAMAGE
				sprite.play("take_damage")
				yield(sprite, "animation_finished")
				
				if chasing:
					state = State.CHASE
				else:
					state = State.PATROL

func play_attack_timer():
	can_attack = false
	var timeout = ATTACK_COOLDOWN * (1 + (-0.5 + randf()) * 0.1)
	attack_timer.start(timeout)


func _die():
	if animation_player.is_playing():
		animation_player.stop(true)
		
	if death_sound:
		play_effect(death_sound)
		
	$CollisionShape2D.shape = null

	# disables collision
	for child in touch_damage_area.get_children():
		if child is CollisionShape2D:
			child.set_disabled(true)

	motion.x = 0
	state = State.DYING
	
	sprite.play("death")
	yield(sprite, "animation_finished")

	state = State.DEATH
	set_physics_process(false)

#	sprite.hide()
#	yield(get_tree().create_timer(0.1),"timeout")


func horizontal_patrol():
	if not rays.right_corner.is_colliding() || not rays.left_corner.is_colliding():
		var move_direction = int(rays.right_corner.is_colliding()) - int(rays.left_corner.is_colliding())
		motion.x = SPEED * move_direction
	
	if rays.right.is_colliding() || rays.left.is_colliding():
#		print(rays.right.get_collider(), rays.left.get_collider(), self)
		var move_direction = int(rays.right.is_colliding()) - int(rays.left.is_colliding())
		motion.x = -SPEED * move_direction
		
func get_chasing_direction():
	if chasing:
		var distance = chasing.global_position.x - global_position.x
		if abs(distance) < 2:
			return 0
		return sign(distance)
		
	
func chase():
	SPEED = CHASE_SPEED
	if motion.x == 0:
		reboot_horizontal_motion()
		
	restore_speed()
	
	motion.x = get_chasing_direction() * SPEED
	
	if only_chases:
		rays.right_corner.force_raycast_update()
		rays.left_corner.force_raycast_update()
	
	if motion.x > 0 and !rays.right_corner.is_colliding():
		motion.x = 0
	elif motion.x < 0 and !rays.left_corner.is_colliding():
		motion.x = 0
	
	if hit_detection_area.overlaps_body(chasing):
		attack()
	
func attack():
	print("Should attack")
	if can_attack:
		motion.x = 0
		
		state = State.ATTACK
		
		animation_player.play("attack")
		yield(animation_player, "animation_finished")
		play_attack_timer()
		
		if chasing:
			state = State.CHASE
		else:
			state = State.PATROL
			

func set_animation():
	if state == State.PATROL or state == State.CHASE:
		if sprite.animation != "walk":
			sprite.play("walk")
			
		if not rays.right_corner.is_colliding() and motion.x == 0:
			sprite.play("idle")
		elif not rays.left_corner.is_colliding() and motion.x == 0:
			sprite.play("idle") 
			
	elif state == State.IDLE:
		if sprite.animation != "idle":
			sprite.play("idle")

func set_orientation():
	if motion.x < 0:
		hit_detection_area.scale.x = -1
		hit_detection_area.scale.x = -1
		hit_detection_area.scale.x = -1
		sprite.scale.x = -1
		for hitbox in attack_hit_boxes.values():
			hitbox.scale.x = -1
	elif motion.x > 0:
		hit_detection_area.scale.x = 1
		hit_detection_area.scale.x = 1
		hit_detection_area.scale.x = 1
		sprite.scale.x = 1
		for hitbox in attack_hit_boxes.values():
			hitbox.scale.x = 1


func patrol():	
	SPEED = PATROL_SPEED
	if motion.x == 0:
		reboot_horizontal_motion()
		
	restore_speed()
	
	horizontal_patrol()

func check_hit_player(hitbox_name: String):
	"""Should be called during animations with a relevant area2d to check for other body inside."""
	if chasing:
		var hitbox = attack_hit_boxes[hitbox_name]
		if hitbox.overlaps_body(chasing):
			chasing.take_enemy_damage(1)