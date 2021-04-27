extends Node

var collidedHitBoxes = []

enum InteractionState {WIN, LOSE, REBOUND, TRANSCENDENT}

func add_colliding_hitbox(attackingObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray):
	collidedHitBoxes.append([attackingObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox,specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray])

func _process(delta):
	if collidedHitBoxes.size() == 2: 
		#get attack damage from colliding hitboxes
		var object1Damage = collidedHitBoxes[0][1] 
		var object2Damage = collidedHitBoxes[1][1]
		#if special hitbox interacted character projectile
		if manage_hitbox_special_interactions_projectile(0,1):
			pass
		#object one wins trade finish attack object 2 enters rebound or attacked if hitboxconneteted != empty
		elif object1Damage > object2Damage + 9:
			if collidedHitBoxes[0][3].empty():
				manage_only_hitboxes_connected_one_winner(0,1)
			else:
				manage_collisionboxes_and_hitboxes_connected_one_winner(0,1)
		#object 2 wins trade finish attack object 1 enters rebound or attacked if hitboxconneteted != empty
		elif object2Damage > object1Damage + 9:
			if collidedHitBoxes[1][3].empty():
				manage_only_hitboxes_connected_one_winner(1,0)
			else:
				manage_collisionboxes_and_hitboxes_connected_one_winner(1,0)
		#both characters win trade switch to reboundstate
		else:
			if !collidedHitBoxes[0][3].empty()\
			|| !collidedHitBoxes[1][3].empty():
				manage_collisionboxes_and_hitboxes_connected_no_winner(1,0)
			else:
				manage_only_hitboxes_connected_no_winner(0,1)
		collidedHitBoxes.clear()
		
func manage_hitbox_special_interactions_projectile(object1ArrayPos, object2ArrayPos):
	var object1 = collidedHitBoxes[object1ArrayPos][0]
	var object2 = collidedHitBoxes[object2ArrayPos][0]
#	print("OBJECT 1 " +str(object1.name))
#	print("OBJECT 2 " +str(object2.name))
	if object1.is_in_group("Projectile")||object2.is_in_group("Projectile"):
		var interactionTypeToUse = GlobalVariables.HitBoxInteractionType.CONNECTED
		var object1Interacted = object2.apply_special_hitbox_effect(collidedHitBoxes[object1ArrayPos][6], object1, collidedHitBoxes[0][1] , interactionTypeToUse)
		var object2Interacted = object1.apply_special_hitbox_effect(collidedHitBoxes[object2ArrayPos][6], object2, collidedHitBoxes[1][1] , interactionTypeToUse)
		if object1Interacted || object2Interacted:
			var object1HitlagFrames = calc_hitlag_attacker(object1ArrayPos)
			set_hitlag_frames(object1, object1HitlagFrames)
			var object2HitlagFrames = calc_hitlag_attacker(object2ArrayPos)
			set_hitlag_frames(object2, object2HitlagFrames)
			return true
	return false
	
#after one character won the interaction only interacted of this character is called
func manage_hitbox_special_interactions_character(object1ArrayPos, object2ArrayPos):
	var object1 = collidedHitBoxes[object1ArrayPos][0]
	var object2 = collidedHitBoxes[object2ArrayPos][0]
#	print("OBJECT 1 " +str(object1.name))
#	print("OBJECT 2 " +str(object2.name))
	if object1.is_in_group("Character")&&object2.is_in_group("Character"):
		var interactionTypeToUse = GlobalVariables.HitBoxInteractionType.CONNECTED
		var object1Interacted = object2.apply_special_hitbox_effect(collidedHitBoxes[object1ArrayPos][6], object1, collidedHitBoxes[0][1] , interactionTypeToUse)
		var object2Interacted = object1.apply_special_hitbox_effect(collidedHitBoxes[object2ArrayPos][6], object2, collidedHitBoxes[1][1] , interactionTypeToUse)
	return false
		
func manage_only_hitboxes_connected_one_winner(attackingObjectArrayPos, attackedObjectArrayPos):
	var attackingObject = collidedHitBoxes[attackingObjectArrayPos][0]
	var attackedObject = collidedHitBoxes[attackedObjectArrayPos][0]
	manage_hitbox_interactions(attackedObjectArrayPos)
	var attackingObjectHitlag = calc_hitlag_attacker(attackingObjectArrayPos)
	set_hitlag_frames(attackingObject, attackingObjectHitlag)
	
func manage_only_hitboxes_connected_no_winner(object1ArrayPos, object2ArrayPos):
	manage_hitbox_interactions(object1ArrayPos)
	manage_hitbox_interactions(object2ArrayPos)
	
func manage_hitbox_interactions(objectArrayPos):
	var object = collidedHitBoxes[objectArrayPos][0]
	#check if move is transcendent 1 = is transcendent
	if collidedHitBoxes[objectArrayPos][5] == 1:
		var objectHitlagFrames = calc_hitlag_attacker(objectArrayPos)
		set_hitlag_frames(object, objectHitlagFrames)
	#check if attackedObject can rebound 1 = cannot rebound
	#if move can not rebound disable hitbox but continue attack
	elif collidedHitBoxes[objectArrayPos][4] == 1:
		object.toggle_all_hitboxes("off")
		var objectHitlagFrames = calc_hitlag_attacker(objectArrayPos)
		set_hitlag_frames(object, objectHitlagFrames)
	#if move can rebound attackingObject continous attack, attackedobject rebounds
	match_rebound_objecttype(object, objectArrayPos)
	
func manage_collisionboxes_and_hitboxes_connected_one_winner(attackingObjectArrayPos, attackedObjectArrayPos):
	var attackingObject = collidedHitBoxes[attackingObjectArrayPos][0]
	var attackedObject = collidedHitBoxes[attackedObjectArrayPos][0]
	#check if move is transcendent 1 = is transcendent
	#if transendent check if hitbox also hit enemy if so apply attack to attacker
	if collidedHitBoxes[attackedObjectArrayPos][5] == 1\
	&& !collidedHitBoxes[attackedObjectArrayPos][3].empty():
		var attackingObjectHitlagFrames = calc_hitlag_attacked(attackingObjectArrayPos)
		set_hitlag_attacked_frames(attackingObject, attackingObjectHitlagFrames)
		collidedHitBoxes[attackingObjectArrayPos][7].call_funcv(collidedHitBoxes[attackingObjectArrayPos][8])
	#if transcendent but hitbox not connecting with attcker continou attack for attacker
	else:
		var attackingObjectHitlagFrames = calc_hitlag_attacker(attackingObjectArrayPos)
		set_hitlag_frames(attackingObject, attackingObjectHitlagFrames)
	var attackedObjectHitlagFrames = calc_hitlag_attacked(attackedObjectArrayPos)
	set_hitlag_attacked_frames(attackedObject, attackedObjectHitlagFrames)
	collidedHitBoxes[attackedObjectArrayPos][7].call_funcv(collidedHitBoxes[attackedObjectArrayPos][8])
			
	
func manage_collisionboxes_and_hitboxes_connected_no_winner(attackingObject1ArrayPos, attackingObject2ArrayPos):
	var attackingObject1 = collidedHitBoxes[attackingObject1ArrayPos][0]
	var attackingObject2 = collidedHitBoxes[attackingObject2ArrayPos][0]
	#both objects have connecting collisionboxes
	if !collidedHitBoxes[attackingObject1ArrayPos][3].empty()\
	&& !collidedHitBoxes[attackingObject2ArrayPos][3].empty():
		manage_object_collisionboxes_and_hitbox_interactions_both_collision(attackingObject1ArrayPos, attackingObject2ArrayPos)
		manage_object_collisionboxes_and_hitbox_interactions_both_collision(attackingObject2ArrayPos, attackingObject1ArrayPos)
	elif !collidedHitBoxes[attackingObject1ArrayPos][3].empty()\
	&& collidedHitBoxes[attackingObject2ArrayPos][3].empty():
		manage_object_collisionboxes_and_hitbox_interactions_one_collision(attackingObject1ArrayPos, attackingObject2ArrayPos)
	elif collidedHitBoxes[attackingObject1ArrayPos][3].empty()\
	&& !collidedHitBoxes[attackingObject2ArrayPos][3].empty():
		manage_object_collisionboxes_and_hitbox_interactions_one_collision(attackingObject2ArrayPos, attackingObject1ArrayPos)

func manage_object_collisionboxes_and_hitbox_interactions_both_collision(attackingObject1ArrayPos, attackingObject2ArrayPos):
	var attackingObject1 = collidedHitBoxes[attackingObject1ArrayPos][0]
	var attackingObject2 = collidedHitBoxes[attackingObject2ArrayPos][0]
	#check if both moves are transcendent 1 = is transcendent,
	if collidedHitBoxes[attackingObject1ArrayPos][5] == 1\
	&& collidedHitBoxes[attackingObject2ArrayPos][5] == 1:
		var attackingObject1HitlagFrames = calc_hitlag_attacked(attackingObject1ArrayPos)
		set_hitlag_attacked_frames(attackingObject2, attackingObject1HitlagFrames)
		collidedHitBoxes[attackingObject1ArrayPos][7].call_funcv(collidedHitBoxes[attackingObject1ArrayPos][8])
	elif collidedHitBoxes[attackingObject1ArrayPos][5] == 0\
	&& collidedHitBoxes[attackingObject2ArrayPos][5] == 1:
		var object1HitlagFrames = calc_hitlag_attacker(attackingObject1ArrayPos)
		set_hitlag_frames(attackingObject1, object1HitlagFrames)
	elif collidedHitBoxes[attackingObject1ArrayPos][5] == 1\
	&& collidedHitBoxes[attackingObject2ArrayPos][5] == 0:
		var attackingObject1HitlagFrames = calc_hitlag_attacked(attackingObject1ArrayPos)
		set_hitlag_attacked_frames(attackingObject2, attackingObject1HitlagFrames)
		collidedHitBoxes[attackingObject1ArrayPos][7].call_funcv(collidedHitBoxes[attackingObject1ArrayPos][8])
	#check if both are non rebound
	elif collidedHitBoxes[attackingObject1ArrayPos][4] == 1:
		attackingObject1.toggle_all_hitboxes("off")
		var object1HitlagFrames = calc_hitlag_attacker(attackingObject1ArrayPos)
		set_hitlag_frames(attackingObject1, object1HitlagFrames)
	#if rebound hitbox
	match_rebound_objecttype(attackingObject1, attackingObject1ArrayPos)

func manage_object_collisionboxes_and_hitbox_interactions_one_collision(attackingObjectArrayPos, attackedObjectArrayPos):
	var attackingObject = collidedHitBoxes[attackingObjectArrayPos][0]
	var attackedObject = collidedHitBoxes[attackedObjectArrayPos][0]
	#if transcendend hitbox, attack other character, apply hitlag to selfe
	if collidedHitBoxes[attackingObjectArrayPos][5] == 1:
		var attackedObjectHitlagFrames = calc_hitlag_attacked(attackedObjectArrayPos)
		set_hitlag_attacked_frames(attackedObject, attackedObjectHitlagFrames)
		collidedHitBoxes[attackingObjectArrayPos][7].call_funcv(collidedHitBoxes[attackingObjectArrayPos][8])
		var attackingObjectHitlagFrames = calc_hitlag_attacker(attackingObjectArrayPos)
		set_hitlag_frames(attackingObject, attackingObjectHitlagFrames)
	#set both characters to state rebound if they can rebound 
	elif collidedHitBoxes[attackingObjectArrayPos][4] == 0\
	&& collidedHitBoxes[attackedObjectArrayPos][4] == 0:
		match_rebound_objecttype(attackingObject, attackingObjectArrayPos)
		match_rebound_objecttype(attackedObject, attackedObjectArrayPos)
	#one to rebound one to finish attack 
	elif collidedHitBoxes[attackingObjectArrayPos][4] == 1\
	&& collidedHitBoxes[attackedObjectArrayPos][4] == 0:
		attackingObject.toggle_all_hitboxes("off")
		var attackingObjectHitlagFrames = calc_hitlag_attacker(attackingObjectArrayPos)
		set_hitlag_frames(attackingObject, attackingObjectHitlagFrames)
		match_rebound_objecttype(attackedObject, attackedObjectArrayPos)
	#one to rebound one to finish attack 
	elif collidedHitBoxes[attackingObjectArrayPos][4] == 0\
	&& collidedHitBoxes[attackedObjectArrayPos][4] == 1:
		match_rebound_objecttype(attackingObject, attackingObjectArrayPos)
		attackedObject.toggle_all_hitboxes("off")
		var attackedObjectHitlagFrames = calc_hitlag_attacker(attackedObjectArrayPos)
		set_hitlag_frames(attackedObject, attackedObjectHitlagFrames)
		
func match_rebound_objecttype(object, objectArrayPosition):
	if object.is_in_group("Character"):
		object.bufferReboundFrames = calc_reboundLag(objectArrayPosition)
		object.change_state(GlobalVariables.CharacterState.REBOUND)
	elif object.is_in_group("Projectile"):
		object.change_state(GlobalVariables.ProjectileState.DESTROYED)
		
func calc_hitlag_attacker(arrayPosition):
	var attackingObject = collidedHitBoxes[arrayPosition][0]
	var attackingObjectDamage = collidedHitBoxes[arrayPosition][1]
	var attackingObjectHitlagMultiplier = collidedHitBoxes[arrayPosition][2]
	var attackingObjectHitlag = floor((attackingObjectDamage*0.75+4)*attackingObjectHitlagMultiplier + (attackingObject.state.hitlagTimer.get_time_left()*70))
	return attackingObjectHitlag
#	calculate_hitlag_frames_clashed_attackingObject(attackingObjectDamage, attackingObjectHitlagMultiplier, attackingObject)

func calc_hitlag_attacked(arrayPosition):
	var attackedObject = collidedHitBoxes[arrayPosition][0]
	var attackedObjectDamage = collidedHitBoxes[arrayPosition][1]
	var attackedObjectHitlagMultiplier = collidedHitBoxes[arrayPosition][2]
	var attackedObjectHitlag = floor((attackedObjectDamage*0.75+4)*attackedObjectHitlagMultiplier + (attackedObject.state.hitlagTimer.get_time_left()*70))
	return attackedObjectHitlag
#	calculate_hitlag_frames_clashed_attackedObject(attackedObjectDamage, attackedObjectHitlagMultiplier, attackedObject)
	
func calc_reboundLag(arrayPosition):
	var reboundObject = collidedHitBoxes[arrayPosition][0]
	var reboundObjectDamage = collidedHitBoxes[arrayPosition][1]
	var reboundObjectHitlagMultiplier = collidedHitBoxes[arrayPosition][2]
	var reboundObjectHitlag = floor((reboundObjectDamage*0.75+4)*reboundObjectHitlagMultiplier + (reboundObject.state.hitlagTimer.get_time_left()*70))
	return reboundObjectHitlag
	
func set_hitlag_frames(object, objectHitlag):
	object.state.hitlagTimer.stop()
	object.state.start_timer(object.state.hitlagTimer, objectHitlag)

func set_hitlag_attacked_frames(object, objectHitlag):
	object.state.hitlagTimer.stop()
	object.character_attacked_handler(objectHitlag)
