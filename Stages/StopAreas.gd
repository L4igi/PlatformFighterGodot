extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_StopAreaRight_area_entered(area):
	if area.is_in_group("CollisionArea"):
		stop_character_velocity(area)


func _on_StopAreaLeft_area_entered(area):
	if area.is_in_group("CollisionArea"):
		stop_character_velocity(area)

func stop_character_velocity(area):
	var stopCharacter = area.get_parent().get_parent()
	if stopCharacter.get_input_direction_x() == 0 || stopCharacter.currentState == stopCharacter.CharacterState.ATTACKGROUND:
		if stopCharacter.onSolidGround: 
			if self.global_position < stopCharacter.global_position: 
				stopCharacter.velocity.x = 200
			else:
				stopCharacter.velocity.x = -200
