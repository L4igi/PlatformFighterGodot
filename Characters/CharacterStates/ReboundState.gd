extends State

class_name ReboundState

var reboundTimer = null 
var reboundFrames = 30.0

func _ready():
	hitlagTimer.stop()
	reboundTimer = create_timer("on_rebound_timeout", "ReboundTimer")
	create_rebound_timer(reboundFrames)
	play_animation("rebound")
	
	
func setup(change_state, animationPlayer, character):
	.setup(change_state, animationPlayer, character)
	hitStunTimer.stop()
	gravity_on_off("on")
	character.chargingSmashAttack = false
	character.smashAttack = null
	hitStunTimerDone = true
	animationPlayer.stop(false)
	character.velocity = Vector2.ZERO
	character.disableInput = true
	character.backUpDisableInputDI = character.disableInputDI
	character.disableInputDI = false
	
func _physics_process(_delta):
	if !stateDone:
		process_movement_physics(_delta)
		if check_in_air():
			character.change_state(GlobalVariables.CharacterState.AIR)

func create_rebound_timer(waitTime):
	start_timer(reboundTimer, waitTime)

func on_rebound_timeout():
	print("rebound timeout")
	character.disableInput = false
	character.change_state(GlobalVariables.CharacterState.GROUND)
