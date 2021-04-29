extends State

class_name HitStunAirState
var bounceDegreeThreashold = 0.35
var techTimer = null 
var techCoolDownTimer = null
var techWindowFrames = 11.0
var techCooldownFrames = 40.0
var teched = false
var hitStunMaxFallSpeed = 3000
var hitStunStopForce = 1000
var hitStunGravity = 1000
var hitStunIncreaseValue = 50
var hitlagDone = false

func _ready():
	techTimer = GlobalVariables.create_timer("on_tech_timeout", "TechTimer", self)
	techCoolDownTimer = GlobalVariables.create_timer("on_techCooldown_timeout", "TechCooldownTimer", self)
	create_hitlagAttacked_timer(character.bufferHitLagFrames)
	
func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	inLandingLag = false
	animationPlayer.get_parent().set_animation("hurt")
	animationPlayer.get_parent().set_frame(0)
	character.jumpCount = 1
	character.canGetEdgeInvincibility = true
	character.onSolidGround = null
	character.disabledEdgeGrab = true
	character.edgeGrabShape.set_deferred("disabled", true)
	CharacterInteractionHandler.remove_ground_colliding_character(character)
	character.airdodgeAvailable = true
	hitStunStopForce = 1000
	hitStunGravity = 1000

func switch_to_current_state_again(transitionBufferedInput):
	hitStunTimer.stop()
	hitStunTimerDone = true
	create_hitlagAttacked_timer(character.bufferHitLagFrames)
	inLandingLag = false
	character.jumpCount = 1
	character.canGetEdgeInvincibility = true
	character.onSolidGround = null
	character.disabledEdgeGrab = true
	character.edgeGrabShape.set_deferred("disabled", true)
	CharacterInteractionHandler.remove_ground_colliding_character(character)
	character.airdodgeAvailable = true
	hitStunStopForce = 1000
	hitStunGravity = 1000
	hitlagDone = false
	.switch_to_current_state_again(transitionBufferedInput)

func handle_input(_delta):
	if hitStunTimerDone:
		if Input.is_action_just_pressed(character.attack):
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		elif Input.is_action_just_pressed(character.special):
			if Input.is_action_pressed(character.jump):
				double_jump_attack_handler()
			character.change_state(GlobalVariables.CharacterState.SPECIALAIR)
		elif Input.is_action_just_pressed(character.jump):
			double_jump_handler()
			character.change_state(GlobalVariables.CharacterState.AIR)
		elif Input.is_action_just_pressed(character.shield)\
		&& !techTimer.get_time_left() && !techCoolDownTimer.get_time_left():
			create_tech_timer(techWindowFrames)

func handle_input_disabled(_delta):
	if Input.is_action_just_pressed(character.shield)\
	&& !techTimer.get_time_left() && !techCoolDownTimer.get_time_left():
		create_tech_timer(techWindowFrames)
#		&& !techTimer.timer_running() && !techCoolDownTimer.timer_running():
#			create_frame_timer(GlobalVariables.TimerType.TECHTIMER, techWindowFrames)
#			print("tech")
	
func _physics_process(_delta):
	if !stateDone:
		if character.velocity.y < 0.0: 
			character.set_collision_mask_bit(1,false)
		elif character.velocity.y >= 0.0: 
			character.set_collision_mask_bit(1,true)
		if character.velocity.y != 0:
			character.lastVelocity = character.velocity
		if character.disableInput:
			process_movement_physics_air(_delta)
		if !hitlagDone:
			character.hitlagDI = Vector2(get_input_direction_x(), get_input_direction_y())
		elif hitlagDone:
			if character.disableInput && !hitStunTimerDone:
				handle_input_disabled(_delta)
				if character.shortHitStun: 
					return
				if character.airTime <= 300: 
					character.airTime += 1
			elif !character.disableInput:
				handle_input(_delta)
				input_movement_physics(_delta)
			if handle_character_bounce():
				pass
			else:
				check_hitStun_transition()


func process_movement_physics_air(_delta):
#	print(character.velocity)
	character.velocity.y += character.gravity * _delta
	character.velocity.x = move_toward(character.velocity.x, 0.0, 1000*_delta)
	character.velocity = character.move_and_slide(character.velocity)    


func check_hitStun_transition():
	if hitStunTimerDone:
		var solidGroundCollision = check_ground_platform_collision()
		if solidGroundCollision:
			character.onSolidGround = solidGroundCollision
			if !handle_tech(Vector2(0,-1)):
				play_animation("hurtTransition")
				character.change_state(GlobalVariables.CharacterState.HITSTUNGROUND)

				
func handle_character_bounce():
	if character.get_slide_count():
		var collision = character.get_slide_collision(0)
		var collisionNormal = collision.get_normal()
		if (attackedInitLaunchAngle >= 0.5*PI-bounceDegreeThreashold && attackedInitLaunchAngle <= 0.5*PI+bounceDegreeThreashold)\
		|| (collision.collider.is_in_group("Ground") && collisionNormal != Vector2(0,-1)):
			if collision:
				if character.lastBounceCollision:
					if (collisionNormal.y/abs(collisionNormal.y)) == (character.lastBounceCollision.get_normal().y/abs(character.lastBounceCollision.get_normal().y)):
						return false
				character.lastBounceCollision = collision
				if handle_tech(collisionNormal):
					return false
				character.velocity = Vector2(character.lastVelocity.x,character.lastVelocity.y)
				character.velocity = character.velocity.bounce(collisionNormal)*character.bounceReduction
				character.initLaunchVelocity = character.velocity
				return true
	return false
	
func handle_tech(collisionNormal):
	if techTimer.get_time_left() && character.airTime > 1:
		techTimer.stop()
		character.velocity = Vector2.ZERO
		#change to TechGround/Techair
		if collisionNormal != Vector2(0,-1):
			character.change_state(GlobalVariables.CharacterState.TECHAIR)
		else:
			character.change_state(GlobalVariables.CharacterState.TECHGROUND)
		return true
	return false

func on_hitlagAttacked_timeout():
	.on_hitlagAttacked_timeout()
	character.calculate_hitlag_di()
	print(character.name)
	print(character.backUpHitStunTime)
	create_hitStun_timer(character.backUpHitStunTime)
	if character.shortHitStun:
		play_animation("hurt_short")
	else:
		play_animation("hurt")
	hitlagDone = true
		
func input_movement_physics(_delta):
	# Horizontal movement code. First, get the player's input.
	var xInput = get_input_direction_x()
	var walk = character.airMaxSpeed * xInput
	var previousVelocity = character.velocity
	# Slow down the player if they're not trying to move.
	if xInput == 0:
		if character.pushingCharacter == null:
			if abs(character.velocity.x) > character.airMaxSpeed:
				character.velocity.x = move_toward(character.velocity.x, 0, character.airStopForce*4 * _delta)
			else:
				character.velocity.x = move_toward(character.velocity.x, 0, character.airStopForce * _delta)
	else:
		#make sure that player moves up ground slope if jumping or recovering
		if character.state.check_stage_slide_collide():
			character.velocity.x = move_toward(character.velocity.x, 0, character.airStopForce * _delta)
		else:
			character.velocity.x += (walk * _delta) 
#			if abs(previousVelocity.x) > character.airMaxSpeed:
#				character.velocity.x = clamp(character.velocity.x, -previousVelocity.x, previousVelocity.x)
#			else:
			character.velocity.x = clamp(character.velocity.x, -character.airMaxSpeed, character.airMaxSpeed)
	calculate_vertical_velocity(_delta)
	character.velocity = character.move_and_slide(character.velocity)
#	print(character.velocity)
	
	
func create_tech_timer(waitTime):
	teched = true
	GlobalVariables.start_timer(techTimer, waitTime)
	
func on_tech_timeout():
	teched = false
	create_techCooldown_timer(techCooldownFrames)
	
func create_techCooldown_timer(waitTime):
	GlobalVariables.start_timer(techCoolDownTimer, waitTime)
	
func on_techCooldown_timeout():
	pass
	
func on_hitstun_timeout():
	.on_hitstun_timeout()
	character.edgeGrabShape.set_deferred("disabled", false)
	character.airdodgeAvailable = true

