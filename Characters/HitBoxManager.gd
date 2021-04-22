extends Node

var collidedHitBoxes = []

func add_colliding_hitbox(funcRef, paramArray, attackingObject, attackDamage, hitlagMultiplier):
	collidedHitBoxes.append([funcRef, paramArray, attackingObject, attackDamage, hitlagMultiplier])

func _process(delta):
	if collidedHitBoxes.size() == 2: 
		#get attack damage from colliding hitboxes
		var object1Damage = collidedHitBoxes[0][3]
		var object2Damage = collidedHitBoxes[1][3]
		if object1Damage > object2Damage + 9:
			calc_hitlag_apply_attack_attacker(0)
			calc_hitlag_apply_attack_attacked(1)
			collidedHitBoxes[0][0].call_funcv(collidedHitBoxes[0][1])
		elif object2Damage > object1Damage +9:
			calc_hitlag_apply_attack_attacker(1)
			calc_hitlag_apply_attack_attacked(0)
			collidedHitBoxes[0][0].call_funcv(collidedHitBoxes[0][1])
			collidedHitBoxes[1][0].call_funcv(collidedHitBoxes[1][1])
		else:
			calc_hitlag_apply_attack_attacked(0)
			calc_hitlag_apply_attack_attacked(1)
			collidedHitBoxes[0][0].call_funcv(collidedHitBoxes[0][1])
			collidedHitBoxes[1][0].call_funcv(collidedHitBoxes[1][1])
		collidedHitBoxes.clear()
		
func calc_hitlag_apply_attack_attacker(arrayPosition):
	var attackingObject = collidedHitBoxes[arrayPosition][2]
	print(attackingObject.name)
	var attackingObjectDamage = collidedHitBoxes[arrayPosition][3]
	var attackingObjectHitlagMultiplier = collidedHitBoxes[arrayPosition][4]
	calculate_hitlag_frames_clashed_attackingObject(attackingObjectDamage, attackingObjectHitlagMultiplier, attackingObject)

func calc_hitlag_apply_attack_attacked(arrayPosition):
	var attackedObject = collidedHitBoxes[arrayPosition][2]
	var attackedObjectDamage = collidedHitBoxes[arrayPosition][3]
	var attackedObjectHitlagMultiplier = collidedHitBoxes[arrayPosition][4]
	calculate_hitlag_frames_clashed_attackedObject(attackedObjectDamage, attackedObjectHitlagMultiplier, attackedObject)
	
		
func calculate_hitlag_frames_clashed_attackingObject(attackDamage, hitlagMultiplier, attackingObject):
	var attackingObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackingObject.state.hitlagTimer.get_time_left()*60))
	attackingObject.state.hitlagTimer.stop()
	attackingObject.state.start_timer(attackingObject.state.hitlagTimer, attackingObjectHitlag)
	
func calculate_hitlag_frames_clashed_attackedObject(attackDamage, hitlagMultiplier, attackedObject):
	var attackedObjectHitlag = floor((attackDamage*0.65+4)*hitlagMultiplier + (attackedObject.state.hitlagTimer.get_time_left()*60))
	attackedObject.state.hitlagTimer.stop()
	attackedObject.character_attacked_handler(attackedObjectHitlag)
