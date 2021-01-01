extends Node2D

onready var character = get_parent()
var raycastCollisionObject = null
var areaCollisionObject = null
var collisionAreaEntered = null

var _initial_position


func _ready():
	character.connect("character_state_changed", self, "_on_character_state_change")
	_initial_position = get_transform()
	
func _on_CollisionArea_area_entered(area):
	if area.is_in_group("CollisionArea"):
		#check if colliding object is a character
		areaCollisionObject = area.get_parent().get_parent()
		collisionAreaEntered = area
		match character.currentState:
			character.CharacterState.GROUND:
				match_collision_ground(areaCollisionObject)
			character.CharacterState.AIR:
				match_collision_air(areaCollisionObject)
			character.CharacterState.EDGE:
				match_collision_edge(areaCollisionObject)
			character.CharacterState.ATTACKGROUND:
				match_collision_attackground(areaCollisionObject)
			character.CharacterState.ATTACKAIR:
				match_collision_attackair(areaCollisionObject)
			character.CharacterState.HITSTUNGROUND:
				match_collision_hitstunground(areaCollisionObject)
			character.CharacterState.HITSTUNAIR:
				match_collision_hitstunair(areaCollisionObject)
			character.CharacterState.SPECIALGROUND:
				match_collision_specialground(areaCollisionObject)
			character.CharacterState.SPECIALAIR:
				match_collision_specialair(areaCollisionObject)
			character.CharacterState.SHIELD:
				match_collision_shield(areaCollisionObject)
			character.CharacterState.ROLL:
				match_collision_roll(areaCollisionObject)
			character.CharacterState.GRAB:
				match_collision_grab(areaCollisionObject)
			character.CharacterState.INGRAB:
				match_collision_ingrab(areaCollisionObject)
			character.CharacterState.SPOTDODGE:
				match_collision_spotdodge(areaCollisionObject)
			character.CharacterState.GETUP:
				match_collision_getup(areaCollisionObject)
			character.CharacterState.SHIELDBREAK:
				match_collision_shieldbreak(areaCollisionObject)
				
			
func disable_collision():
	character.set_collision_mask_bit(0,false)

func enable_collision():
	if character.global_position.y < areaCollisionObject.global_position.y && character.velocity.y < 0:
		return
	else:
		character.pushingCharacter = areaCollisionObject
		CharacterInteractionHandler.add_ground_colliding_character(character)
		character.set_collision_mask_bit(0,true)
	
func _on_CollisionArea_area_exited(area):
	if area.is_in_group("CollisionArea"):
		character.set_collision_mask_bit(0,false)
		#set everything to base
		CharacterInteractionHandler.remove_ground_colliding_character(character)
		collisionAreaEntered = null
		character.pushingCharacter = null
#		if character.currentState == character.CharacterState.GROUND:
#			character.velocity.x = 0

func _on_character_state_change(currentState):
	if collisionAreaEntered != null: 
		if currentState == character.CharacterState.GROUND \
		|| currentState == character.CharacterState.HITSTUNGROUND \
		|| currentState == character.CharacterState.SHIELD:
			character.set_collision_mask_bit(0,true)
			character.pushingCharacter = areaCollisionObject
			areaCollisionObject.pushingCharacter = character
			CharacterInteractionHandler.add_ground_colliding_character(character)
			CharacterInteractionHandler.add_ground_colliding_character(areaCollisionObject)
		elif currentState == character.CharacterState.AIR\
		|| currentState == character.CharacterState.HITSTUNAIR\
		|| currentState == character.CharacterState.GETUP\
		|| currentState == character.CharacterState.ROLL\
		|| currentState == character.CharacterState.SPOTDODGE\
		|| currentState == character.CharacterState.GRAB:
			character.set_collision_mask_bit(0,false)
			CharacterInteractionHandler.remove_ground_colliding_character(character)
				
func reset_global_transform():
	set_transform(_initial_position)


func match_collision_ground(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			enable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			enable_collision()
		character.CharacterState.ATTACKAIR:
			disable_collision()
		character.CharacterState.HITSTUNGROUND:
			enable_collision()
		character.CharacterState.HITSTUNAIR:
			enable_collision()
		character.CharacterState.SPECIALGROUND:
			enable_collision()
		character.CharacterState.SPECIALAIR:
			enable_collision()
		character.CharacterState.SHIELD:
			enable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			enable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			enable_collision()
			
func match_collision_air(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			disable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			enable_collision()
		character.CharacterState.ATTACKAIR:
			disable_collision()
		character.CharacterState.HITSTUNGROUND:
			enable_collision()
		character.CharacterState.HITSTUNAIR:
			disable_collision()
		character.CharacterState.SPECIALGROUND:
			enable_collision()
		character.CharacterState.SPECIALAIR:
			disable_collision()
		character.CharacterState.SHIELD:
			enable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			enable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			enable_collision()
			
func match_collision_edge(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			disable_collision()
		character.CharacterState.AIR:
			disable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			disable_collision()
		character.CharacterState.ATTACKAIR:
			disable_collision()
		character.CharacterState.HITSTUNGROUND:
			disable_collision()
		character.CharacterState.HITSTUNAIR:
			disable_collision()
		character.CharacterState.SPECIALGROUND:
			disable_collision()
		character.CharacterState.SPECIALAIR:
			disable_collision()
		character.CharacterState.SHIELD:
			disable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			disable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			disable_collision()
			
func match_collision_attackground(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			enable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			enable_collision()
		character.CharacterState.ATTACKAIR:
			enable_collision()
		character.CharacterState.HITSTUNGROUND:
			enable_collision()
		character.CharacterState.HITSTUNAIR:
			enable_collision()
		character.CharacterState.SPECIALGROUND:
			enable_collision()
		character.CharacterState.SPECIALAIR:
			disable_collision()
		character.CharacterState.SHIELD:
			enable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			enable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			enable_collision()

func match_collision_attackair(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			disable_collision()
		character.CharacterState.AIR:
			disable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			disable_collision()
		character.CharacterState.ATTACKAIR:
			disable_collision()
		character.CharacterState.HITSTUNGROUND:
			disable_collision()
		character.CharacterState.HITSTUNAIR:
			disable_collision()
		character.CharacterState.SPECIALGROUND:
			disable_collision()
		character.CharacterState.SPECIALAIR:
			disable_collision()
		character.CharacterState.SHIELD:
			disable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			disable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			disable_collision()
			
func match_collision_hitstunground(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			enable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			enable_collision()
		character.CharacterState.ATTACKAIR:
			enable_collision()
		character.CharacterState.HITSTUNGROUND:
			enable_collision()
		character.CharacterState.HITSTUNAIR:
			enable_collision()
		character.CharacterState.SPECIALGROUND:
			enable_collision()
		character.CharacterState.SPECIALAIR:
			enable_collision()
		character.CharacterState.SHIELD:
			enable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			enable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			enable_collision()
			
func match_collision_hitstunair(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			disable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			enable_collision()
		character.CharacterState.ATTACKAIR:
			disable_collision()
		character.CharacterState.HITSTUNGROUND:
			enable_collision()
		character.CharacterState.HITSTUNAIR:
			disable_collision()
		character.CharacterState.SPECIALGROUND:
			enable_collision()
		character.CharacterState.SPECIALAIR:
			disable_collision()
		character.CharacterState.SHIELD:
			enable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			enable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			enable_collision()
			
func match_collision_specialground(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			enable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			enable_collision()
		character.CharacterState.ATTACKAIR:
			enable_collision()
		character.CharacterState.HITSTUNGROUND:
			enable_collision()
		character.CharacterState.HITSTUNAIR:
			enable_collision()
		character.CharacterState.SPECIALGROUND:
			enable_collision()
		character.CharacterState.SPECIALAIR:
			enable_collision()
		character.CharacterState.SHIELD:
			enable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			enable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			enable_collision()
			
func match_collision_specialair(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			disable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			enable_collision()
		character.CharacterState.ATTACKAIR:
			disable_collision()
		character.CharacterState.HITSTUNGROUND:
			enable_collision()
		character.CharacterState.HITSTUNAIR:
			disable_collision()
		character.CharacterState.SPECIALGROUND:
			enable_collision()
		character.CharacterState.SPECIALAIR:
			disable_collision()
		character.CharacterState.SHIELD:
			enable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			enable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			enable_collision()
			
func match_collision_shield(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			enable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			enable_collision()
		character.CharacterState.ATTACKAIR:
			enable_collision()
		character.CharacterState.HITSTUNGROUND:
			enable_collision()
		character.CharacterState.HITSTUNAIR:
			enable_collision()
		character.CharacterState.SPECIALGROUND:
			enable_collision()
		character.CharacterState.SPECIALAIR:
			enable_collision()
		character.CharacterState.SHIELD:
			enable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			enable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			enable_collision()
			
func match_collision_roll(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			disable_collision()
		character.CharacterState.AIR:
			disable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			disable_collision()
		character.CharacterState.ATTACKAIR:
			disable_collision()
		character.CharacterState.HITSTUNGROUND:
			disable_collision()
		character.CharacterState.HITSTUNAIR:
			disable_collision()
		character.CharacterState.SPECIALGROUND:
			disable_collision()
		character.CharacterState.SPECIALAIR:
			disable_collision()
		character.CharacterState.SHIELD:
			disable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			disable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			disable_collision()
			
func match_collision_grab(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			enable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			enable_collision()
		character.CharacterState.ATTACKAIR:
			enable_collision()
		character.CharacterState.HITSTUNGROUND:
			enable_collision()
		character.CharacterState.HITSTUNAIR:
			enable_collision()
		character.CharacterState.SPECIALGROUND:
			enable_collision()
		character.CharacterState.SPECIALAIR:
			enable_collision()
		character.CharacterState.SHIELD:
			disable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			enable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			enable_collision()
			
func match_collision_ingrab(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			disable_collision()
		character.CharacterState.AIR:
			disable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			disable_collision()
		character.CharacterState.ATTACKAIR:
			disable_collision()
		character.CharacterState.HITSTUNGROUND:
			disable_collision()
		character.CharacterState.HITSTUNAIR:
			disable_collision()
		character.CharacterState.SPECIALGROUND:
			disable_collision()
		character.CharacterState.SPECIALAIR:
			disable_collision()
		character.CharacterState.SHIELD:
			disable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			disable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			disable_collision()
			
func match_collision_spotdodge(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			disable_collision()
		character.CharacterState.AIR:
			disable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			disable_collision()
		character.CharacterState.ATTACKAIR:
			disable_collision()
		character.CharacterState.HITSTUNGROUND:
			disable_collision()
		character.CharacterState.HITSTUNAIR:
			disable_collision()
		character.CharacterState.SPECIALGROUND:
			disable_collision()
		character.CharacterState.SPECIALAIR:
			disable_collision()
		character.CharacterState.SHIELD:
			disable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			disable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			disable_collision()
			
func match_collision_getup(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			disable_collision()
		character.CharacterState.AIR:
			disable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			disable_collision()
		character.CharacterState.ATTACKAIR:
			disable_collision()
		character.CharacterState.HITSTUNGROUND:
			disable_collision()
		character.CharacterState.HITSTUNAIR:
			disable_collision()
		character.CharacterState.SPECIALGROUND:
			disable_collision()
		character.CharacterState.SPECIALAIR:
			disable_collision()
		character.CharacterState.SHIELD:
			disable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			disable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			disable_collision()
			
func match_collision_shieldbreak(areaCollisionObject):
	match areaCollisionObject.currentState:
		character.CharacterState.GROUND:
			enable_collision()
		character.CharacterState.AIR:
			enable_collision()
		character.CharacterState.EDGE:
			disable_collision()
		character.CharacterState.ATTACKGROUND:
			enable_collision()
		character.CharacterState.ATTACKAIR:
			enable_collision()
		character.CharacterState.HITSTUNGROUND:
			enable_collision()
		character.CharacterState.HITSTUNAIR:
			enable_collision()
		character.CharacterState.SPECIALGROUND:
			enable_collision()
		character.CharacterState.SPECIALAIR:
			enable_collision()
		character.CharacterState.SHIELD:
			enable_collision()
		character.CharacterState.ROLL:
			disable_collision()
		character.CharacterState.GRAB:
			enable_collision()
		character.CharacterState.INGRAB:
			disable_collision()
		character.CharacterState.SPOTDODGE:
			disable_collision()
		character.CharacterState.GETUP:
			disable_collision()
		character.CharacterState.SHIELDBREAK:
			enable_collision()
