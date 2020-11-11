extends KinematicBody2D

const WALK_FORCE = 800
const WALK_MAX_SPEED = 600
const STOP_FORCE = 600
const JUMP_SPEED = 800

var jumpCount = 0
var snapEdge = false
var collidePlatforms = true
var dropDownCount = 0
var snapEdgePosition = Vector2()
var disableInput = false

var directionChange = false

var velocity = Vector2()

onready var gravity = 2000

func _physics_process(delta):
	if !disableInput:
		if !snapEdge:
			basic_movement(delta)
		else:
			snap_edge_input(delta)
	
func basic_movement(delta):
	# Horizontal movement code. First, get the player's input.
	var walk = WALK_FORCE * (Input.get_action_strength("right") - Input.get_action_strength("left"))
	# Slow down the player if they're not trying to move.
	if abs(walk) < WALK_FORCE * 0.2:
		# The velocity, slowed down a bit, and then reassigned.
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		if velocity.x >= 0 && walk < 0 || velocity.x <= 0 && walk > 0: 
			directionChange = true
			velocity.x += walk*3 * delta
		else: 
			directionChange = false
			velocity.x += walk * delta
	# Clamp to the maximum horizontal movement speed.
	velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)

	# Vertical movement code. Apply gravity.
	velocity.y += gravity * delta

	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

	# Check for jumping. is_on_floor() must be called after movement code.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -JUMP_SPEED
		jumpCount += 1
		#disables collisons with platforms if player is jumping upwards
		collidePlatforms = false
		set_collision_mask_bit(1,false)
	elif !is_on_floor() and Input.is_action_just_pressed("jump") and jumpCount == 1:
		velocity.y = -JUMP_SPEED
		jumpCount += 1
		collidePlatforms = false
		set_collision_mask_bit(1,false)
	#rests jump count when player lands back on the ground
	elif is_on_floor() and jumpCount > 0: 
		jumpCount = 0
	elif !is_on_floor() and jumpCount == 0: 
		jumpCount = 1
	
	#enable collisons with platforms if player is falling down
	if !collidePlatforms && !is_on_floor() && velocity.y >= 0: 
		collidePlatforms = true
		set_collision_mask_bit(1,true)

	if Input.is_action_just_pressed("down"):
		dropDownCount += 1
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			#print("is in group " + str(collision.get_collider().is_in_group("Platform")))
			if collision.get_collider().is_in_group("Platform") && dropDownCount >=2:
				set_collision_mask_bit(1,false)
				create_drop_platform_timer(0.3, false)
			else: 
				create_drop_platform_timer(0.5, true)
				
				
func _on_drop_platform_timeout():
	collidePlatforms = false

func _on_drop_input_timeout():
	dropDownCount = 0

#creates timer after dropping through platform to enable/diable collision
func create_drop_platform_timer(waittime,inputTimeout):
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(waittime)
	timer.autostart = true
	if inputTimeout:
		timer.connect("timeout", self, "_on_drop_input_timeout")
	else: 
		timer.connect("timeout", self, "_on_drop_platform_timeout")
	add_child(timer)
 
func snap_edge(edgePosition):
	if !is_on_floor():
		disableInput = true
		snapEdgePosition = edgePosition
		velocity = Vector2.ZERO
		var targetPosition = edgePosition + $Sprite.texture.get_size()/2
		if global_position < edgePosition:
			targetPosition = edgePosition + Vector2(-($Sprite.texture.get_size()/2).x,($Sprite.texture.get_size()/2).y)
		$Tween.interpolate_property(self, "position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		yield($Tween, "tween_all_completed")
		snapEdge = true
		disableInput = false

func snap_edge_input(delta):
	jumpCount = 0
	velocity = Vector2.ZERO
	if Input.is_action_just_pressed("down"):
		snapEdge=false
	elif Input.is_action_just_pressed("jump"):
		velocity.y = -JUMP_SPEED
		jumpCount += 1
		#disables collisons with platforms if player is jumping upwards
		collidePlatforms = false
		set_collision_mask_bit(1,false)
		snapEdge=false
	elif Input.is_action_just_pressed("left"):
		if global_position < snapEdgePosition:
			velocity.x = -WALK_MAX_SPEED/4
		else:
			pass
		snapEdge=false
	elif Input.is_action_just_pressed("right"):
		if global_position > snapEdgePosition:
			velocity.x = WALK_MAX_SPEED/4
		else: 
			pass
		snapEdge=false

func get_character_size():
	return $Sprite.texture.get_size()
	

