extends Enemy


func _ready():
	state = State.IDLE
	
func set_animation():
	if state == State.PATROL or state == State.CHASE:
		if sprite.animation != "fly":
			sprite.play("fly")
	elif state == State.IDLE:
		if sprite.animation != "idle":
			sprite.play("idle")

func _physics_process(delta):
	if chasing:
		check_touch_damage()
	set_animation()
	
	if state == State.IDLE:
		if GRAVITY > 0:
			GRAVITY = -GRAVITY
		move_gravity(delta)
		idle()
	if state == State.PATROL:
		patrol()
	elif state == State.CHASE:
		chase()
	elif state == State.ATTACK:
		return
	elif state == State.TAKE_DAMAGE:
		motion.x = 0
		motion.y = 0
	elif state == State.DYING:
		if GRAVITY < 0:
			GRAVITY = -GRAVITY
		move_gravity(delta)
	elif state == State.DEATH:
		if GRAVITY < 0:
			GRAVITY = -GRAVITY
		move_gravity(delta)
		
	if not moves:
		motion.x = 0
	
	motion = move_and_slide(motion, Vector2(0, -1))
		
	set_orientation()
	
	
func idle():
	motion.x = 0


func patrol():
	motion.x = 0
	motion.y = 0
	
func chase():
	SPEED = CHASE_SPEED
	var difference: Vector2 = (chasing.global_position + Vector2(0, -20)) - global_position
	motion = difference.normalized()
	motion.x *= SPEED
	motion.y *= 0.8 * SPEED


func move_gravity(delta):
	
	motion.y = min(motion.y + GRAVITY, MAX_GRAVITY)
	
	if rays.up.is_colliding():
		motion.y = SPEED * 0.5
	
	if rays.down.is_colliding():
		motion.y = 0

	