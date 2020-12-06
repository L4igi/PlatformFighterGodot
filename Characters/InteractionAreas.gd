extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var character = get_parent()
onready var collisionRayCast = $CollisionRayCast2D
var collisionObject = null
# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		collisionRayCast.add_exception(child)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	raycast_collision()

func _on_CollisionArea_area_entered(area):
	pass
#	if area.is_in_group("CollisionArea"):
#		if character.currentState == character.CharacterState.GROUND && area.get_parent().get_parent().currentState == area.get_parent().get_parent().CharacterState.GROUND:
#			character.pushingCharacter = area.get_parent().get_parent()
#			character.WALK_MAX_SPEED = 200
#			character.set_collision_mask_bit(0,true)
#		elif character.currentState == character.CharacterState.AIR && area.get_parent().get_parent().currentState == area.get_parent().get_parent().CharacterState.GROUND:
#			character.pushingCharacter = area.get_parent().get_parent()
#			character.set_collision_mask_bit(0,true)
		


func _on_CollisionArea_area_exited(area):
	pass
#	if area.is_in_group("CollisionArea"):
#		character.pushingCharacter = null
#		character.WALK_MAX_SPEED = 600
#		character.set_collision_mask_bit(0,false)

func raycast_collision():
	if collisionRayCast.is_colliding():
		var collider = collisionRayCast.get_collider()
		if collider.is_in_group("CollisionArea"):
			collisionObject = collider.get_parent().get_parent()
			collisionObject.pushingCharacter = character
			if character.get_input_direction() == 0:
				collisionObject.set_collision_mask_bit(0,true)
				character.set_collision_mask_bit(0,true)
			else: 
				collisionObject.set_collision_mask_bit(0,false)
				character.set_collision_mask_bit(0,false)
	else: 
		if collisionObject != null:
			collisionObject.pushingCharacter = null
			
