extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var character = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	self


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass




func _on_NeutralSpot_body_entered(body):
	if body == character:
		pass
	elif body.is_in_group("Character"):
		match character.currentMoveDirection:
			character.moveDirection.RIGHT:
				body.apply_force(500, Vector2(1,-1))
			character.moveDirection.LEFT:
				body.apply_force(-500, Vector2(1,1))
