extends State

class_name HitStunAirState#
var bounceDegreeThreashold = 0.35

func _ready():
	create_hitlagAttacked_timer(character.bufferHitLagFrames)
	
func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	.setup(change_state, animationPlayer, character, bufferedInput, bufferedAnimation)
	character.inLandingLag = false
	animationPlayer.get_parent().set_animation("hurt")
	animationPlayer.get_parent().set_frame(0)
	character.jumpCount = 1
	character.hitStunRayCast.set_enabled(true)
	character.canGetEdgeInvincibility = true
	character.onSolidGround = null
	character.disabledEdgeGrab = false


func handle_input():
	if !hitStunTimer.get_time_left():
		if Input.is_action_just_pressed(character.attack):
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
#			attack_handler_air(delta)
		elif Input.is_action_just_pressed(character.jump):
			character.change_state(GlobalVariables.CharacterState.AIR)

func handle_input_disabled():
	if Input.is_action_just_pressed(character.shield):
		pass
#		&& !techTimer.timer_running() && !techCoolDownTimer.timer_running():
#			create_frame_timer(GlobalVariables.TimerType.TECHTIMER, techWindowFrames)
#			print("tech")
	
func _physics_process(_delta):
	if !stateDone:
		if character.velocity.y != 0:
			character.lastVelocity = character.velocity
		if character.disableInput:
			process_movement_physics_air(_delta)
		if hitlagAttackedTimer.get_time_left():
			character.hitlagDI = Vector2(get_input_direction_x(), get_input_direction_y())
		elif !hitlagAttackedTimer.get_time_left():
			if character.disableInput && hitStunTimer.get_time_left():
				handle_input_disabled()
				if character.shortHitStun: 
					return
				if character.airTime <= 300: 
					character.airTime += 1
#				print("degrees " +str(character.hitStunRayCast.get_rotation()))
				#BOUNCING CHARACTER
				if character.hitStunRayCast.get_collider():
		#				if stageBounceCollider != hitStunRayCast.get_collider():
					character.stageBounceCollider = character.hitStunRayCast.get_collider()
					if abs(character.hitStunRayCast.get_rotation()) <= bounceDegreeThreashold || character.stageBounceCollider.is_in_group("Ground"):
						print("bounced "+ str(character.lastVelocity))
		#					if techTimer.timer_running():
		#						techTimer.stop_timer()
		#						print("TECHED in hitStun!!!")
						character.velocity = Vector2(character.lastVelocity.x,character.lastVelocity.y)
						character.velocity = character.velocity.bounce(character.hitStunRayCast.get_collision_normal())*character.bounceReduction
						character.change_hitstunray_direction(atan2(character.velocity.y, character.velocity.x))
						character.initLaunchVelocity = character.velocity
				elif character.onSolidGround:
					play_animation("hurtTransition")
					character.change_state(GlobalVariables.CharacterState.HITSTUNGROUND)
			elif !character.disableInput:
				handle_input()
				var solidGroundCollision = check_ground_platform_collision()
				if solidGroundCollision:
		#				if techTimer.timer_running():
		#					techTimer.stop_timer()
		#					print("TECHED solidGroundCollision!!!")
					character.onSolidGround = solidGroundCollision
				if !character.onSolidGround && character.hitStunRayCast.get_collider():
					character.stageBounceCollider = character.hitStunRayCast.get_collider()
					if character.velocity.y >= 0 || character.stageBounceCollider.is_in_group("Ground"):
		#					if techTimer.timer_running():
		#						print("TECHED!!!")
						character.velocity = Vector2(character.lastVelocity.x,character.lastVelocity.y)
						character.velocity = character.velocity.bounce(character.hitStunRayCast.get_collision_normal())*character.bounceReduction
						character.change_hitstunray_direction(atan2(character.velocity.y, character.velocity.x))
						character.initLaunchVelocity = character.velocity
				elif character.onSolidGround:
					play_animation("hurtTransition")
					character.change_state(GlobalVariables.CharacterState.HITSTUNGROUND)
				input_movement_physics(_delta)
				character.velocity = character.move_and_slide(character.velocity)

func on_hitlagAttacked_timeout():
	.on_hitlagAttacked_timeout()
	character.calculate_hitlag_di()
	create_hitStun_timer(character.backUpHitStunTime)
	if character.shortHitStun:
		play_animation("hurt_short")
	else:
		play_animation("hurt")
		
func input_movement_physics(_delta):
	# Horizontal movement code. First, get the player's input.
	var xInput = get_input_direction_x()
	var walk = character.airMaxSpeed * xInput
	# Slow down the player if they're not trying to move.
	if xInput == 0:
		if character.pushingCharacter == null:
			character.velocity.x = move_toward(character.velocity.x, 0, character.airStopForce * _delta)
	else:
		#make sure that player moves up ground slope if jumping or recovering
		if character.state.check_stage_slide_collide():
			character.velocity.x = move_toward(character.velocity.x, 0, character.airStopForce * _delta)
		else:
			character.velocity.x += (walk * _delta) * 4
	character.velocity.x = clamp(character.velocity.x, -character.airMaxSpeed, character.airMaxSpeed)
	calculate_vertical_velocity(_delta)
	character.velocity = character.velocity