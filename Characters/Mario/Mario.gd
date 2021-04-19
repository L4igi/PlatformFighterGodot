extends Character

var specialCaseAttacks = [GlobalVariables.CharacterAnimations.DAIR]

# Called when the node enters the scene tree for the first time.
func _ready():
	#assign inputs to players
	
	set_base_stats()
	
#	animationPlayer = $AnimatedSprite/AnimationPlayer
	
func set_base_stats():
	weight = 1.5
	baseWalkMaxSpeed = 300
	walkMaxSpeed = 300
	runMaxSpeed = 600
	baseRunMaxSpeed = 600
	jabCombo = 1

func apply_attack_animation_steps(step = 0):
	match currentAttack:
		GlobalVariables.CharacterAnimations.DAIR: 
			manage_dair(step)
		GlobalVariables.CharacterAnimations.DASHATTACK:
			manage_dash_attack(step)
	
func manage_dair(step):
	match step:
		0:
			velocity = Vector2.ZERO
			state.gravity_on_off("off")
			disableInputDI = false
		1:
			state.gravity_on_off("on")
			animationPlayer.stop(false)
			state.bufferedAnimation = true

func manage_dash_attack(step):
	match step: 
		0: 
			pushingAction = true
		1: 
			pushingAction = false
