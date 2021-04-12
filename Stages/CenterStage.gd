extends KinematicBody2D


onready var stopAreaRight = $StopAreas/StopAreaRight
onready var stopAreaLeft = $StopAreas/StopAreaLeft
onready var edgeAreaLeft = $EdgeSnapLeft
onready var edgeAreaRight = $EdgeSnapRight
onready var checkYPoint = $CheckYPoint
var collidingBodies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	stopAreaRight.set_position(Vector2(445,-30))
	stopAreaLeft.set_position(Vector2(-445,-30))
	edgeAreaLeft.set_position(Vector2(-447,-15))
	edgeAreaLeft.edgeSnapDirection = "left"
	edgeAreaRight.set_position(Vector2(447,-15))
	edgeAreaRight.edgeSnapDirection = "right"


func _on_StopAreaRight_area_entered(area):
	if area.is_in_group("CollisionArea"):
		stop_character_velocity(area)


func _on_StopAreaLeft_area_entered(area):
	if area.is_in_group("CollisionArea"):
		stop_character_velocity(area)

func stop_character_velocity(area):
	var stopCharacter = area.get_parent().get_parent()
	if stopCharacter.state.get_input_direction_x() == 0:
		if stopCharacter.onSolidGround: 
			if self.global_position < stopCharacter.global_position: 
				stopCharacter.velocity.x = 200
			else:
				stopCharacter.velocity.x = -200
#
#func _on_CollisisionDetectionArea_body_entered(body):
#	if body.is_in_group("Character"):
#		collidingBodies.append(body)
#
#
#func _on_CollisisionDetectionArea_body_exited(body):
#	if body.is_in_group("Character"):
#		collidingBodies.erase(body)
#		body.onSolidGround = null
