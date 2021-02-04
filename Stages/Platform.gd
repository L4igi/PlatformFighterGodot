extends KinematicBody2D


onready var stopAreaRight = $StopAreas/StopAreaRight
onready var stopAreaLeft = $StopAreas/StopAreaLeft
onready var collisionArea = $CollisionDetectionArea
onready var checkYPoint = $CheckYPoint
var collidingBodies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	stopAreaRight.set_position(Vector2(123,-5))
	stopAreaLeft.set_position(Vector2(-123,-5))
	
func _physics_process(delta):
	for body in collidingBodies: 
#		if body.name == "Dark_Mario":
#			print(body.onSolidGround)
		if body.onSolidGround == null: 
			if (body.lowestCheckYPoint.global_position.y <= checkYPoint.global_position.y):
				body.onSolidGround = self
				body.set_collision_mask_bit(1,true)
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
	if body.is_in_group("Character") && body.velocity.y < 0:
		collidingBodies.append(body)
		body.set_collision_mask_bit(1,false)
	elif body.is_in_group("Character") && body.velocity.y >= 0:
		collidingBodies.append(body)


func _on_CollisionDetectionArea_body_exited(body):
	if body.is_in_group("Character"):
		collidingBodies.erase(body)
		body.onSolidGround = null
		body.set_collision_mask_bit(1,true)
