extends Node

var allCollidedHitBoxes = []

enum InteractionState {WIN, LOSE, REBOUND, TRANSCENDENT}

func add_colliding_hitbox(attackingObject, attackedObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray):
	allCollidedHitBoxes.append([attackingObject, attackedObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox,specialHitBoxEffects, isAttackedHandlerFuncRef, isAttackedHandlerParamArray])

func match_colliding_hitboxes():
	print(allCollidedHitBoxes[0])
	var tempAllCollidedHitBoxes = allCollidedHitBoxes.duplicate(true)
	var loopCount = 0
	for object1Count in range(0,tempAllCollidedHitBoxes.size()):
		loopCount += 1
		for object2Count in range(loopCount,tempAllCollidedHitBoxes.size()):
			if loopCount == tempAllCollidedHitBoxes.size(): 
				break
			if tempAllCollidedHitBoxes[object1Count][0] == tempAllCollidedHitBoxes[object2Count][1]:
				var collidedHitBoxes = []
				collidedHitBoxes.append(tempAllCollidedHitBoxes[object1Count])
				collidedHitBoxes.append(tempAllCollidedHitBoxes[object2Count])
				process_collision(collidedHitBoxes)
	tempAllCollidedHitBoxes.clear()
	allCollidedHitBoxes.clear()

func _process(delta):
	if allCollidedHitBoxes.size() >= 2:
		match_colliding_hitboxes()
	pass
	
func process_collision(collidedHitBoxes):
	if collidedHitBoxes.size() == 2: 
		print(collidedHitBoxes[0])
		#get attack damage from colliding hitboxes
		var object1Damage = collidedHitBoxes[0][2] 
		var object2Damage = collidedHitBoxes[1][2]
		#if special hitbox interacted character projectile
		if manage_hitbox_special_interactions_projectile(collidedHitBoxes,0,1):
			pass
		#object one wins trade finish attack object 2 enters rebound or attacked if hitboxconneteted != empty
		elif object1Damage > object2Damage + 9:
			if collidedHitBoxes[0][4].empty():
				manage_only_hitboxes_connected_one_winner(collidedHitBoxes,0,1)
			else:
				manage_collisionboxes_and_hitboxes_connected_one_winner(collidedHitBoxes,0,1)
		#object 2 wins trade finish attack object 1 enters rebound or attacked if hitboxconneteted != empty
		elif object2Damage > object1Damage + 9:
			if collidedHitBoxes[1][4].empty():
				manage_only_hitboxes_connected_one_winner(collidedHitBoxes,1,0)
			else:
				manage_collisionboxes_and_hitboxes_connected_one_winner(collidedHitBoxes,1,0)
		#both characters win trade switch to reboundstate
		else:
			if !collidedHitBoxes[0][4].empty()\
			|| !collidedHitBoxes[1][4].empty():
				manage_collisionboxes_and_hitboxes_connected_no_winner(collidedHitBoxes,1,0)
			else:
				manage_only_hitboxes_connected_no_winner(collidedHitBoxes,0,1)
		collidedHitBoxes.clear()
		
func manage_hitbox_special_interactions_projectile(collidedHitBoxes, object1ArrayPos, object2ArrayPos):
	var object1 = collidedHitBoxes[object1ArrayPos][0]
	var object2 = collidedHitBoxes[object2ArrayPos][0]
#	print("OBJECT 1 " +str(object1.name))
#	print("OBJECT 2 " +str(object2.name))
	if object1.is_in_group("Projectile")||object2.is_in_group("Projectile"):
		var interactionTypeToUse = GlobalVariables.HitBoxInteractionType.CONNECTED
		var object1Interacted = object2.apply_special_hitbox_effect(collidedHitBoxes[object1ArrayPos][7], object1, collidedHitBoxes[0][2] , interactionTypeToUse)
		var object2Interacted = object1.apply_special_hitbox_effect(collidedHitBoxes[object2ArrayPos][7], object2, collidedHitBoxes[1][2] , interactionTypeToUse)
		if object1Interacted || object2Interacted:
			var object1HitlagFrames = calc_hitlag_attacker(collidedHitBoxes,object1ArrayPos)
			set_hitlag_frames(object1, object1HitlagFrames)
			var object2HitlagFrames = calc_hitlag_attacker(collidedHitBoxes,object2ArrayPos)
			set_hitlag_frames(object2, object2HitlagFrames)
			return true
	return false
	
#after one character won the interaction only interacted of this character is called
func manage_hitbox_special_interactions_character(collidedHitBoxes,object1ArrayPos, object2ArrayPos):
	var object1 = collidedHitBoxes[object1ArrayPos][0]
	var object2 = collidedHitBoxes[object2ArrayPos][0]
#	print("OBJECT 1 " +str(object1.name))
#	print("OBJECT 2 " +str(object2.name))
	if object1.is_in_group("Character")&&object2.is_in_group("Character"):
		var interactionTypeToUse = GlobalVariables.HitBoxInteractionType.CONNECTED
		var object1Interacted = object2.apply_special_hitbox_effect(collidedHitBoxes[object1ArrayPos][7], object1, collidedHitBoxes[0][2] , interactionTypeToUse)
		var object2Interacted = object1.apply_special_hitbox_effect(collidedHitBoxes[object2ArrayPos][7], object2, collidedHitBoxes[1][2] , interactionTypeToUse)
	return false
		
func manage_only_hitboxes_connected_one_winner(collidedHitBoxes,attackingObjectArrayPos, attackedObjectArrayPos):
	var attackingObject = collidedHitBoxes[attackingObjectArrayPos][0]
	var attackedObject = collidedHitBoxes[attackedObjectArrayPos][0]
	manage_hitbox_interactions(collidedHitBoxes,attackedObjectArrayPos)
	var attackingObjectHitlag = calc_hitlag_attacker(collidedHitBoxes,attackingObjectArrayPos)
	set_hitlag_frames(attackingObject, attackingObjectHitlag)
	
func manage_only_hitboxes_connected_no_winner(collidedHitBoxes,object1ArrayPos, object2ArrayPos):
	manage_hitbox_interactions(collidedHitBoxes,object1ArrayPos)
	manage_hitbox_interactions(collidedHitBoxes,object2ArrayPos)
	
func manage_hitbox_interactions(collidedHitBoxes,objectArrayPos):
	var object = collidedHitBoxes[objectArrayPos][0]
	#check if move is transcendent 1 = is transcendent
	if collidedHitBoxes[objectArrayPos][6] == 1:
		var objectHitlagFrames = calc_hitlag_attacker(collidedHitBoxes,objectArrayPos)
		set_hitlag_frames(object, objectHitlagFrames)
	#check if attackedObject can rebound 1 = cannot rebound
	#if move can not rebound disable hitbox but continue attack
	elif collidedHitBoxes[objectArrayPos][5] == 1:
		object.toggle_all_hitboxes("off")
		var objectHitlagFrames = calc_hitlag_attacker(collidedHitBoxes,objectArrayPos)
		set_hitlag_frames(object, objectHitlagFrames)
	#if move can rebound attackingObject continous attack, attackedobject rebounds
	match_rebound_objecttype(collidedHitBoxes,object, objectArrayPos)
	
func manage_collisionboxes_and_hitboxes_connected_one_winner(collidedHitBoxes,attackingObjectArrayPos, attackedObjectArrayPos):
	var attackingObject = collidedHitBoxes[attackingObjectArrayPos][0]
	var attackedObject = collidedHitBoxes[attackedObjectArrayPos][0]
	#check if move is transcendent 1 = is transcendent
	#if transendent check if hitbox also hit enemy if so apply attack to attacker
	if collidedHitBoxes[attackedObjectArrayPos][6] == 1\
	&& !collidedHitBoxes[attackedObjectArrayPos][4].empty():
		var attackingObjectHitlagFrames = calc_hitlag_attacked(collidedHitBoxes,attackingObjectArrayPos)
		set_hitlag_attacked_frames(attackingObject, attackingObjectHitlagFrames)
		collidedHitBoxes[attackingObjectArrayPos][8].call_funcv(collidedHitBoxes[attackingObjectArrayPos][9])
	#if transcendent but hitbox not connecting with attcker continou attack for attacker
	else:
		var attackingObjectHitlagFrames = calc_hitlag_attacker(collidedHitBoxes,attackingObjectArrayPos)
		set_hitlag_frames(attackingObject, attackingObjectHitlagFrames)
	var attackedObjectHitlagFrames = calc_hitlag_attacked(collidedHitBoxes,attackedObjectArrayPos)
	set_hitlag_attacked_frames(attackedObject, attackedObjectHitlagFrames)
	collidedHitBoxes[attackedObjectArrayPos][8].call_funcv(collidedHitBoxes[attackedObjectArrayPos][9])
			
	
func manage_collisionboxes_and_hitboxes_connected_no_winner(collidedHitBoxes,attackingObject1ArrayPos, attackingObject2ArrayPos):
	var attackingObject1 = collidedHitBoxes[attackingObject1ArrayPos][0]
	var attackingObject2 = collidedHitBoxes[attackingObject2ArrayPos][0]
	#both objects have connecting collisionboxes
	if !collidedHitBoxes[attackingObject1ArrayPos][4].empty()\
	&& !collidedHitBoxes[attackingObject2ArrayPos][4].empty():
		manage_object_collisionboxes_and_hitbox_interactions_both_collision(collidedHitBoxes,attackingObject1ArrayPos, attackingObject2ArrayPos)
		manage_object_collisionboxes_and_hitbox_interactions_both_collision(collidedHitBoxes,attackingObject2ArrayPos, attackingObject1ArrayPos)
	elif !collidedHitBoxes[attackingObject1ArrayPos][4].empty()\
	&& collidedHitBoxes[attackingObject2ArrayPos][4].empty():
		manage_object_collisionboxes_and_hitbox_interactions_one_collision(collidedHitBoxes,attackingObject1ArrayPos, attackingObject2ArrayPos)
	elif collidedHitBoxes[attackingObject1ArrayPos][4].empty()\
	&& !collidedHitBoxes[attackingObject2ArrayPos][4].empty():
		manage_object_collisionboxes_and_hitbox_interactions_one_collision(collidedHitBoxes,attackingObject2ArrayPos, attackingObject1ArrayPos)

func manage_object_collisionboxes_and_hitbox_interactions_both_collision(collidedHitBoxes,attackingObject1ArrayPos, attackingObject2ArrayPos):
	var attackingObject1 = collidedHitBoxes[attackingObject1ArrayPos][0]
	var attackingObject2 = collidedHitBoxes[attackingObject2ArrayPos][0]
	#check if both moves are transcendent 1 = is transcendent,
	if collidedHitBoxes[attackingObject1ArrayPos][6] == 1\
	&& collidedHitBoxes[attackingObject2ArrayPos][6] == 1:
		var attackingObject1HitlagFrames = calc_hitlag_attacked(collidedHitBoxes,attackingObject1ArrayPos)
		set_hitlag_attacked_frames(attackingObject2, attackingObject1HitlagFrames)
		collidedHitBoxes[attackingObject1ArrayPos][8].call_funcv(collidedHitBoxes[attackingObject1ArrayPos][9])
	elif collidedHitBoxes[attackingObject1ArrayPos][6] == 0\
	&& collidedHitBoxes[attackingObject2ArrayPos][6] == 1:
		var object1HitlagFrames = calc_hitlag_attacker(collidedHitBoxes,attackingObject1ArrayPos)
		set_hitlag_frames(attackingObject1, object1HitlagFrames)
	elif collidedHitBoxes[attackingObject1ArrayPos][6] == 1\
	&& collidedHitBoxes[attackingObject2ArrayPos][6] == 0:
		var attackingObject1HitlagFrames = calc_hitlag_attacked(collidedHitBoxes,attackingObject1ArrayPos)
		set_hitlag_attacked_frames(attackingObject2, attackingObject1HitlagFrames)
		collidedHitBoxes[attackingObject1ArrayPos][8].call_funcv(collidedHitBoxes[attackingObject1ArrayPos][9])
	#check if both are non rebound
	elif collidedHitBoxes[attackingObject1ArrayPos][5] == 1:
		attackingObject1.toggle_all_hitboxes("off")
		var object1HitlagFrames = calc_hitlag_attacker(collidedHitBoxes,attackingObject1ArrayPos)
		set_hitlag_frames(attackingObject1, object1HitlagFrames)
	#if rebound hitbox
	match_rebound_objecttype(collidedHitBoxes,attackingObject1, attackingObject1ArrayPos)

func manage_object_collisionboxes_and_hitbox_interactions_one_collision(collidedHitBoxes,attackingObjectArrayPos, attackedObjectArrayPos):
	var attackingObject = collidedHitBoxes[attackingObjectArrayPos][0]
	var attackedObject = collidedHitBoxes[attackedObjectArrayPos][0]
	#if transcendend hitbox, attack other character, apply hitlag to selfe
	if collidedHitBoxes[attackingObjectArrayPos][6] == 1:
		var attackedObjectHitlagFrames = calc_hitlag_attacked(collidedHitBoxes,attackedObjectArrayPos)
		set_hitlag_attacked_frames(attackedObject, attackedObjectHitlagFrames)
		collidedHitBoxes[attackingObjectArrayPos][8].call_funcv(collidedHitBoxes[attackingObjectArrayPos][9])
		var attackingObjectHitlagFrames = calc_hitlag_attacker(collidedHitBoxes,attackingObjectArrayPos)
		set_hitlag_frames(attackingObject, attackingObjectHitlagFrames)
	#set both characters to state rebound if they can rebound 
	elif collidedHitBoxes[attackingObjectArrayPos][5] == 0\
	&& collidedHitBoxes[attackedObjectArrayPos][5] == 0:
		match_rebound_objecttype(collidedHitBoxes,attackingObject, attackingObjectArrayPos)
		match_rebound_objecttype(collidedHitBoxes,attackedObject, attackedObjectArrayPos)
	#one to rebound one to finish attack 
	elif collidedHitBoxes[attackingObjectArrayPos][5] == 1\
	&& collidedHitBoxes[attackedObjectArrayPos][5] == 0:
		attackingObject.toggle_all_hitboxes("off")
		var attackingObjectHitlagFrames = calc_hitlag_attacker(collidedHitBoxes,attackingObjectArrayPos)
		set_hitlag_frames(attackingObject, attackingObjectHitlagFrames)
		match_rebound_objecttype(collidedHitBoxes,attackedObject, attackedObjectArrayPos)
	#one to rebound one to finish attack 
	elif collidedHitBoxes[attackingObjectArrayPos][5] == 0\
	&& collidedHitBoxes[attackedObjectArrayPos][5] == 1:
		match_rebound_objecttype(collidedHitBoxes,attackingObject, attackingObjectArrayPos)
		attackedObject.toggle_all_hitboxes("off")
		var attackedObjectHitlagFrames = calc_hitlag_attacker(collidedHitBoxes,attackedObjectArrayPos)
		set_hitlag_frames(attackedObject, attackedObjectHitlagFrames)
		
func match_rebound_objecttype(collidedHitBoxes,object, objectArrayPosition):
	if object.is_in_group("Character"):
		object.bufferReboundFrames = calc_reboundLag(collidedHitBoxes,objectArrayPosition)
		object.change_state(GlobalVariables.CharacterState.REBOUND)
	elif object.is_in_group("Projectile"):
		object.change_state(GlobalVariables.ProjectileState.DESTROYED)
		
func calc_hitlag_attacker(collidedHitBoxes,arrayPosition):
	var attackingObject = collidedHitBoxes[arrayPosition][0]
	var attackingObjectDamage = collidedHitBoxes[arrayPosition][2]
	var attackingObjectHitlagMultiplier = collidedHitBoxes[arrayPosition][3]
	var attackingObjectHitlag = floor((attackingObjectDamage*0.75+4)*attackingObjectHitlagMultiplier + (attackingObject.state.hitlagTimer.get_time_left()*70))
	return attackingObjectHitlag
#	calculate_hitlag_frames_clashed_attackingObject(attackingObjectDamage, attackingObjectHitlagMultiplier, attackingObject)

func calc_hitlag_attacked(collidedHitBoxes,arrayPosition):
	var attackedObject = collidedHitBoxes[arrayPosition][0]
	var attackedObjectDamage = collidedHitBoxes[arrayPosition][2]
	var attackedObjectHitlagMultiplier = collidedHitBoxes[arrayPosition][3]
	var attackedObjectHitlag = floor((attackedObjectDamage*0.75+4)*attackedObjectHitlagMultiplier + (attackedObject.state.hitlagTimer.get_time_left()*70))
	return attackedObjectHitlag
#	calculate_hitlag_frames_clashed_attackedObject(attackedObjectDamage, attackedObjectHitlagMultiplier, attackedObject)
	
func calc_reboundLag(collidedHitBoxes,arrayPosition):
	var reboundObject = collidedHitBoxes[arrayPosition][0]
	var reboundObjectDamage = collidedHitBoxes[arrayPosition][2]
	var reboundObjectHitlagMultiplier = collidedHitBoxes[arrayPosition][3]
	var reboundObjectHitlag = floor((reboundObjectDamage*0.75+4)*reboundObjectHitlagMultiplier + (reboundObject.state.hitlagTimer.get_time_left()*70))
	return reboundObjectHitlag
	
func set_hitlag_frames(object, objectHitlag):
	object.state.hitlagTimer.stop()
	object.state.start_timer(object.state.hitlagTimer, objectHitlag)

func set_hitlag_attacked_frames(object, objectHitlag):
	object.state.hitlagTimer.stop()
	object.character_attacked_handler(objectHitlag)
