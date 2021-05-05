extends State

class_name AirState

#platform dropdown
var lastVelocity = Vector2.ZERO

func _ready():
	gravity_on_off("on")
	if !character.disabledEdgeGrab:
		character.edgeGrabShape.set_deferred("disabled", false)
#	character.emit_signal("character_state_changed", self, currentState)
	if character.queueFreeFall:
		character.queueFreeFall = false
		play_animation("freefall",true)
	else:
		play_animation("freefall")

func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
#	CharacterInteractionHandler.remove_ground_colliding_character(character)

func manage_buffered_input():
	manage_buffered_input_ground()

			
func handle_input(_delta):
	if Input.is_action_just_pressed(character.attack):
		if Input.is_action_pressed(character.jump):
			double_jump_attack_handler()
		character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
	elif Input.is_action_just_pressed(character.grab):
		if character.grabbedItem:
			character.grabbedItem.on_projectile_throw(GlobalVariables.CharacterAnimations.ZDROPITEM)
			character.grabbedItem = null
		else:
			#character aeral grab (link hook, samus phaser etc)
			pass
	elif Input.is_action_just_pressed(character.special):
		if Input.is_action_pressed(character.jump):
			double_jump_attack_handler()
		var changeToState = character.change_to_special_state()
		character.change_state(changeToState)
	elif Input.is_action_just_pressed(character.jump):
		double_jump_handler()
	elif Input.is_action_just_pressed(character.down) && !character.onSolidGround && int(character.velocity.y) >= 0:
		character.gravity = character.fastFallGravity
		character.maxFallSpeed = character.maxFallSpeedFastFall
	elif Input.is_action_just_pressed(character.shield):
		if character.airdodgeAvailable:
			character.change_state(GlobalVariables.CharacterState.AIRDODGE)
	elif Input.is_action_just_pressed(character.special):
		var changeToState = character.change_to_special_state()
		character.change_state(changeToState)
	elif Input.is_action_just_pressed("StopGravity"):
		if character.gravity == 0:
			gravity_on_off("on")
		else:
			gravity_on_off("off")
			character.velocity.y = 0

func handle_input_disabled(_delta):
	if !bufferedInput:
		.buffer_input()
	

func _physics_process(_delta):
	if !stateDone:
		if character.airTime <= 300: 
			character.airTime += 1
		if character.disableInput: 
			handle_input_disabled(_delta)
			process_movement_physics_air(_delta)
		elif !character.disableInput:
			handle_input(_delta)
			input_movement_physics(_delta)
			character.velocity = character.move_and_slide(character.velocity)
			# Move based on the velocity and snap to the ground.
				#Fastfall
		if character.velocity.y > 0 && get_input_direction_y() >= 0.5: 
			character.set_collision_mask_bit(1,false)
		elif character.velocity.y > 0 && get_input_direction_y() < 0.5 && character.platformCollision == null && !character.platformCollisionDisabledTimer.get_time_left():
			character.set_collision_mask_bit(1,true) 
		if get_input_direction_y() >= 0.5: 
			character.edgeGrabShape.set_deferred("disabled", true)
		elif get_input_direction_y() < 0.5 && !character.disabledEdgeGrab: 
			character.edgeGrabShape.set_deferred("disabled", false)
		var solidGroundCollision = check_ground_platform_collision(character.platformCollisionDisabledTimer.get_time_left())
		if solidGroundCollision:
			character.onSolidGround = solidGroundCollision
			character.applyLandingLag = character.normalLandingLag
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
	
