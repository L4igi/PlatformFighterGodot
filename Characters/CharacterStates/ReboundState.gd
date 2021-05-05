extends State

class_name ReboundState

var reboundTimer = null 
var reboundFrames = 30.0

func _ready():
	hitlagTimer.stop()
	reboundTimer = GlobalVariables.create_timer("on_rebound_timeout", "ReboundTimer", self)
	create_rebound_timer(reboundFrames)
	play_animation("rebound")
	
	
func setup(change_state, transitionBufferedInput, animationPlayer, character):
	.setup(change_state, transitionBufferedInput, animationPlayer, character)
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
	character.currentMaxSpeed = character.baseWalkMaxSpeed
	
func handle_input_disabled(_delta):
	if !bufferedInput:
		.buffer_input()
	
func _physics_process(_delta):
	if !stateDone:
		handle_input_disabled(_delta)
		process_movement_physics(_delta)
		if check_in_air():
			character.disableInput = false
			character.change_state(GlobalVariables.CharacterState.AIR)

func create_rebound_timer(waitTime):
	GlobalVariables.start_timer(reboundTimer, waitTime)

func on_rebound_timeout():
	character.disableInput = false
	character.change_state(GlobalVariables.CharacterState.GROUND)
