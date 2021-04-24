extends Node2D

class_name State

var change_state
var animationPlayer
var character = null
var stateDone = false
#smash Attack 
var smashAttackTimer = null
var smashAttackInputFrames = 5.0
#shorthop 
var shortHopTimer = null
var shortHop = false
var shortHopWaitTime = 3.0
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
var hitStunTimerDone = true
#disableInputDI
var disableInputDi = false
var attackedInitLaunchAngle = 0
#lag
var inLandingLag = false

# Writing _delta instead of delta here prevents the unused variable warning.
func _physics_process(_delta):
	pass
	
func manage_buffered_input():
	pass
	
func manage_buffered_input_ground():
	print("Input ground was buffered " +str(GlobalVariables.CharacterAnimations.keys()[bufferedInput]))
	match bufferedInput: 
		GlobalVariables.CharacterAnimations.SHORTHOPATTACK:
			process_shorthop_attack()
		GlobalVariables.CharacterAnimations.JAB1:
			if Input.is_action_pressed(character.jump):
				process_shorthop_attack()
			else:
				character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		GlobalVariables.CharacterAnimations.JUMP:
			if Input.is_action_pressed(character.attack):
				process_shorthop_attack()
			else:
				process_jump()
				character.change_state(GlobalVariables.CharacterState.AIR)
		GlobalVariables.CharacterAnimations.GRAB:
			character.change_state(GlobalVariables.CharacterState.GRAB)
		GlobalVariables.CharacterAnimations.FSMASHR:
			character.smashAttack = GlobalVariables.CharacterAnimations.FSMASHR
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		GlobalVariables.CharacterAnimations.FSMASHL:
			character.smashAttack = GlobalVariables.CharacterAnimations.FSMASHL
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		GlobalVariables.CharacterAnimations.UPSMASH:
			character.smashAttack = GlobalVariables.CharacterAnimations.UPSMASH
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		GlobalVariables.CharacterAnimations.DSMASH: 
			character.smashAttack = GlobalVariables.CharacterAnimations.DSMASH
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
		GlobalVariables.CharacterAnimations.SHORTHOPATTACK:
			double_jump_attack_handler()
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.JAB1:
			character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		GlobalVariables.CharacterAnimations.JUMP:
			double_jump_handler()
			character.disableInput = false
			character.change_state(GlobalVariables.CharacterState.AIR)
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
		GlobalVariables.CharacterAnimations.SHIELD:
			if character.airdodgeAvailable:
				character.change_state(GlobalVariables.CharacterState.AIRDODGE)
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
	character.velocity.x = clamp(character.velocity.x, -character.airMaxSpeed, character.airMaxSpeed)
	calculate_vertical_velocity(_delta)
	character.velocity = character.move_and_slide(character.velocity)     

	
func process_disable_input_direction_influence(_delta):
	if !hitlagTimer.get_time_left():
		var xInput = get_input_direction_x()
		var walk = character.airMaxSpeed * xInput
		character.velocity.x += (walk * _delta) *4
	process_movement_physics_air(_delta)

func buffer_input():
	if Input.is_action_just_pressed(character.jump)\
	&& Input.is_action_just_pressed(character.attack):
		bufferedInput = GlobalVariables.CharacterAnimations.SHORTHOPATTACK
	elif Input.is_action_just_pressed(character.attack)\
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

func setup(change_state, animationPlayer, character):
	smashAttackTimer = create_timer("on_smashAttack_timeout", "SmashAttackTimer")
	shortHopTimer = create_timer("on_shorthop_timeout", "ShortHopTimer")
	invincibilityTimer = create_timer("on_invincibility_timeout", "InvincibilityTimer")
	hitlagTimer = create_timer("on_hitlag_timeout", "HitLagTimer")
	hitStunTimer = create_timer("on_hitstun_timeout", "HitStunTimer")
	hitlagAttackedTimer = create_timer("on_hitlagAttacked_timeout", "HitLagAttackedTimer")
	self.change_state = change_state
	self.animationPlayer = animationPlayer
	self.character = character
	self.bufferedInput = null
	self.bufferedAnimation = character.bufferedAnimation
	reset_attributes()

func reset_attributes():
	character.shortTurnAround = false
	character.pushingAction = false
	character.perfectShieldActivated = false
	character.bufferedSmashAttack = null
	character.stopAreaVelocity.x = 0
	character.currentHitBox = 1
	character.toggle_all_hitboxes("off")
	character.characterShield.disable_shield()
	character.reset_hitboxes()
	character.jabCount = 0
	if bufferedAnimation:
		animationPlayer.play()
		bufferedAnimation = null
	character.damagePercentArmour = 0.0
	character.knockbackArmour = 0.0
	character.multiHitArmour = 0.0
	character.hitsTaken = 0
	
func switch_to_current_state_again():
	print("switching to current state again " +str(GlobalVariables.CharacterState.keys()[character.currentState]))
	pass

func _unhandled_input(event):
	pass
	
func input_movement_physics(_delta):
#	character.move_and_slide(character.velocity, Vector2.UP)
	character.move_and_slide(character.velocity)

func create_timer(timeout_function, timerName):
	var timer = Timer.new()    
	timer.set_name(timerName)
	add_child (timer)
	timer.connect("timeout", self, timeout_function) 
	return timer
	
func start_timer(timer, waitTime, oneShot = true):
	timer.set_wait_time(waitTime/60.0)
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
	character.animatedSprite.set_position(Vector2(0,0))
	if queue:
		animationPlayer.queue(animationToPlay)
	else:
		animationPlayer.play(animationToPlay)
		
		
func play_attack_animation(animationToPlay, queue = false):
	character.disableInput = true
	animationPlayer.playback_speed = 1
	character.animatedSprite.set_rotation_degrees(0.0)
	character.animatedSprite.set_position(Vector2(0,0))
	if queue: 
		animationPlayer.queue(animationToPlay)
	else:
		animationPlayer.play(animationToPlay)

func check_in_air():
	if character.gravity != 0:
		if !character.get_slide_count():
			if character.velocity.x == 0: 
				character.velocity.x = character.stopAreaVelocity.x
			character.disableInput = false
			character.bufferMoveAirTransition = true
			character.jumpCount = 1
#			character.change_state(GlobalVariables.CharacterState.AIR)
			return true
	return false
	
func check_ground_platform_collision(platformCollisionDisabledTimerRunning = 0):
	if character.velocity.y >= 0 && character.get_slide_count():
		var collision = character.get_slide_collision(0)
		if ((collision.get_collider().is_in_group("Platform")\
		&& platformCollisionDisabledTimerRunning == 0)\
		|| collision.get_collider().is_in_group("Ground"))\
		&& check_max_ground_radians(collision):
			check_max_ground_radians(collision)
			character.platformCollision = collision.get_collider()
			return character.platformCollision
	return null
	
func check_max_ground_radians(collision):
	var collisionNoraml = collision.get_normal()
	var collisionNormalRadians = atan2(collisionNoraml.y, collisionNoraml.x)
	if collisionNormalRadians >= 0: 
		return false 
	return true

func check_stage_slide_collide(doubleJump = false):
	if character.stageSlideCollider: 
		if (character.velocity.y <= 0 || doubleJump)\
		&& character.global_position < character.stageSlideCollider.global_position: 
			if get_input_direction_x() >= 0: 
				return true
		elif (character.velocity.y <= 0 || doubleJump)\
		&& character.global_position > character.stageSlideCollider.global_position: 
			if get_input_direction_x() <= 0: 
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
		character.change_state(GlobalVariables.CharacterState.AIR)
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
			character.velocity.x = get_input_direction_x()*character.airMaxSpeed
		elif get_input_direction_x() > 0:
			character.velocity.x = get_input_direction_x()*character.airMaxSpeed
		elif get_input_direction_x() < 0:
			animationToPlay = "backflip"
			character.velocity.x = get_input_direction_x()*character.airMaxSpeed
	elif character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
		if inMovementLag && get_input_direction_x() < 0:
			character.velocity.x = -get_input_direction_x()*character.airMaxSpeed
		elif get_input_direction_x() < 0:
			character.velocity.x = -1 * character.airMaxSpeed
		elif get_input_direction_x() > 0:
			animationToPlay = "backflip"
			character.velocity.x = character.airMaxSpeed
	play_animation(animationToPlay)
	character.disableInput = false
	if character.velocity.x == 0: 
		character.velocity.x = character.stopAreaVelocity.x
	
func process_shorthop_attack():
	bufferedInput = null
	character.shortHopAttack = true
	inMovementLag = false
	character.queueFreeFall = true
	character.jumpCount += 1
	character.velocity.y = -character.shortHopSpeed
	if character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
		if inMovementLag && get_input_direction_x() > 0:
			character.velocity.x = get_input_direction_x()*character.airMaxSpeed
		elif get_input_direction_x() > 0:
			character.velocity.x = get_input_direction_x()*character.airMaxSpeed
		elif get_input_direction_x() < 0:
			character.velocity.x = get_input_direction_x()*character.airMaxSpeed
	elif character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
		if inMovementLag && get_input_direction_x() < 0:
			character.velocity.x = get_input_direction_x()*character.airMaxSpeed
		elif get_input_direction_x() < 0:
			character.velocity.x = get_input_direction_x()* character.airMaxSpeed
		elif get_input_direction_x() > 0:
			character.velocity.x = get_input_direction_x()*character.airMaxSpeed
	if character.velocity.x == 0: 
		character.velocity.x = character.stopAreaVelocity.x
	character.change_state(GlobalVariables.CharacterState.ATTACKAIR)
		
func enable_player_input():
	if bufferedInput:
		character.disableInput = false
		character.disableInputDI = false
		manage_buffered_input()
		return false
	elif bufferedAnimation:
		animationPlayer.play()
		bufferedAnimation = false
		return false
	else:
		character.jabCount = 0
		character.disableInput = false
		character.disableInputDI = false
		return true
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
#	character.toggle_all_hitboxes("off")
	animationPlayer.stop(false)
	gravity_on_off("off")
	character.velocity = Vector2.ZERO
	character.disableInput = true
	character.backUpDisableInputDI = character.disableInputDI
	character.disableInputDI = false
	start_timer(hitlagTimer, waitTime)
		
func on_hitlag_timeout():
	#character.toggle_all_hitboxes("on")
	gravity_on_off("on")
	character.velocity = character.initLaunchVelocity
	if character.superArmourOn:
		character.superArmourOn = false
	else:
		animationPlayer.play()
	character.disableInputDI = character.backUpDisableInputDI

func create_hitlagAttacked_timer(waitTime):
	hitlagTimer.stop()
	reset_gravity()
	gravity_on_off("off")
	character.chargingSmashAttack = false
	character.smashAttack = null
	hitStunTimer.stop()
	hitStunTimerDone = true
	animationPlayer.stop(false)
	character.velocity = Vector2.ZERO
	character.disableInput = true
	character.backUpDisableInputDI = character.disableInputDI
	character.disableInputDI = false
	start_timer(hitlagAttackedTimer, waitTime)
	
func on_hitlagAttacked_timeout():
	print("current damage " +str(character.damagePercent))
	gravity_on_off("on")
	attackedInitLaunchAngle = atan2(character.initLaunchVelocity.y, character.initLaunchVelocity.x)
	character.velocity = character.initLaunchVelocity
	animationPlayer.play()
	character.disableInputDI = character.backUpDisableInputDI
	if character.currentState == GlobalVariables.CharacterState.GROUND && character.perfectShieldActivated:
		character.initLaunchVelocity = Vector2.ZERO
		character.perfectShieldActivated = false
		play_animation("idle", true)
		enable_player_input()
	
	
func create_hitStun_timer(waitTime):
	hitStunTimerDone = false
	character.disableInput = true
	character.disableInputDI = false
	start_timer(hitStunTimer, waitTime)
	
func on_hitstun_timeout():
	hitStunTimerDone = true
	character.disableInput = false
	if character.shortHitStun: 
		if character.onSolidGround:
			character.applyLandingLag = character.normalLandingLag
			character.change_state(GlobalVariables.CharacterState.GROUND)
		else:
			hitStunTimer.stop()
			hitStunTimerDone = true
			character.change_state(GlobalVariables.CharacterState.AIR)
	else: 
		if character.currentState == GlobalVariables.CharacterState.HITSTUNAIR:
			play_animation("tumble")
	
func reset_gravity():
	if character.gravity!=character.baseGravity:
		character.gravity=character.baseGravity
		character.maxFallSpeed = character.baseFallSpeed

func check_stop_area_entered(_delta):
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
		animationPlayer.stop()
		play_animation("doublejump")
		reset_gravity()
		character.velocity.y = -character.jumpSpeed
		if check_stage_slide_collide(true):
#			character.velocity.x = 0
			character.velocity.y *=2
		else:
			character.velocity.x = character.airMaxSpeed * xInput 
			

func double_jump_attack_handler():
	if character.jumpCount < character.availabelJumps:
		character.jumpCount += 1
		var xInput = get_input_direction_x()
		reset_gravity()
		character.velocity.y = -character.jumpSpeed
		if check_stage_slide_collide(true):
#			character.velocity.x = 0
			character.velocity.y *=2
		else:
			character.velocity.x = character.airMaxSpeed * xInput 

func initialize_superarmour():
	if character.currentAttack:
		var combinedAttackDataString = GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_neutral"
		var currentAttackData = character.attackData[combinedAttackDataString]
		character.damagePercentArmour = currentAttackData["damagePercentArmour"]
		character.knockbackArmour = currentAttackData["knockbackArmour"]
		character.multiHitArmour = currentAttackData["multiHitArmour"]
		print(character.damagePercentArmour)
		
func manage_disabled_inputDI():
	if character.currentAttack:
		var combinedAttackDataString = GlobalVariables.CharacterAnimations.keys()[character.currentAttack] + "_neutral"
		var currentAttackData = character.attackData[combinedAttackDataString]
		if currentAttackData["disableInputDI"] == 0: 
			return false
	return true
