extends State

class_name AirState

#platform dropdown
var platformCollisionDisabledTimer = null
var platformCollisionDisableFrames = 30.0/60.0
var normalLandingLag = 3.0/60.0
var lastVelocity = Vector2.ZERO

func _ready():
	platformCollisionDisabledTimer = create_timer("on_platformCollisionDisabled_timeout", "PlatformCollisionDisabledTimer")
	gravity_on_off("on")
	if !character.disabledEdgeGrab:
		character.edgeGrabShape.set_deferred("disabled", false)
#	character.emit_signal("character_state_changed", self, currentState)
	if character.queueFreeFall:
		character.queueFreeFall = false
		play_animation("freefall",true)
	else:
		play_animation("freefall")
	if character.droppedPlatform: 
		character.droppedPlatform = false
		create_platformCollisionDisabled_timer(platformCollisionDisableFrames)

func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	.setup(change_state, animationPlayer, character, bufferedInput, bufferedAnimation)
#	CharacterInteractionHandler.remove_ground_colliding_character(character)

func manage_buffered_input():
	manage_buffered_input_air()

			
func handle_input():
	if Input.is_action_just_pressed(character.attack):
		character.bufferPlatformCollisionDisabledFrames = platformCollisionDisabledTimer.get_time_left()
		character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
	elif Input.is_action_just_pressed(character.jump):
		double_jump_handler()
	elif Input.is_action_just_pressed(character.down) && !character.onSolidGround && int(character.velocity.y) >= 0:
		character.gravity = character.fastFallGravity
	elif Input.is_action_just_pressed(character.shield):
		character.change_state(GlobalVariables.CharacterState.AIRDODGE)
	elif Input.is_action_just_pressed("StopGravity"):
		if character.gravity == 0:
			gravity_on_off("on")
		else:
			gravity_on_off("off")
			character.velocity.y = 0

func handle_input_disabled():
	buffer_input()
	

func _physics_process(_delta):
	if !stateDone:
		if character.airTime <= 300: 
			character.airTime += 1
		if character.disableInput: 
			handle_input_disabled()
			process_movement_physics(_delta)
		elif !character.disableInput:
			handle_input()
			input_movement_physics(_delta)
			character.velocity = character.move_and_slide(character.velocity)
			# Move based on the velocity and snap to the ground.
				#Fastfall
			if character.velocity.y > 0 && get_input_direction_y() >= 0.5: 
				character.set_collision_mask_bit(1,false)
			elif character.velocity.y > 0 && get_input_direction_y() < 0.5 && character.platformCollision == null && !platformCollisionDisabledTimer.get_time_left():
				character.set_collision_mask_bit(1,true)
		if get_input_direction_y() >= 0.5: 
			character.edgeGrabShape.set_deferred("disabled", true)
		elif get_input_direction_y() < 0.5 && !character.disabledEdgeGrab: 
			character.edgeGrabShape.set_deferred("disabled", false)
		var solidGroundCollision = check_ground_platform_collision(platformCollisionDisabledTimer.get_time_left())
		if solidGroundCollision:
			character.onSolidGround = solidGroundCollision
			character.applyLandingLag = normalLandingLag
			character.change_state(GlobalVariables.CharacterState.GROUND)
		lastVelocity = character.velocity

func input_movement_physics(_delta):
	# Horizontal movement code. First, get the player's input.
	var xInput = get_input_direction_x()
	var walk = character.airMaxSpeed * xInput
#	if character.velocity.y <= 0 && character.get_slide_count():
#		var collision = character.get_slide_collision(0)
#		if collision.get_collider().is_in_group("Ground") && collision.get_normal() != Vector2(0,1):
#			character.velocity.y += character.gravity/4 * _delta
#			character.velocity.x = move_toward(character.velocity.x, character.velocity.x, character.airStopForce * _delta)
#			character.velocity.y = lastVelocity.y
#			character.velocity.y -= character.gravity/10 * _delta
#			return
	# Slow down the player if they're not trying to move.
	if xInput == 0:
		if character.pushingCharacter == null:
			character.velocity.x = move_toward(character.velocity.x, 0, character.airStopForce * _delta)
	else:
		#make sure that player moves up ground slope if jumping or recovering
		if check_stage_slide_collide():
			character.velocity.x = move_toward(character.velocity.x, 0, character.airStopForce * _delta)
		else:
			character.velocity.x += (walk * _delta) * 4
			
	character.velocity.x = clamp(character.velocity.x, -character.airMaxSpeed, character.airMaxSpeed)
	calculate_vertical_velocity(_delta)

func create_platformCollisionDisabled_timer(waitTime):
	start_timer(platformCollisionDisabledTimer, waitTime)
	
func on_platformCollisionDisabled_timeout():
	pass
	
