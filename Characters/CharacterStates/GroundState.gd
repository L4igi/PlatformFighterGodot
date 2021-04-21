extends State

class_name GroundState

var xInput = 0
var lastXInput = 0
#stopMovement
var stopMovementFrames = 4.0
var stopMovementTimer = null
#turnAround
var slideTurnAroundFrames = 21.0
var turnAroundFrames = 6.0
var turnAroundTimer = null
#sideStep
var sideStepTimer = null
var sideStepFrames = 12.0
var countFrames = 0
#shieldDropTimer 
var perfectShieldFrames = 5
var perfectShieldFramesLeft = 5
var shieldDropTimer = null
var shiedDropFrames = 11.0
#dropDownTimer
var dropDownTimer = null
#landinglag
var landingLagTimer = null
#count last xInputs equal 0 
var lastXInputZeroCount = 0
var lastXInputSlowTurnAround = 5

func _ready():
	if character.shieldDropped:
		character.shieldDropped = false 
		create_shieldDrop_timer(shiedDropFrames)
	if character.applyLandingLag:
		switch_from_air_to_ground(character.applyLandingLag)
		character.applyLandingLag = null
	if character.applySideStepFrames: 
		character.applySideStepFrames = false
		create_sidestep_timer(sideStepFrames)
		
func setup(change_state, animationPlayer, character):
	stopMovementTimer = create_timer("on_stop_movement_timeout", "StopMovementTimer")
	turnAroundTimer = create_timer("on_turnAroundTimer_timeout", "TurnAroundTimer")
	sideStepTimer = create_timer("on_sideStep_timeout", "SideStepTimer")
	dropDownTimer = create_timer("on_dropDown_timeout", "DropDownTimer")
	shieldDropTimer = create_timer("on_shielddrop_timeout", "ShieldDropTimer")
	landingLagTimer = create_timer("on_landingLag_timeout", "LandingLagTimer")
	.setup(change_state, animationPlayer, character)
	character.canGetEdgeInvincibility = true
	character.disabledEdgeGrab = false
	reset_gravity()
	character.airTime = 0
	character.velocity.y = 0
	character.jumpCount = 0
	lastXInputZeroCount = 0
	play_animation("idle")
	character.airdodgeAvailable = true
	character.turnAroundSmashAttack = false

func manage_buffered_input():
	manage_buffered_input_ground()

func handle_input():
	if Input.is_action_just_pressed(character.jump):
		create_shortHop_timer()
		return
	elif Input.is_action_pressed(character.shield):
		if Input.is_action_just_pressed(character.attack):
			character.change_state(GlobalVariables.CharacterState.GRAB)
		else:
			character.change_state(GlobalVariables.CharacterState.SHIELD)
		return
	elif Input.is_action_just_pressed(character.grab):
		character.change_state(GlobalVariables.CharacterState.GRAB)
		return
	if !character.bufferedSmashAttack:
		if Input.is_action_just_pressed(character.right):
#			if character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
#				character.turnAroundSmashAttack = true
			create_smashAttack_timer(smashAttackInputFrames)
			character.bufferedSmashAttack = GlobalVariables.CharacterAnimations.FSMASHR
		elif Input.is_action_just_pressed(character.left):
#			if character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
#				character.turnAroundSmashAttack = true
			create_smashAttack_timer(smashAttackInputFrames)
			character.bufferedSmashAttack = GlobalVariables.CharacterAnimations.FSMASHL
		elif Input.is_action_just_pressed(character.up):
			create_smashAttack_timer(smashAttackInputFrames)
			character.bufferedSmashAttack = GlobalVariables.CharacterAnimations.UPSMASH
		elif Input.is_action_just_pressed(character.down):
			create_smashAttack_timer(smashAttackInputFrames)
			character.bufferedSmashAttack = GlobalVariables.CharacterAnimations.DSMASH
		if Input.is_action_just_pressed(character.attack):
			character.smashAttack = character.bufferedSmashAttack
			character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
	elif character.bufferedSmashAttack && smashAttackTimer.get_time_left():
		if Input.is_action_just_pressed(character.attack):
			if Input.is_action_pressed(character.right):
				if character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT:
					character.turnAroundSmashAttack = true
				character.smashAttack = character.bufferedSmashAttack
				character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
			elif Input.is_action_pressed(character.left):
				if character.currentMoveDirection == GlobalVariables.MoveDirection.RIGHT:
					character.turnAroundSmashAttack = true
				character.smashAttack = character.bufferedSmashAttack
				character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
			elif Input.is_action_pressed(character.up):
				character.smashAttack = character.bufferedSmashAttack
				character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
			elif Input.is_action_pressed(character.down):
				character.smashAttack = character.bufferedSmashAttack
				character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
	if Input.is_action_just_pressed(character.attack):
		character.change_state(GlobalVariables.CharacterState.ATTACKGROUND)
		
func handle_input_disabled():
	if !bufferedInput:
		buffer_input()
	if !inLandingLag:
		if Input.is_action_just_pressed(character.jump):
			if shieldDropTimer.get_time_left():
				shieldDropTimer.stop()
			create_shortHop_timer()
			bufferedInput = null
		if !Input.is_action_pressed(character.jump):
			if shortHopTimer.get_time_left():
				shortHop = true
				bufferedInput = null
		elif shortHopTimer.get_time_left():
			if Input.is_action_pressed(character.attack):
				bufferedInput = GlobalVariables.CharacterAnimations.SHORTHOPATTACK
#normal input 
				
func _physics_process(_delta):
	if !stateDone:
		if character.disableInput || inMovementLag:
			process_movement_physics(_delta)
			check_stop_area_entered(_delta)
			if shieldDropTimer.get_time_left():
				if perfectShieldFramesLeft > 0:
					perfectShieldFramesLeft -= 1
			check_in_air()
			if character.disableInput:
				handle_input_disabled()
			elif inMovementLag:
				handle_input()
		else:
			input_movement_physics(_delta)
			check_stop_area_entered(_delta)
			character.velocity = character.move_and_slide_with_snap(character.velocity, Vector2.DOWN, Vector2.UP)
			check_in_air()
			handle_input()
			#checks if player walked off platform/stage
		
func input_movement_physics(_delta):
	xInput = get_input_direction_x()
	if !inMovementLag:
		if xInput == 0:
			direction_changer(xInput)
			if lastXInput != 0:
				play_animation("idle")
			if character.pushingCharacter == null:
				character.resetMovementSpeed = true
				if character.velocity.x != 0: 
					character.velocity.x = move_toward(character.velocity.x, 0, character.groundStopForce * _delta)
		elif xInput != 0 && character.velocity.x != 0:
			if lastXInputZeroCount > lastXInputSlowTurnAround: 
				change_max_speed(xInput)
			if character.currentMaxSpeed == character.baseRunMaxSpeed:
				if animationPlayer.get_current_animation() == "idle":
					animationPlayer.play("run")
				if xInput > 0 && !character.pushingCharacter:
					character.velocity.x = character.currentMaxSpeed
					character.velocity.x = clamp(character.velocity.x, -character.currentMaxSpeed, character.currentMaxSpeed)
				elif xInput < 0 && !character.pushingCharacter:
					character.velocity.x = - character.currentMaxSpeed
					character.velocity.x = clamp(character.velocity.x, -character.currentMaxSpeed, character.currentMaxSpeed)
			elif character.currentMaxSpeed == character.baseWalkMaxSpeed:
				if animationPlayer.get_current_animation() == "idle":
					animationPlayer.play("walk")
				if !character.pushingCharacter:
					character.velocity.x = xInput * character.currentMaxSpeed
					character.velocity.x = clamp(character.velocity.x, -character.currentMaxSpeed, character.currentMaxSpeed)
			direction_changer(xInput)
			if character.pushingCharacter && lastXInput == 0: 
				character.resetMovementSpeed = true
		elif xInput != 0 && character.velocity.x == 0: 
			if !direction_changer(xInput, true):
				create_sidestep_timer(sideStepFrames)
				if lastXInputZeroCount > lastXInputSlowTurnAround:
					change_max_speed(xInput)
				if !character.pushingCharacter:
					character.velocity.x = xInput * character.currentMaxSpeed
					character.velocity.x = clamp(character.velocity.x, -character.currentMaxSpeed, character.currentMaxSpeed)
					character.resetMovementSpeed = false
		elif character.stopMovementTimer.timer_running():
			if !direction_changer(xInput):
				if !character.pushingCharacter:
					character.velocity.x = move_toward(character.velocity.x, 0, character.groundStopForce * _delta)
		elif character.turnAroundTimer.timer_running():
			match character.currentMoveDirection:
				GlobalVariables.moveDirection.LEFT:
					if character.velocity.x > 0:
						character.velocity.x = move_toward(character.velocity.x, 0, character.groundStopForce * _delta)
				GlobalVariables.moveDirection.RIGHT:
					if character.velocity.x < 0:
						character.velocity.x = move_toward(character.velocity.x, 0, character.groundStopForce * _delta)
	lastXInput = xInput
#	if character.bufferFTiltWalk: 
#		character.bufferFTiltWalk = false
	calculate_vertical_velocity(_delta)
	
func count_last_XInput():
	if lastXInput == 0:
		if lastXInputZeroCount <= lastXInputSlowTurnAround:
			lastXInputZeroCount += 1
	else:
		lastXInputZeroCount = 0

func direction_changer(xInput, fromIdle = false):
	count_last_XInput()
	match character.currentMoveDirection:
		GlobalVariables.MoveDirection.LEFT:
			if xInput <= 0 && xInput > lastXInput && !inMovementLag && !fromIdle:  
				#print("here left Xinput " +str(xInput) + " lastXInput " +str(lastXInput) + " inMovementLag " +str(inMovementLag))
				if character.currentMaxSpeed == character.baseRunMaxSpeed:
					create_stop_movement_timer(stopMovementFrames)
			elif xInput > 0: 
				if character.currentMaxSpeed == character.baseRunMaxSpeed\
				&& (inMovementLag || lastXInputZeroCount <= lastXInputSlowTurnAround)\
				&& !sideStepTimer.get_time_left() && !character.pushingCharacter:
					#print("Xinput " +str(xInput) + " lastXInput " +str(lastXInput) + " inMovementLag " +str(inMovementLag))
					#print("slow turn " +str(currentMaxSpeed) + " in movement lag " +str(inMovementLag) + " in slide step " + str(inSideStep))
					play_animation("turnaround_slow")
					create_turnAround_timer(slideTurnAroundFrames)
					character.currentMaxSpeed = character.baseWalkMaxSpeed
					character.velocity.x = -600
					character.shortTurnAround = false
				else: 
					#print("Xinput " +str(xInput) + " lastXInput " +str(lastXInput) + " inMovementLag " +str(inMovementLag))
					#print("fast turn " +str(currentMaxSpeed) + " in movement lag " +str(inMovementLag) + " in slide step " + str(inSideStep))
					play_animation("turnaround_fast")
					create_turnAround_timer(turnAroundFrames)
					character.velocity.x = 0
					character.shortTurnAround = true
				return true
		GlobalVariables.MoveDirection.RIGHT:
			if xInput >= 0 && xInput < lastXInput && !inMovementLag && !fromIdle:  
				#print("here right Xinput " +str(xInput) + " lastXInput " +str(lastXInput) + " inMovementLag " +str(inMovementLag))
				if character.currentMaxSpeed == character.baseRunMaxSpeed:
					create_stop_movement_timer(stopMovementFrames)
			elif xInput < 0: 
				if character.currentMaxSpeed == character.baseRunMaxSpeed\
				&& (inMovementLag || lastXInputZeroCount <= lastXInputSlowTurnAround)\
				&& !sideStepTimer.get_time_left() && !character.pushingCharacter:
					#print("Xinput " +str(xInput) + " lastXInput " +str(lastXInput) + " inMovementLag " +str(inMovementLag))
					#print("slow turn " +str(currentMaxSpeed) + " in movement lag " +str(inMovementLag) + " in slide step " + str(inSideStep))
					play_animation("turnaround_slow")
					create_turnAround_timer(slideTurnAroundFrames)
					character.currentMaxSpeed = character.baseWalkMaxSpeed
					character.velocity.x = 600
					character.shortTurnAround = false
				else: 
					#print("Xinput " +str(xInput) + " lastXInput " +str(lastXInput) + " inMovementLag " +str(inMovementLag))
					#print("fast turn " +str(currentMaxSpeed) + " in movement lag " +str(inMovementLag) + " in slide step " + str(inSideStep))
					play_animation("turnaround_fast")
					create_turnAround_timer(turnAroundFrames)
					character.velocity.x = 0
					character.shortTurnAround = true
				return true
	return false
	
func change_max_speed(xInput):
	var useXInput = xInput
	character.resetMovementSpeed = true
	CharacterInteractionHandler.initCalculations = false
	if abs(useXInput) > character.walkThreashold:
		character.currentMaxSpeed = character.baseRunMaxSpeed
		play_animation("run")
	elif abs(useXInput) == 0:
		character.currentMaxSpeed = character.baseWalkMaxSpeed
		play_animation("idle")
	else:
		character.currentMaxSpeed = character.baseWalkMaxSpeed
		play_animation("walk")
	
func create_stop_movement_timer(waitTime):
	inMovementLag = true
	start_timer(stopMovementTimer, waitTime)
	
func on_stop_movement_timeout():
	change_max_speed(get_input_direction_x())
	check_character_crouch()
	inMovementLag = false
	enable_player_input()

func create_turnAround_timer(waitTime):
	inMovementLag = true
	character.stopAreaVelocity.x = 0
	stopMovementTimer.stop()
	start_timer(turnAroundTimer, waitTime)
	lastXInputZeroCount = 0
	match character.currentMoveDirection:
		GlobalVariables.MoveDirection.LEFT:
			character.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
			mirror_areas()
		GlobalVariables.MoveDirection.RIGHT:
			character.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
			mirror_areas()

func on_turnAroundTimer_timeout():
	character.turnAroundSmashAttack = false
	character.velocity.x = 0
	check_ground_animations()
	check_character_crouch()
	create_sidestep_timer(sideStepFrames)
	inMovementLag = false
	character.shortTurnAround = false
	enable_player_input()

func create_sidestep_timer(waitTime):
	start_timer(sideStepTimer, waitTime)
	
func on_sideStep_timeout():
	pass

func create_shieldDrop_timer(waitTime):
	character.disableInput = true
	perfectShieldFramesLeft = perfectShieldFrames
	play_animation("shielddrop")
	start_timer(shieldDropTimer, waitTime)
	
func on_shielddrop_timeout():
	lastXInputZeroCount = 0
	if get_input_direction_y() >= 0.5:
		if enable_player_input():
			character.change_state(GlobalVariables.CharacterState.CROUCH)
	else:
		play_animation("idle")
		character.currentMaxSpeed = character.baseWalkMaxSpeed
		enable_player_input()
		
func check_ground_animations():
	if get_input_direction_x() == 0:
		play_animation("idle")
	else:
		change_max_speed(get_input_direction_x())

func create_dropdown_timer(waitTime):
	pass
	
func on_dropDown_timeout():
	pass

func create_landingLag_timer(waitTime):
	reset_gravity()
	inLandingLag = true
	character.disableInput = true
	character.disableInputDI = false
	start_timer(landingLagTimer, waitTime)
	
func on_landingLag_timeout():
	inLandingLag = false
	if enable_player_input():
		create_sidestep_timer(sideStepFrames)
		play_animation("idle")
		check_character_crouch()
	else:
		check_ground_animations()

func on_smashAttack_timeout():
	if !inMovementLag: 
		check_character_crouch()
	character.bufferedSmashAttack = null

func switch_from_air_to_ground(landingLag):
	create_landingLag_timer(landingLag)
	play_animation("landinglagnormal")
	match character.currentMoveDirection:
		GlobalVariables.MoveDirection.LEFT:
			if get_input_direction_x() > 0:
				character.currentMoveDirection = GlobalVariables.MoveDirection.RIGHT
				mirror_areas()
		GlobalVariables.MoveDirection.RIGHT:
			if get_input_direction_x() < 0:
				character.currentMoveDirection = GlobalVariables.MoveDirection.LEFT
				mirror_areas()

func check_character_crouch():
	if get_input_direction_y() >= 0.5 && !inMovementLag:
		for i in character.get_slide_count():
			var collision = character.get_slide_collision(i)
			if collision.get_collider().is_in_group("Platform"):
				character.onSolidGround = collision.get_collider()
				character.change_state(GlobalVariables.CharacterState.CROUCH)
				return true
			elif collision.get_collider().is_in_group("Ground"):
				character.onSolidGround = collision.get_collider()
				character.change_state(GlobalVariables.CharacterState.CROUCH)
				return true
	elif get_input_direction_y() >= 0.2:
		character.change_state(GlobalVariables.CharacterState.CROUCH)
		return true
	return false
	
func create_hitlagAttacked_timer(waitTime):
	.create_hitlagAttacked_timer(waitTime)
	shieldDropTimer.stop()
	
	
func on_hitlagAttacked_timeout():
	.on_hitlagAttacked_timeout()
	if character.perfectShieldActivated:
		character.initLaunchVelocity = Vector2.ZERO
		enable_player_input()

func on_shorthop_timeout():
	print(character.currentState)
	if shortHopTimer:
		.on_shorthop_timeout()
		inMovementLag = false
		turnAroundTimer.stop()
		enable_player_input()
		
func check_stop_area_entered(_delta):
	match character.atPlatformEdge:
		GlobalVariables.MoveDirection.RIGHT:
			if inMovementLag || get_input_direction_x() == 0 && !character.pushingCharacter:
				character.stopAreaVelocity.x = move_toward(character.stopAreaVelocity.x, 0, character.groundStopForce * _delta)
				character.velocity.x = 0
		GlobalVariables.MoveDirection.LEFT:
			if inMovementLag || get_input_direction_x() == 0 && !character.pushingCharacter:
				character.stopAreaVelocity.x = move_toward(character.stopAreaVelocity.x, 0, character.groundStopForce * _delta)
				character.velocity.x = 0
