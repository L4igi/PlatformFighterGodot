extends "res://Characters/Character.gd"

var specialCaseAttacks = [GlobalVariables.CharacterAnimations.DAIR]

# Called when the node enters the scene tree for the first time.
func _ready():
	#assign inputs to players
	
	set_base_stats()
	
#	animationPlayer = $AnimatedSprite/AnimationPlayer
	
func set_base_stats():
	weight = 2.0
	baseWalkMaxSpeed = 300
	walkMaxSpeed = 300
	runMaxSpeed = 600
	baseRunMaxSpeed = 600
	jabCombo = 1

func apply_attack_movement_stats(step = 0):
	match currentAttack:
		GlobalVariables.CharacterAnimations.DAIR: 
			manage_dair(step)
		GlobalVariables.CharacterAnimations.DASHATTACK:
			manage_dash_attack(step)
	
func manage_dair(step):
	match step:
		0:
			velocity = Vector2.ZERO
			gravity_on_off("off")
			disableInputDI = false
		1:
			gravity_on_off("on")
			animationPlayer.stop(false)
			bufferAnimation = true


func check_special_case_attack():
	if specialCaseAttacks.has(currentAttack):
		if currentAttack == GlobalVariables.CharacterAnimations.DAIR: 
			switch_to_state(CharacterState.ATTACKGROUND)
		return true
	return false

func manage_dash_attack(step):
	pass
