extends State

class_name ShieldBreakState

var shieldBreakTimer = null
var shieldBreakFrames = 500.0
var shieldBreakVelocity = Vector2(0,-1000)

func _ready():
	character.characterShield.disable_shield()
	character.disableInput = true
	character.onSolidGround = null
	character.enableShieldBreakGroundCheck = false
	shieldBreakTimer = create_timer("on_shieldBreak_timeout", "ShieldBreakTimer")
	create_shieldbreak_timer(shieldBreakFrames)
	play_animation("shieldBreakStart")
	
func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
	character.velocity = shieldBreakVelocity
	character.jumpCount = 0
	character.airdodgeAvailable = true
	
func manage_buffered_input():
	if character.onSolidGround:
		manage_buffered_input_ground()
	else: 
		manage_buffered_input_air()

func handle_input():
	pass

func handle_input_disabled(_delta):
	if !bufferedInput:
		.buffer_input()
	
func _physics_process(_delta):
	if !stateDone:
		handle_input_disabled(_delta)
		process_movement_physics_air(_delta)
		if character.enableShieldBreakGroundCheck && !character.onSolidGround:
				var solidGroundCollision = check_ground_platform_collision()
				if solidGroundCollision:
					character.onSolidGround = solidGroundCollision
					character.shieldbreak_animation_step(2)
		elif character.enableShieldBreakGroundCheck && character.onSolidGround:
			if character.velocity.y > 0: 
				character.characterShield.shieldBreak_end()
				shieldBreakTimer.stop()
				if check_in_air():
					character.disableInput = false
					character.bufferMoveAirTransition = true
					character.change_state(GlobalVariables.CharacterState.AIR)
	
func create_shieldbreak_timer(waitTime):
	start_timer(shieldBreakTimer, waitTime)
	
func on_shieldBreak_timeout():
	character.characterShield.shieldBreak_end()
	if enable_player_input():
		if character.onSolidGround: 
			character.change_state(GlobalVariables.CharacterState.GROUND)
		else:
			character.change_state(GlobalVariables.CharacterState.AIR)
