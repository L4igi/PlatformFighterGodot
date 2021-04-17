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
	
func setup(change_state, animationPlayer, character, bufferedInput = null, bufferedAnimation= null):
	.setup(change_state, animationPlayer, character, bufferedInput, bufferedAnimation)
	character.velocity = shieldBreakVelocity
	character.jumpCount = 0
	
func _physics_process(_delta):
	if !stateDone:
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
				check_in_air()
	
func create_shieldbreak_timer(waitTime):
	start_timer(shieldBreakTimer, waitTime)
	
func on_shieldBreak_timeout():
	character.characterShield.shieldBreak_end()
	if character.onSolidGround: 
		character.change_state(GlobalVariables.CharacterState.GROUND)
	else:
		character.change_state(GlobalVariables.CharacterState.AIR)
