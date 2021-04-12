extends Node2D

class_name State

var change_state
var animationPlayer
var character = null
var stateDone = false
#smash Attack 
var smashAttackTimer = null
var smashAttackInputFrames = 5.0/60.0
#shorthop 
var shortHopTimer = null
var shortHop = false
var shortHopWaitTime = 3.0/60.0
var inMovementLag = false
#buffer 
var bufferedInput = null
var bufferedAnimation = null
#invincibility 
var invincibilityTimer = null
var invincibilityFrames
#hitlag 
var hitlagTimer = null
var hitlagAttackedTimer = null
#hitStun 
var hitStunTimer = null
#disableInputDI
var disableInputDi = false

# Writing _delta instead of delta here prevents the unused variable warning.
func _physics_process(_delta):
	pass
	
func manage_buffered_input():
	pass
	
func manage_buffered_input_ground():
	match bufferedInput: 
		GlobalVariables.CharacterAnimations.JAB1:
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		GlobalVariables.CharacterAnimations.JUMP:
			bufferedInput = null
			process_jump()
		GlobalVariables.CharacterAnimations.GRAB:
			character.change_state(GlobalVariables.CharacterState.GRAB)
		GlobalVariables.CharacterAnimations.FSMASHR:
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		GlobalVariables.CharacterAnimations.FSMASHL:
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		GlobalVariables.CharacterAnimations.UPSMASH:
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		GlobalVariables.CharacterAnimations.DSMASH: 
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		GlobalVariables.CharacterAnimations.UPTILT:
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		GlobalVariables.CharacterAnimations.DTILT:
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		GlobalVariables.CharacterAnimations.FTILTR:
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		GlobalVariables.CharacterAnimations.FTILTL:
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
	
func manage_buffered_input_air():
	match bufferedInput: 
		GlobalVariables.CharacterAnimations.JAB1:
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		GlobalVariables.CharacterAnimations.JUMP:
			double_jump_handler()
			character.disableInput = false
#		GlobalVariables.CharacterAnimations.GRAB:
#			character.change_state(GlobalVariables.CharacterState.GRAB)
		GlobalVariables.CharacterAnimations.FSMASHR:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.FSMASHL:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.UPSMASH:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.DSMASH: 
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.UPTILT:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.DTILT:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.FTILTR:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.FTILTL:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
	bufferedInput = null
	
func handle_input():
	pass

func handle_input_disabled():
	pass
	

func process_movement_physics(_delta):
	character.velocity.x = move_toward(character.velocity.x, 0, character.groundStopForce * _delta)
	calculate_vertical_velocity(_delta)
	character.velocity = character.move_and_slide(character.velocity)
	
func process_movement_physics_air(_delta):
	character.velocity.x = move_toward(character.velocity.x, 0, character.airStopForce * _delta)
	calculate_vertical_velocity(_delta)
	character.velocity = character.move_and_slide(character.velocity)
	
func process_disable_input_direction_influence(_delta):
	if !hitlagTimer.get_time_left():
		var xInput = get_input_direction_x()
		var walk = character.airMaxSpeed * xInput
		character.velocity.x += (walk * _delta) *2
	process_movement_physics_air(_delta)

func buffer_input():
	var animationFramesLeft = int((animationPlayer.get_current_animation_length()-animationPlayer.get_current_animation_position())*60)
	if animationFramesLeft <= character.bufferInputWindow\
	|| (character.currentState == GlobalVariables.CharacterState.EDGEGETUP && animationPlayer.get_current_animation_position()*60 > 5)\
	&& bufferedInput == null: 
		if Input.is_action_just_pressed(character.attack)\
		&& get_input_direction_x() == 0 && get_input_direction_y() == 0:
			bufferedInput = GlobalVariables.CharacterAnimations.JAB1
		elif Input.is_action_just_pressed(character.jump):
			bufferedInput = GlobalVariables.CharacterAnimations.JUMP
			if character.onSolidGround: 
				create_shortHop_timer()
		elif Input.is_action_just_pressed(character.grab):
			bufferedInput = GlobalVariables.CharacterAnimations.GRAB
		elif Input.is_action_just_pressed(character.right):
			create_smashAttack_timer(smashAttackInputFrames)
			character.bufferedSmashAttack = GlobalVariables.CharacterAnimations.FSMASHR
		elif Input.is_action_just_pressed(character.left):
			create_smashAttack_timer(smashAttackInputFrames)
			character.bufferedSmashAttack = GlobalVariables.CharacterAnimations.FSMASHL
		elif Input.is_action_just_pressed(character.up):
			create_smashAttack_timer(smashAttackInputFrames)
			character.bufferedSmashAttack = GlobalVariables.CharacterAnimations.UPSMASH
		elif Input.is_action_just_pressed(character.down):
			create_smashAttack_timer(smashAttackInputFrames)
			character.bufferedSmashAttack = GlobalVariables.CharacterAnimations.DSMASH
		if smashAttackTimer.get_time_left()\
		&& Input.is_action_just_pressed(character.attack)\
		&& character.bufferedSmashAttack != null:
			if Input.is_action_pressed(character.right):
				bufferedInput = character.bufferedSmashAttack
			elif Input.is_action_pressed(character.left):
				bufferedInput = character.bufferedSmashAttack
			elif Input.is_action_pressed(character.up):
				bufferedInput = character.bufferedSmashAttack
			elif Input.is_action_pressed(character.down):
				bufferedInput = character.bufferedSmashAttack
		elif !smashAttackTimer.get_time_left() && Input.is_action_just_pressed(character.attack):
			if Input.is_action_pressed(character.right):
				bufferedInput = GlobalVariables.CharacterAnimations.FTILTR
			elif Input.is_action_pressed(character.left):
				bufferedInput = GlobalVariables.CharacterAnimations.FTILTL
			elif Input.is_action_pressed(character.up):
				bufferedInput = GlobalVariables.CharacterAnimations.UPTILT
			elif Input.is_action_pressed(character.down):
				bufferedInput = GlobalVariables.CharacterAnimations.DTILT

func _ready():
	pass

func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	smashAttackTimer = create_timer("on_smashAttack_timeout", "SmashAttackTimer")
	shortHopTimer = create_timer("on_shorthop_timeout", "ShortHopTimer")
	invincibilityTimer = create_timer("on_invincibility_timeout", "InvincibilityTimer")
	hitlagTimer = create_timer("on_hitlag_timeout", "HitLagTimer")
	hitStunTimer = create_timer("on_hitstun_timeout", "HitStunTimer")
	hitlagAttackedTimer = create_timer("on_hitlagAttacked_timeout", "HitLagAttackedTimer")
	self.change_state = change_state
	self.animationPlayer = animationPlayer
	self.character = character
	self.bufferedInput = bufferedInput
	self.bufferedAnimation = bufferedAnimation
	character.emit_signal("character_state_changed", character, character.currentState)
	reset_attributes()

func reset_attributes():
	character.shortTurnAround = false
	character.pushingAction = false
	character.perfectShieldActivated = false
	character.bufferedSmashAttack = null
	character.toggle_all_hitboxes("off")
	character.characterShield.disable_shield()
	enable_player_input()

func _unhandled_input(event):
	pass
	
func input_movement_physics(_delta):
	character.move_and_slide(character.velocity, Vector2.UP)

func create_timer(timeout_function, timerName):
	var timer = Timer.new()    
	timer.set_name(timerName)
	add_child (timer)
	timer.connect("timeout", self, timeout_function) 
	return timer
	
func start_timer(timer, waitTime, oneShot = true):
	timer.set_wait_time(waitTime)
	timer.set_one_shot(oneShot)
	timer.start()

func calculate_vertical_velocity(_delta):
	character.velocity.y += character.gravity * _delta
	if character.velocity.y >= character.maxFallSpeed: 
		character.velocity.y = character.maxFallSpeed

func get_input_direction_x():
	return Input.get_action_strength(character.right) - Input.get_action_strength(character.left)
			
func get_input_direction_y():
	return Input.get_action_strength(character.down) - Input.get_action_strength(character.up)

func gravity_on_off(status):
	if status == "on":
		character.gravity = character.baseGravity
	elif status == "off":
		character.gravity = 0
		
func check_ground_platform_collision(platformCollisionDisabledTimerRunning = 0):
	if character.velocity.y >= 0:
		var collidingWith = character.move_and_collide(Vector2(0,1), true, true, true)
		if collidingWith \
		&& ((collidingWith.get_collider().is_in_group("Platform")\
		&& platformCollisionDisabledTimerRunning == 0)\
		|| collidingWith.get_collider().is_in_group("Ground")):
			character.platformCollision = collidingWith.get_collider()
			return character.platformCollision
	return null
	
func mirror_areas():
	match character.currentMoveDirection:
		GlobalVariables.MoveDirection.LEFT:
			character.set_scale(Vector2(-1*abs(character.get_scale().x), abs(character.get_scale().y)))
		GlobalVariables.MoveDirection.RIGHT:
			character.set_scale(Vector2(-1*abs(character.get_scale().x), -1*abs(character.get_scale().y)))

func play_animation(animationToPlay, queue = false):
#	print("play " +str(animationToPlay) +str(queue))
	animationPlayer.playback_speed = 1
	character.animatedSprite.set_rotation_degrees(0.0)
	if queue:
		animationPlayer.queue(animationToPlay)
	else:
		animationPlayer.play(animationToPlay)
		
func play_attack_animation(animationToPlay, queue = false):
	character.disableInput = true
	animationPlayer.playback_speed = 1
	character.animatedSprite.set_rotation_degrees(0.0)
	if queue: 
		animationPlayer.queue(animationToPlay)
	else:
		animationPlayer.play(animationToPlay)

func check_in_air(_delta):
	var collidingWith = character.move_and_collide(Vector2(0,1), true, true, true)
	if !collidingWith:
		if shortHopTimer.get_time_left():
			bufferedInput = GlobalVariables.CharacterAnimations.JUMP
			character.change_state(GlobalVariables.CharacterState.AIR)
		else:
			character.bufferMoveAirTransition = true
			character.jumpCount = 1
			character.change_state(GlobalVariables.CharacterState.AIR)
		return true
	return false

func check_stage_slide_collide(doubleJump = false):
	if character.stageSlideCollider: 
		if (character.velocity.y <= 0 || doubleJump)\
		&& character.global_position < character.stageSlideCollider.global_position: 
			if get_input_direction_x() > 0: 
				return true
		elif (character.velocity.y <= 0 || doubleJump)\
		&& character.global_position > character.stageSlideCollider.global_position: 
			if get_input_direction_x() < 0: 
				return true
		else:
			return false


func create_smashAttack_timer(waitTime):
	start_timer(smashAttackTimer, waitTime)
	
func on_smashAttack_timeout():
#	if !inMovementLag: 
#		pass
#		check_character_crouch()
	character.bufferedSmashAttack = null

func create_shortHop_timer():
	character.disableInput = true
	start_timer(shortHopTimer, shortHopWaitTime)
			
func on_shorthop_timeout():
#	print(self.name + " shorthop timeout")
	if !bufferedInput:
		process_jump()
	shortHop = false
		
func process_jump():
#	print("no buffer input jumping")
	inMovementLag = false
	character.queueFreeFall = true
	character.jumpCount += 1
	var animationToPlay = "jump"
	if shortHop:
		character.velocity.y = -character.shortHopSpeed
	else: 
		character.velocity.y = -character.jumpSpeed
	if character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
		if inMovementLag && get_input_direction_x() > 0:
			character.velocity.x = character.airMaxSpeed
		elif get_input_direction_x() > 0:
			character.velocity.x = character.airMaxSpeed
		elif get_input_direction_x() < 0:
			animationToPlay = "backflip"
			character.velocity.x = -1*character.airMaxSpeed
	elif character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
		if inMovementLag && get_input_direction_x() < 0:
			character.velocity.x = -1 * character.airMaxSpeed
		elif get_input_direction_x() < 0:
			character.velocity.x = -1 * character.airMaxSpeed
		elif get_input_direction_x() > 0:
			animationToPlay = "backflip"
			character.velocity.x = character.airMaxSpeed
	play_animation(animationToPlay)
	character.disableInput = false
	character.change_state(GlobalVariables.CharacterState.AIR)
		
func enable_player_input():
	if bufferedInput:
		manage_buffered_input()
	elif bufferedAnimation:
		character.jabCount = 0
		animationPlayer.play()
		bufferedAnimation = false
	else:
		character.jabCount = 0
		character.disableInput = false
		character.disableInputDI = false
		#reset InteractionArea Position/Rotation/Scale to default
#		$InteractionAreas.reset_global_transform()

func check_character_crouch():
	pass
	
func create_invincibility_timer(waitTime):
	character.enable_disable_hurtboxes(false)
	start_timer(invincibilityTimer, waitTime)

func on_invincibility_timeout():
	character.enable_disable_hurtboxes(true)
	var direction = 1
	if character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT: 
		direction = -1
		
func create_hitlag_timer(waitTime):
	print(character.name +" creating hitlag timer " + str(waitTime))
	animationPlayer.stop(false)
	gravity_on_off("off")
	character.velocity = Vector2.ZERO
	character.disableInput = true
	character.backUpDisableInputDI = character.disableInputDI
	character.disableInputDI = false
	start_timer(hitlagTimer, waitTime)
		
func on_hitlag_timeout():
	gravity_on_off("on")
	character.velocity = character.initLaunchVelocity
	animationPlayer.play()
	character.disableInputDI = character.backUpDisableInputDI
#	elif currentState == CharacterState.GROUND && perfectShieldActivated:
#		initLaunchVelocity = Vector2.ZERO
#		enable_player_input()

func create_hitlagAttacked_timer(waitTime):
	print(character.name +" creating hitlagAttacked timer " + str(waitTime))
	reset_gravity()
	gravity_on_off("off")
	character.chargingSmashAttack = false
	character.smashAttack = null
	hitStunTimer.stop()
	animationPlayer.stop(false)
	character.velocity = Vector2.ZERO
	character.disableInput = true
	character.backUpDisableInputDI = character.disableInputDI
	character.disableInputDI = false
	start_timer(hitlagAttackedTimer, waitTime)
	
func on_hitlagAttacked_timeout():
	gravity_on_off("on")
	character.velocity = character.initLaunchVelocity
	animationPlayer.play()
	character.disableInputDI = character.backUpDisableInputDI
	
	
func create_hitStun_timer(waitTime):
	character.disableInput = true
	character.disableInputDI = false
	start_timer(hitStunTimer, waitTime)
	
func on_hitstun_timeout():
	character.disableInput = false
	if character.shortHitStun: 
		if character.onSolidGround:
			character.applyLandingLag = character.normalLandingLag
			character.change_state(GlobalVariables.CharacterState.GROUND)
		else:
			hitStunTimer.stop()
			character.change_state(GlobalVariables.CharacterState.AIR)
	else: 
		if character.onSolidGround && bufferedInput:
			character.applyLandingLag = character.normalLandingLag
			character.change_state(GlobalVariables.CharacterState.GROUND)
		elif !character.onSolidGround && bufferedInput:
			hitStunTimer.stop()
			character.change_state(GlobalVariables.CharacterState.AIR)
		elif !character.onSolidGround: 
			play_animation("tumble")
	
func reset_gravity():
	if character.gravity!=character.baseGravity:
		character.gravity=character.baseGravity

func check_stop_area_entered():
	if character.stopAreaEntered: 
		match character.atPlatformEdge:
			GlobalVariables.MoveDirection.RIGHT:
				match character.currentMoveDirection:
					GlobalVariables.MoveDirection.LEFT:
						character.velocity.x = 0
					GlobalVariables.MoveDirection.RIGHT:
						pass
			GlobalVariables.MoveDirection.LEFT:
				match character.currentMoveDirection:
					GlobalVariables.MoveDirection.LEFT:
						pass
					GlobalVariables.MoveDirection.RIGHT:
						character.velocity.x = 0
						

func double_jump_handler():
	if character.jumpCount < character.availabelJumps:
		character.jumpCount += 1
		var xInput = get_input_direction_x()
		play_animation("doublejump")
		reset_gravity()
		character.velocity.y = -character.jumpSpeed
		if check_stage_slide_collide(true):
			character.velocity.x = 0
		else:
			character.velocity.x = character.airMaxSpeed * xInput 
