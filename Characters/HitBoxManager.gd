extends Node

var collidedHitBoxes = []

enum InteractionState {WIN, LOSE, REBOUND, TRANSCENDENT}

func add_colliding_hitbox(attackingObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, isAttackedHandlerFuncRef, isAttackedHandlerParamArray):
	collidedHitBoxes.append([attackingObject, attackDamage, hitlagMultiplier, hitBoxesConnectedCopy, reboundingHitbox, transcendentHitBox, isAttackedHandlerFuncRef, isAttackedHandlerParamArray])

func _process(delta):
	if collidedHitBoxes.size() == 2: 
		#get attack damage from colliding hitboxes
		var object1Damage = collidedHitBoxes[0][1]
		var object2Damage = collidedHitBoxes[1][1]
		#object one wins trade finish attack object 2 enters rebound or attacked if hitboxconneteted != empty
		if object1Damage > object2Damage + 9:
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
		
func manage_only_hitboxes_connected_one_winner(attackingObjectArrayPos, attackedObjectArrayPos):
	var attackingObject = collidedHitBoxes[attackingObjectArrayPos][0]
	var attackedObject = collidedHitBoxes[attackedObjectArrayPos][0]
	if attackedObject.is_in_group("Character"):
		manage_character_hitbox_interactions(attackedObjectArrayPos)
	var attackingObjectHitlag = calc_hitlag_attacker(attackingObjectArrayPos)
	set_hitlag_frames(attackingObject, attackingObjectHitlag)
	
func manage_only_hitboxes_connected_no_winner(object1ArrayPos, object2ArrayPos):
	manage_character_hitbox_interactions(object1ArrayPos)
	manage_character_hitbox_interactions(object2ArrayPos)
	
func manage_character_hitbox_interactions(objectArrayPos):
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
	else:
		object.bufferReboundFrames = calc_reboundLag(objectArrayPos)
		object.change_state(GlobalVariables.CharacterState.REBOUND)
	
	
func manage_collisionboxes_and_hitboxes_connected_one_winner(attackingObjectArrayPos, attackedObjectArrayPos):
	var attackingObject = collidedHitBoxes[attackingObjectArrayPos][0]
	var attackedObject = collidedHitBoxes[attackedObjectArrayPos][0]
	#check if move is transcendent 1 = is transcendent
	#if transendent check if hitbox also hit enemy if so apply attack to attacker
	if collidedHitBoxes[attackedObjectArrayPos][5] == 1\
	&& !collidedHitBoxes[attackedObjectArrayPos][3].empty():
		var attackingObjectHitlagFrames = calc_hitlag_attacked(attackingObjectArrayPos)
		set_hitlag_attacked_frames(attackingObject, attackingObjectHitlagFrames)
		collidedHitBoxes[attackingObjectArrayPos][6].call_funcv(collidedHitBoxes[attackingObjectArrayPos][7])
	#if transcendent but hitbox not connecting with attcker continou attack for attacker
	else:
		var attackingObjectHitlagFrames = calc_hitlag_attacker(attackingObjectArrayPos)
		set_hitlag_frames(attackingObject, attackingObjectHitlagFrames)
	var attackedObjectHitlagFrames = calc_hitlag_attacked(attackedObjectArrayPos)
	set_hitlag_attacked_frames(attackedObject, attackedObjectHitlagFrames)
	collidedHitBoxes[attackedObjectArrayPos][6].call_funcv(collidedHitBoxes[attackedObjectArrayPos][7])
			
	
func manage_collisionboxes_and_hitboxes_connected_no_winner(attackingObject1ArrayPos, attackingObject2ArrayPos):
	var attackingObject1 = collidedHitBoxes[attackingObject1ArrayPos][0]
	var attackingObject2 = collidedHitBoxes[attackingObject2ArrayPos][0]
	#both objects have connecting collisionboxes
	if !collidedHitBoxes[attackingObject1ArrayPos][3].empty()\
	&& !collidedHitBoxes[attackingObject2ArrayPos][3].empty():
		if attackingObject1.is_in_group("Character")\
		&& attackingObject2.is_in_group("Character"):
			manage_character_collisionboxes_and_hitbox_interactions_both_collision(attackingObject1ArrayPos, attackingObject2ArrayPos)
			manage_character_collisionboxes_and_hitbox_interactions_both_collision(attackingObject2ArrayPos, attackingObject1ArrayPos)
	elif !collidedHitBoxes[attackingObject1ArrayPos][3].empty()\
	&& collidedHitBoxes[attackingObject2ArrayPos][3].empty():
		manage_character_collisionboxes_and_hitbox_interactions_one_collision(attackingObject1ArrayPos, attackingObject2ArrayPos)
	elif collidedHitBoxes[attackingObject1ArrayPos][3].empty()\
	&& !collidedHitBoxes[attackingObject2ArrayPos][3].empty():
		manage_character_collisionboxes_and_hitbox_interactions_one_collision(attackingObject2ArrayPos, attackingObject1ArrayPos)

func manage_character_collisionboxes_and_hitbox_interactions_both_collision(attackingObject1ArrayPos, attackingObject2ArrayPos):
	var attackingObject1 = collidedHitBoxes[attackingObject1ArrayPos][0]
	var attackingObject2 = collidedHitBoxes[attackingObject2ArrayPos][0]
	#check if both moves are transcendent 1 = is transcendent,
	if collidedHitBoxes[attackingObject1ArrayPos][5] == 1\
	&& collidedHitBoxes[attackingObject2ArrayPos][5] == 1:
		var attackingObject1HitlagFrames = calc_hitlag_attacked(attackingObject1ArrayPos)
		set_hitlag_attacked_frames(attackingObject2, attackingObject1HitlagFrames)
		collidedHitBoxes[attackingObject1ArrayPos][6].call_funcv(collidedHitBoxes[attackingObject1ArrayPos][7])
	elif collidedHitBoxes[attackingObject1ArrayPos][5] == 1\
	&& collidedHitBoxes[attackingObject2ArrayPos][5] == 0:
		var attackingObject1HitlagFrames = calc_hitlag_attacked(attackingObject1ArrayPos)
		set_hitlag_attacked_frames(attackingObject2, attackingObject1HitlagFrames)
		collidedHitBoxes[attackingObject1ArrayPos][6].call_funcv(collidedHitBoxes[attackingObject1ArrayPos][7])
		var object1HitlagFrames = calc_hitlag_attacker(attackingObject1ArrayPos)
		set_hitlag_frames(attackingObject1, object1HitlagFrames)
	#check if both are non rebound
	elif collidedHitBoxes[attackingObject1ArrayPos][4] == 1:
		attackingObject1.toggle_all_hitboxes("off")
		var object1HitlagFrames = calc_hitlag_attacker(attackingObject1ArrayPos)
		set_hitlag_frames(attackingObject1, object1HitlagFrames)
	#if rebound hitbox
	else:
		attackingObject1.bufferReboundFrames = calc_reboundLag(attackingObject1ArrayPos)
		attackingObject1.change_state(GlobalVariables.CharacterState.REBOUND)

func manage_character_collisionboxes_and_hitbox_interactions_one_collision(attackingObjectArrayPos, attackedObjectArrayPos):
	var attackingObject = collidedHitBoxes[attackingObjectArrayPos][0]
	var attackedObject = collidedHitBoxes[attackedObjectArrayPos][0]
	#if transcendend hitbox, attack other character, apply hitlag to selfe
	if collidedHitBoxes[attackingObjectArrayPos][5] == 1:
		var attackedObjectHitlagFrames = calc_hitlag_attacked(attackedObjectArrayPos)
		set_hitlag_attacked_frames(attackedObject, attackedObjectHitlagFrames)
		collidedHitBoxes[attackingObjectArrayPos][6].call_funcv(collidedHitBoxes[attackingObjectArrayPos][7])
		var attackingObjectHitlagFrames = calc_hitlag_attacker(attackingObjectArrayPos)
		set_hitlag_frames(attackingObject, attackingObjectHitlagFrames)
	#set both characters to state rebound if they can rebound 
	elif collidedHitBoxes[attackingObjectArrayPos][4] == 0\
	&& collidedHitBoxes[attackedObjectArrayPos][4] == 0:
		attackingObject.bufferReboundFrames = calc_reboundLag(attackingObjectArrayPos)
		attackingObject.change_state(GlobalVariables.CharacterState.REBOUND)
		attackedObject.bufferReboundFrames = calc_reboundLag(attackedObjectArrayPos)
		attackedObject.change_state(GlobalVariables.CharacterState.REBOUND)
	#one to rebound one to finish attack 
	elif collidedHitBoxes[attackingObjectArrayPos][4] == 1\
	&& collidedHitBoxes[attackedObjectArrayPos][4] == 0:
		attackingObject.toggle_all_hitboxes("off")
		var attackingObjectHitlagFrames = calc_hitlag_attacker(attackingObjectArrayPos)
		set_hitlag_frames(attackingObject, attackingObjectHitlagFrames)
		attackedObject.bufferReboundFrames = calc_reboundLag(attackedObjectArrayPos)
		attackedObject.change_state(GlobalVariables.CharacterState.REBOUND)
	#one to rebound one to finish attack 
	elif collidedHitBoxes[attackingObjectArrayPos][4] == 0\
	&& collidedHitBoxes[attackedObjectArrayPos][4] == 1:
		attackingObject.bufferReboundFrames = calc_reboundLag(attackingObjectArrayPos)
		attackingObject.change_state(GlobalVariables.CharacterState.REBOUND)
		attackedObject.toggle_all_hitboxes("off")
		var attackedObjectHitlagFrames = calc_hitlag_attacker(attackedObjectArrayPos)
		set_hitlag_frames(attackedObject, attackedObjectHitlagFrames)
		
		
func calc_hitlag_attacker(arrayPosition):
	var attackingObject = collidedHitBoxes[arrayPosition][0]
	var attackingObjectDamage = collidedHitBoxes[arrayPosition][1]
	var attackingObjectHitlagMultiplier = collidedHitBoxes[arrayPosition][2]
	var attackingObjectHitlag = floor((attackingObjectDamage*0.65+4)*attackingObjectHitlagMultiplier + (attackingObject.state.hitlagTimer.get_time_left()*60))
	return attackingObjectHitlag
#	calculate_hitlag_frames_clashed_attackingObject(attackingObjectDamage, attackingObjectHitlagMultiplier, attackingObject)

func calc_hitlag_attacked(arrayPosition):
	var attackedObject = collidedHitBoxes[arrayPosition][0]
	var attackedObjectDamage = collidedHitBoxes[arrayPosition][1]
	var attackedObjectHitlagMultiplier = collidedHitBoxes[arrayPosition][2]
	var attackedObjectHitlag = floor((attackedObjectDamage*0.65+4)*attackedObjectHitlagMultiplier + (attackedObject.state.hitlagTimer.get_time_left()*60))
	return attackedObjectHitlag
#	calculate_hitlag_frames_clashed_attackedObject(attackedObjectDamage, attackedObjectHitlagMultiplier, attackedObject)
	
func calc_reboundLag(arrayPosition):
	var reboundObject = collidedHitBoxes[arrayPosition][0]
	var reboundObjectDamage = collidedHitBoxes[arrayPosition][1]
	var reboundObjectHitlagMultiplier = collidedHitBoxes[arrayPosition][2]
	var reboundObjectHitlag = floor((reboundObjectDamage*0.65+4)*reboundObjectHitlagMultiplier + (reboundObject.state.hitlagTimer.get_time_left()*60))
	return reboundObjectHitlag
	
func set_hitlag_frames(object, objectHitlag):
	object.state.hitlagTimer.stop()
	object.state.start_timer(object.state.hitlagTimer, objectHitlag)

func set_hitlag_attacked_frames(object, objectHitlag):
	object.state.hitlagTimer.stop()
	object.character_attacked_handler(objectHitlag)
