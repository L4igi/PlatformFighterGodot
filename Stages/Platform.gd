extends KinematicBody2D


onready var stopAreaRight = $StopAreas/StopAreaRight
onready var stopAreaLeft = $StopAreas/StopAreaLeft
onready var collisionArea = $CollisionDetectionArea

var collidingBodies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	stopAreaRight.set_position(Vector2(123,-5))
	stopAreaLeft.set_position(Vector2(-123,-5))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_StopAreaRight_area_entered(area):
	if area.is_in_group("CollisionArea"):
		stop_character_velocity(area)


func _on_StopAreaLeft_area_entered(area):
	if area.is_in_group("CollisionArea"):
		stop_character_velocity(area)

func stop_character_velocity(area):
	var stopCharacter = area.get_parent().get_parent()
	if stopCharacter.get_input_direction_x() == 0:
		if stopCharacter.onSolidGround: 
			if self.global_position < stopCharacter.global_position: 
				stopCharacter.velocity.x = 200
			else:
				stopCharacter.velocity.x = -200



func _on_CollisionDetectionArea_body_entered(body):
	if body.is_in_group("Character") && !collidingBodies.has(body):
		collidingBodies.append(body)
		body.onSolidGround = true


func _on_CollisionDetectionArea_body_exited(body):
	if body.is_in_group("Character"):
		collidingBodies.erase(body)
		body.onSolidGround = false
