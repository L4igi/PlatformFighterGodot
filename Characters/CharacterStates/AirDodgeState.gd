extends State

class_name AirDodgeState

var neutralAirDodgeDuration = 45.0/60.0
var upAirDodgeDuration = 45.0/60.0
var downAirDodgeDuration = 45.0/60.0
var leftAirDodgeDuration = 45.0/60.0
var rightAirDodgeDuration = 45.0/60.0
var directionallyUpAirDodgeDuration = 45.0/60.0
var directionallyDownAirDodgeDuration = 45.0/60.0

var airDodgeTimer = null

func _ready():
	airDodgeTimer = create_timer("on_airDodgeTimer_timeout", "AirDodgeTimer")
	get_airDodge_angle()

func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	.setup(change_state, animationPlayer, character, bufferedInput, bufferedAnimation)
	character.call_deferred("set_collision_mask_bit",1,true)
	character.edgeGrabShape.set_deferred("disabled", true)
	
func manage_buffered_input():
	print("manage buffered input tech")
	manage_buffered_input_air()
	character.velocity = Vector2.ZERO
		
func handle_input():
	pass

func handle_input_disabled():
	buffer_input()
	
func _physics_process(_delta):
	if !stateDone:
		handle_input_disabled()
		process_movement_physics_air(_delta)
		character.onSolidGround = check_ground_platform_collision()
		print(character.velocity)

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
		character.velocity = inputVector.normalized() * character.airDodgeVelocity
	else:
		character.currentAirDodgeType = GlobalVariables.AirDodgeType.NORMAL
		create_airDodge_timer(neutralAirDodgeDuration)
	
func create_airDodge_timer(waitTime):
	start_timer(airDodgeTimer, waitTime)
	
func on_airDodgeTimer_timeout():
	if character.onSolidGround:
		character.change_state(GlobalVariables.CharacterState.GROUND)
	else:
		character.change_state(GlobalVariables.CharacterState.AIR)
	
func on_invincibility_timeout():
	character.enable_disable_hurtboxes(true)
	var direction = 1
	if character.currentMoveDirection == GlobalVariables.MoveDirection.LEFT: 
		direction = -1
	character.edgeGrabShape.set_deferred("disabled", false)
