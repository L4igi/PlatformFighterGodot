extends Node

var allConnectedHitboxes = []

var allConnectedHurtBoxes = []

enum InteractionState {WIN, LOSE, REBOUND, TRANSCENDENT}

func add_connecting_hitbox(attackingObject, attackedObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray):
	allConnectedHitboxes.append([attackingObject, attackedObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox,specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray])

func add_connected_hurtbox(attackingObject, attackedObject):
	allConnectedHurtBoxes.append([attackingObject, attackedObject])

func match_connected_hit_hurtboxes():
	var tempAllConnectedHurtBoxes = allConnectedHurtBoxes.duplicate(true)
	for hitbox in allConnectedHitboxes: 
		for hurtbox in tempAllConnectedHurtBoxes:
			if hurtbox[0] == hitbox[0]:
				process_connection(hitbox, hurtbox)
	allConnectedHitboxes.clear()
	allConnectedHurtBoxes.clear()

func _process(delta):
	if allConnectedHitboxes.size() >= 1\
	&& allConnectedHurtBoxes.size() >= 1:
		match_connected_hit_hurtboxes()
	pass
	
func process_connection(attackingObject, attackedObject):
	pass
