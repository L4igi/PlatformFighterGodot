extends State

class_name CounterState

func _ready():
	play_attack_animation("counter")
	create_invincibility_timer(character.counterInvincibilityFrames)
	character.bufferedCounterDamage *= character.counterDamageMultiplier
	
func setup(change_state, animationPlayer, character):
	.setup(change_state, animationPlayer, character)
	character.currentAttack = GlobalVariables.CharacterAnimations.COUNTER

func handle_input_disabled(_delta):
	if !bufferedInput == null: 
		.buffer_input()
		
func manage_buffered_input():
	if character.onSolidGround:
		manage_buffered_input_ground()
	else:
		manage_buffered_input_air()
	
func _physics_process(_delta):
	if !stateDone:
		handle_input_disabled(_delta)
		if character.onSolidGround:
			process_movement_physics_air(_delta)
		else:
			process_movement_physics(_delta)
