extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var character = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_CollisionArea_area_entered(area):
	if area.is_in_group("CollisionArea"):
		if character.currentState == character.CharacterState.GROUND && area.get_parent().get_parent().currentState == area.get_parent().get_parent().CharacterState.GROUND:
			character.pushingCharacter = area.get_parent().get_parent()
			character.WALK_MAX_SPEED = 200
			character.set_collision_mask_bit(0,true)
		elif character.currentState == character.CharacterState.AIR && area.get_parent().get_parent().currentState == area.get_parent().get_parent().CharacterState.GROUND:
			character.pushingCharacter = area.get_parent().get_parent()
			character.set_collision_mask_bit(0,true)
		


func _on_CollisionArea_area_exited(area):
	if area.is_in_group("CollisionArea"):
		character.pushingCharacter = null
		character.WALK_MAX_SPEED = 600
		character.set_collision_mask_bit(0,false)
