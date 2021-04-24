extends "res://Characters/Character.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	up = GlobalVariables.controlsP2.get("up")
	down = GlobalVariables.controlsP2.get("down")
	left = GlobalVariables.controlsP2.get("left")
	right = GlobalVariables.controlsP2.get("right")
	shield = GlobalVariables.controlsP2.get("shield")
	jump = GlobalVariables.controlsP2.get("jump")
	attack = GlobalVariables.controlsP2.get("attack")
	shield = GlobalVariables.controlsP2.get("shield")
	grab = GlobalVariables.controlsP2.get("grab")
	
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
			state.gravity_on_off("off")
			character.disableInputDI = false
		1:
			state.gravity_on_off("on")
			animationPlayer.stop(false)
			
func manage_dash_attack(step):
	pass
