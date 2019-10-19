extends Enemy


func _ready():	
	attack_hit_boxes = {
		"attack": $Hitboxes/Attack,
	}

func _physics_process(delta):
	if chasing:
		check_touch_damage()
	move_gravity(delta)
	set_animation()
	
	if is_alive():
		if state == State.PATROL:
			patrol()
		elif state == State.CHASE:
			chase()
		elif state == State.ATTACK:
			return
		elif state == State.DYING:
			return
			
		if not moves:
			motion.x = 0
		
		motion = move_and_slide(motion, Vector2(0, -1), true)
		
	set_orientation()
	

func move_gravity(delta):
	
	motion.y = min(motion.y + GRAVITY, MAX_GRAVITY)
	
	if rays.up.is_colliding():
		motion.y = SPEED * 0.5
	
	if rays.down.is_colliding():
		motion.y = 0

	