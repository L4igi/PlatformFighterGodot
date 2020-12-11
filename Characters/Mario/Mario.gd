extends "res://Characters/Character.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#assign inputs to players
	up = GlobalVariables.controlsP1.get("up")
	down = GlobalVariables.controlsP1.get("down")
	left = GlobalVariables.controlsP1.get("left")
	right = GlobalVariables.controlsP1.get("right")
	shield = GlobalVariables.controlsP1.get("shield")
	jump = GlobalVariables.controlsP1.get("jump")
	attack = GlobalVariables.controlsP1.get("attack")
	
	set_base_stats()
	
func set_base_stats():
	weight = 1.0
	baseWalkMaxSpeed = 600
	walkMaxSpeed = 600
