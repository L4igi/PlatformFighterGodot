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
