extends State

class_name CounterState

func _ready():
	play_attack_animation("counter")
	create_invincibility_timer(character.counterInvincibilityFrames)
	character.bufferedCounterDamage *= character.counterDamageMultiplier
	
func setup(change_state, animationPlayer, character):
	.setup(change_state, animationPlayer, character)
	character.currentAttack = GlobalVariables.CharacterAnimations.COUNTER

func _physics_process(delta):
	pass
