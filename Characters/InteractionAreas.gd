extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var character = get_parent()
onready var collisionRayCast = $CollisionRayCast2D
var raycastCollisionObject = null
var areaCollisionObject = null
var firstPush = false
# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		collisionRayCast.add_exception(child)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	raycast_collision()

func _on_CollisionArea_area_entered(area):
	if area.is_in_group("CollisionArea"):
		areaCollisionObject = area.get_parent().get_parent()
		if character.currentState == character.CharacterState.GROUND && areaCollisionObject.currentState == areaCollisionObject.CharacterState.AIR:
			character.set_collision_mask_bit(0,true)
		elif character.currentState == character.CharacterState.AIR && areaCollisionObject.currentState == areaCollisionObject.CharacterState.GROUND:
			character.set_collision_mask_bit(0,true)


func _on_CollisionArea_area_exited(area):
	if area.is_in_group("CollisionArea"):
		character.set_collision_mask_bit(0,false)

func raycast_collision():
	if collisionRayCast.is_colliding():
		if firstPush == false: 
			calc_push_weight_slowdown()
			firstPush = true
		var collider = collisionRayCast.get_collider()
		if collider.is_in_group("CollisionArea"):
			if (character.currentState == character.CharacterState.GROUND \
			&& collider.get_parent().get_parent().currentState == collider.get_parent().get_parent().CharacterState.GROUND):
				raycastCollisionObject = collider.get_parent().get_parent()
				raycastCollisionObject.pushingCharacter = character
#				if character.get_input_direction() == 0:
#					raycastCollisionObject.set_collision_mask_bit(0,true)
#					character.set_collision_mask_bit(0,true)
#				else: 
#					raycastCollisionObject.set_collision_mask_bit(0,false)
#					character.set_collision_mask_bit(0,false)
	else: 
		if raycastCollisionObject != null:
			raycastCollisionObject.pushingCharacter = null
			character.walkMaxSpeed = character.baseWalkMaxSpeed
			firstPush = false
#			raycastCollisionObject.set_collision_mask_bit(0,false)
#			character.set_collision_mask_bit(0,false)

func calc_push_weight_slowdown():
	character.walkMaxSpeed /= 4
	if character.velocity.x > character.walkMaxSpeed:
		character.velocity.x = character.walkMaxSpeed * character.get_input_direction()
