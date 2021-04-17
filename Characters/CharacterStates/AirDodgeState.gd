extends State

class_name AirDodgeState

var neutralAirDodgeDuration = 45.0
var upAirDodgeDuration = 45.0
var downAirDodgeDuration = 45.0
var leftAirDodgeDuration = 45.0
var rightAirDodgeDuration = 45.0
var directionallyUpAirDodgeDuration = 45.0
var directionallyDownAirDodgeDuration = 45.0
var currentAirDodgeDuration = 0.0

var neutralInvincibilityFrames = 27.0
var neutralInvincibilityStartFrame = 2.0
var directionalInvincibilityFrames = 20.0
var directionalInvincibilityStartFrame = 3.0

var airDodgeTimer = null
var invincibilityTimerStarted = false

var airDodgeLandingLag = 20.0

func _ready():
	airDodgeTimer = create_timer("on_airDodgeTimer_timeout", "AirDodgeTimer")
	get_airDodge_angle()
	play_animation("airdodge_neutral")

func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	.setup(change_state, animationPlayer, character, bufferedInput, bufferedAnimation)
	if character.platformCollisionDisabledTimer.get_time_left():
		character.call_deferred("set_collision_mask_bit",1,false)
	character.edgeGrabShape.set_deferred("disabled", true)
	
func manage_buffered_input():
	manage_buffered_input_air()
		
func handle_input():
	pass

func handle_input_disabled():
	buffer_input()
	
func _physics_process(_delta):
	if !stateDone:
		if disableInputDi:
			process_disable_input_direction_influence(_delta)
		handle_input_disabled()
		process_movement_physics_air(_delta)
#		character.velocity.x = move_toward(character.velocity.x, 0, character.airStopForce * _delta)
#		calculate_vertical_velocity(_delta)
#		character.velocity = character.move_and_slide(character.velocity)  
		var solidGroundCollision = check_ground_platform_collision(character.platformCollisionDisabledTimer.get_time_left())
		if solidGroundCollision:
			character.onSolidGround = solidGroundCollision
			character.applyLandingLag = airDodgeLandingLag
			character.change_state(GlobalVariables.CharacterState.GROUND)
#		print(round(airDodgeTimer.get_time_left()*60.0))
		if !invincibilityTimerStarted: 
			check_invincibilityTimer_start()
		print(character.get_collision_mask_bit(1))
		
func check_invincibilityTimer_start():
	var airDodgeFramesLeft = round(airDodgeTimer.get_time_left()*60.0)
	if airDodgeFramesLeft: 
		match character.currentAirDodgeType:
			GlobalVariables.AirDodgeType.NORMAL: 
				if currentAirDodgeDuration - airDodgeFramesLeft >= neutralInvincibilityStartFrame:
					invincibilityTimerStarted = true
					create_invincibility_timer(neutralInvincibilityFrames)
			GlobalVariables.AirDodgeType.DIRECTIONAL:
				if currentAirDodgeDuration - airDodgeFramesLeft >= directionalInvincibilityStartFrame:
					invincibilityTimerStarted = true
					create_invincibility_timer(directionalInvincibilityFrames)


func get_airDodge_angle():
	var inputVector = Vector2(get_input_direction_x(), get_input_direction_y())
	if inputVector != Vector2.ZERO:
		character.currentAirDodgeType = GlobalVariables.AirDodgeType.DIRECTIONAL
		var airDodgeRadian = atan2(inputVector.y, inputVector.x)
		if airDodgeRadian > -0.125*PI && airDodgeRadian < 0.125*PI:
			create_airDodge_timer(rightAirDodgeDuration)
		elif airDodgeRadian >= 0.125*PI && airDodgeRadian <= 0.375*PI:
			create_airDodge_timer(directionallyDownAirDodgeDuration)
		elif airDodgeRadian > 0.375*PI && airDodgeRadian < 0.625*PI:
			create_airDodge_timer(downAirDodgeDuration)
		elif airDodgeRadian >= 0.625*PI && airDodgeRadian <= 0.85*PI:
			create_airDodge_timer(directionallyDownAirDodgeDuration)
		elif airDodgeRadian > 0.85*PI || airDodgeRadian < -0.85*PI:
			create_airDodge_timer(leftAirDodgeDuration)
		elif airDodgeRadian <= -0.125*PI && airDodgeRadian >= -0.375*PI:
			create_airDodge_timer(directionallyUpAirDodgeDuration)
		elif airDodgeRadian < -0.375*PI && airDodgeRadian > -0.625*PI:
			create_airDodge_timer(upAirDodgeDuration)
		elif airDodgeRadian <= -0.625*PI && airDodgeRadian >= -0.85*PI:
			create_airDodge_timer(directionallyUpAirDodgeDuration)
		var airDodgeVelocity = inputVector.normalized() * character.airDodgeVelocity
		character.set_deferred("velocity", airDodgeVelocity)
	else:
		character.currentAirDodgeType = GlobalVariables.AirDodgeType.NORMAL
		create_airDodge_timer(neutralAirDodgeDuration)
	
func create_airDodge_timer(waitTime):
	currentAirDodgeDuration = waitTime
	start_timer(airDodgeTimer, waitTime)
	
func on_airDodgeTimer_timeout():
	if !character.onSolidGround && !bufferedInput:
		character.change_state(GlobalVariables.CharacterState.AIR)
	if character.onSolidGround && Input.is_action_pressed(character.shield):
		character.change_state(GlobalVariables.CharacterState.SHIELD)
	elif character.onSolidGround && !bufferedInput:
		character.applySideStepFrames = true
		character.change_state(GlobalVariables.CharacterState.GROUND)
	else:
		enable_player_input()
	
func on_invincibility_timeout():
	character.enable_disable_hurtboxes(true)
	var direction = 1
	if character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT: 
		direction = -1
	character.edgeGrabShape.set_deferred("disabled", false)
	disableInputDi = true
	
func process_disable_input_direction_influence(_delta):
	var xInput = get_input_direction_x()
	var walk = character.airMaxSpeed * xInput
	character.velocity.x += (walk * _delta) *2
