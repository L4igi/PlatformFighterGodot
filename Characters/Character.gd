extends KinematicBody2D

#base stats to return to after changes were made
var baseDisableInputInfluence = 1200
var baseWalkMaxSpeed = 100
var baseRunMaxSpeed = 600
var baseStopForce = 1500
var baseJumpSpeed = 800
var baseAirSpeed = 600

#walkforce is only used when no input is detected to slow the character down
var disableInputInfluence = 1200
var walkMaxSpeed = 100
var runMaxSpeed = 600
var airMaxSpeed = 600
var airStopForce = 1000
var groundStopForce = 1500
var jumpSpeed = 850
var currentMaxSpeed = runMaxSpeed
#jump
var jumpCount = 0
var availabelJumps = 2
var shortHop = true
onready var shortHopTimer = $ShortHopTimer
#platform
var collidePlatforms = true
var dropDownCount = 0
onready var dropDownTimer = $DropDownTimer
var inputTimeout = false
var atPlatformEdge = null
#edge
var snapEdge = false
var snapEdgePosition = Vector2()
var disableInput = false
#attack 
var smashAttack = null
var currentAttack = null
var jabCount = 0
var jabCombo = 3
var dashAttackSpeed = 800
var chargingSmashAttack = false
#movement
enum moveDirection {LEFT, RIGHT}
var currentMoveDirection = moveDirection.RIGHT
var turnaroundCoefficient = 1500
var pushingCharacter =  null
var disableInputDI = false
var resetMovementSpeed = false
var walkThreashold = 0.3
var currentPushSpeed = 0
#bufferInput
var bufferInput = null
#animation needs to finish 
var bufferAnimation = false
#hitstun 
var inHitStun = false
onready var hitStunTimer = $HitStunTimer
var groundHitStun = 3.0
var getupRollDistance = 100
var tumblingThreashold = 500
#invincibility
onready var invincibilityTimer = $InvincibilityTimer

var directionChange = false

var velocity = Vector2()

var onSolidGround = false

#character stats
var weight = 100
var fastFallGravity = 4000
onready var gravity = 2000
onready var baseGravity = gravity

enum CharacterState{GROUND, AIR, EDGE,ATTACKGROUND, ATTACKAIR, HITSTUNGROUND, HITSTUNAIR, SPECIAL, SHIELD, ROLL, GETUP}
#signal for character state change
signal character_state_changed(state)
signal character_turnaround()

var currentState = CharacterState.GROUND

#character aircollider node
onready var airCollider = $AirCollider 
onready var groundCollider = $GroundCollider 

onready var collisionAreaShape = $InteractionAreas/CollisionArea/CollisionArea

onready var characterSprite = $AnimatedSprite
onready var animationPlayer = $AnimatedSprite/AnimationPlayer

onready var hurtBox = $InteractionAreas/Hurtbox

var attackData = null

#inputs
var up = ""
var down = ""
var left = ""
var right = ""
var jump = ""
var attack = ""
var shield = ""

func _ready():
	self.set_collision_mask_bit(0,false)
	var file = File.new()
	file.open("res://Characters/Mario/marioAttacks.json", file.READ)
	var attacks = JSON.parse(file.get_as_text())
	file.close()
	attackData = attacks.get_result()
	hitStunTimer.connect("timeout", self, "_on_hitstun_timeout")
	shortHopTimer.connect("timeout", self, "_on_short_hop_timeout")
	dropDownTimer.connect("timeout", self, "_on_drop_timer_timeout")
	invincibilityTimer.connect("timeout", self, "_on_invincibility_timer_timeout")
#	animationPlayer.set_blend_time("fair","freefall", 0.05)

func _physics_process(delta):
	if disableInput:
		process_movement_physics(delta)
		check_buffer_input()
		if currentState == CharacterState.AIR || currentState == CharacterState.ATTACKAIR:
			if onSolidGround && int(velocity.y) == 0:
				switch_to_state(CharacterState.GROUND)
#				animationPlayer.play("idle")
				#if aerial attack is interrupted by ground cancel hitboxes
				toggle_all_hitboxes("off")
		elif currentState == CharacterState.GROUND || currentState == CharacterState.ATTACKGROUND:
			if int(velocity.y) != 0:
				jumpCount = 1
				switch_to_state(CharacterState.AIR)
				animationPlayer.play("freefall")
				toggle_all_hitboxes("off")
		#if character is in hitstun and lands on ground finish hurt animation
		elif currentState == CharacterState.HITSTUNAIR:
			if onSolidGround && int(velocity.y) == 0:
				if hitStunTimer.time_left != 0:
					animationPlayer.play()
					bufferAnimation = false
					create_hitstun_timer(groundHitStun)
				switch_to_state(CharacterState.HITSTUNGROUND)
				#plays rest of hitstun animation if hitting ground during hitstun
		elif currentState == CharacterState.HITSTUNGROUND:
			pass
					
	if !disableInput:
		check_input(delta)
		match currentState:
			CharacterState.EDGE:
				edge_handler(delta)
			CharacterState.AIR:
				air_handler(delta)
			CharacterState.ATTACKAIR:
				attack_handler_air()
			CharacterState.ATTACKGROUND:
				attack_handler_ground()
			CharacterState.GROUND:
				ground_handler(delta)
			CharacterState.HITSTUNAIR:
				hitstun_handler(delta)
			CharacterState.HITSTUNGROUND:
				hitstun_handler(delta)
			CharacterState.SHIELD:
				shield_handler(delta)

func check_input(delta):
		if Input.is_action_just_pressed(attack) && Input.is_action_just_pressed(right) && currentState == CharacterState.GROUND:
			smashAttack = GlobalVariables.SmashAttacks.SMASHRIGHT
			switch_to_state(CharacterState.ATTACKGROUND)
		elif Input.is_action_just_pressed(attack) && Input.is_action_just_pressed(left) && currentState == CharacterState.GROUND:
			smashAttack = GlobalVariables.SmashAttacks.SMASHLEFT
			switch_to_state(CharacterState.ATTACKGROUND)
		elif Input.is_action_just_pressed(attack) && Input.is_action_just_pressed(up) && currentState == CharacterState.GROUND:
			smashAttack = GlobalVariables.SmashAttacks.SMASHUP
			switch_to_state(CharacterState.ATTACKGROUND)
		elif Input.is_action_just_pressed(attack) && Input.is_action_just_pressed(down) && currentState == CharacterState.GROUND:
			smashAttack = GlobalVariables.SmashAttacks.SMASHDOWN
			switch_to_state(CharacterState.ATTACKGROUND)
		elif Input.is_action_just_pressed(attack) && !inHitStun:
			match currentState:
				CharacterState.AIR:
					switch_to_state(CharacterState.ATTACKAIR)
				CharacterState.GROUND:
					switch_to_state(CharacterState.ATTACKGROUND)
		elif Input.is_action_just_pressed(shield) && currentState == CharacterState.GROUND:
			print("SHILED")
			animation_handler(GlobalVariables.CharacterAnimations.SHIELD)
			switch_to_state(CharacterState.SHIELD)
		
func attack_handler_ground():
	if smashAttack != null: 
#		print("SMASH " +str(smashAttack))
		match smashAttack: 
			GlobalVariables.SmashAttacks.SMASHRIGHT:
				if currentMoveDirection != moveDirection.RIGHT:
					print("mirror areas right")
					currentMoveDirection = moveDirection.RIGHT
					mirror_areas()
				animation_handler(GlobalVariables.CharacterAnimations.FSMASH)
				currentAttack = GlobalVariables.CharacterAnimations.FSMASH
			GlobalVariables.SmashAttacks.SMASHLEFT:
				if currentMoveDirection != moveDirection.LEFT:
					print("mirror areas left")
					currentMoveDirection = moveDirection.LEFT
					mirror_areas()
				animation_handler(GlobalVariables.CharacterAnimations.FSMASH)
				currentAttack = GlobalVariables.CharacterAnimations.FSMASH
			GlobalVariables.SmashAttacks.SMASHUP:
				animation_handler(GlobalVariables.CharacterAnimations.UPSMASH)
				currentAttack = GlobalVariables.CharacterAnimations.UPSMASH
			GlobalVariables.SmashAttacks.SMASHDOWN:
				animation_handler(GlobalVariables.CharacterAnimations.DSMASH)
				currentAttack = GlobalVariables.CharacterAnimations.DSMASH
	elif bufferInput != null || ((abs(get_input_direction_x()) == 0 || jabCount > 0) \
	&& get_input_direction_y() == 0):
		jab_handler()
	elif get_input_direction_y() < 0:
		animation_handler(GlobalVariables.CharacterAnimations.UPTILT)
		currentAttack = GlobalVariables.CharacterAnimations.UPTILT
	elif get_input_direction_y() > 0:
		animation_handler(GlobalVariables.CharacterAnimations.DTILT)
		currentAttack = GlobalVariables.CharacterAnimations.DTILT
	elif currentMaxSpeed == baseWalkMaxSpeed: 
		animation_handler(GlobalVariables.CharacterAnimations.FTILT)
		currentAttack = GlobalVariables.CharacterAnimations.FTILT
	else: 
		#attack
		match currentMoveDirection:
			moveDirection.LEFT:
				velocity.x = -dashAttackSpeed
			moveDirection.RIGHT:
				velocity.x = dashAttackSpeed
		animation_handler(GlobalVariables.CharacterAnimations.DASHATTACK)
		currentAttack = GlobalVariables.CharacterAnimations.DASHATTACK
#	switch_to_state(CharacterState.GROUND)
			
func jab_handler():
	match jabCount:
		0:
			animation_handler(GlobalVariables.CharacterAnimations.JAB1)
			currentAttack = GlobalVariables.CharacterAnimations.JAB1
		1:
			animation_handler(GlobalVariables.CharacterAnimations.JAB2)
			currentAttack = GlobalVariables.CharacterAnimations.JAB2
		2:
			animation_handler(GlobalVariables.CharacterAnimations.JAB3)
			currentAttack = GlobalVariables.CharacterAnimations.JAB3
	jabCount += 1
	if jabCount > jabCombo: 
		jabCount = 0
		
func attack_handler_air():
	if abs(get_input_direction_x()) < 0.1\
	&& abs(get_input_direction_y()) < 0.1:
		animation_handler(GlobalVariables.CharacterAnimations.NAIR)
		currentAttack = GlobalVariables.CharacterAnimations.NAIR
	elif get_input_direction_y() < 0:
		animation_handler(GlobalVariables.CharacterAnimations.UPAIR)
		currentAttack = GlobalVariables.CharacterAnimations.UPAIR
		pass
	elif get_input_direction_x() > 0 && currentMoveDirection == moveDirection.RIGHT\
	|| get_input_direction_x() < 0 && currentMoveDirection == moveDirection.LEFT: 
		animation_handler(GlobalVariables.CharacterAnimations.FAIR)
		currentAttack = GlobalVariables.CharacterAnimations.FAIR
	elif get_input_direction_x() > 0 && currentMoveDirection == moveDirection.LEFT\
	|| get_input_direction_x() < 0 && currentMoveDirection == moveDirection.RIGHT: 
		animation_handler(GlobalVariables.CharacterAnimations.BAIR)
		currentAttack = GlobalVariables.CharacterAnimations.BAIR
	elif get_input_direction_y() > 0:
		animation_handler(GlobalVariables.CharacterAnimations.DAIR)
		currentAttack = GlobalVariables.CharacterAnimations.DAIR
#	switch_to_state(CharacterState.AIR)
			
func ground_handler(delta):
	#reset gravity if player is grounded
	if gravity!=baseGravity:
		gravity=baseGravity
	input_movement_physics_ground(delta)
	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	# Check for jumping. grounded must be called after movement code
	if Input.is_action_just_pressed(jump):
		jump_handler()
	#shorthop depending on button press length 
	elif Input.is_action_just_pressed(down):
		dropDownCount += 1
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("Platform") && dropDownCount >=2:
				set_collision_mask_bit(1,false)
				create_drop_platform_timer(0.3, false)
			else: 
				create_drop_platform_timer(0.5, true)
	#checks if player walked off platform/stage
	elif velocity.y != 0:
		jumpCount = 1
		if currentState != CharacterState.AIR:
			switch_to_state(CharacterState.AIR)
		animationPlayer.play("freefall")
		toggle_all_hitboxes("off")

#creates timer after dropping through platform to enable/diable collision
func create_drop_platform_timer(waittime,setInputTimeout):
	if setInputTimeout:
		inputTimeout = true
	else: 
		inputTimeout = false
	dropDownTimer.set_wait_time(waittime)
	dropDownTimer.start()
	
#is called when player is in the air 
func air_handler(delta):
	input_movement_physics_air(delta)
	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	if Input.is_action_just_pressed(jump) && jumpCount < availabelJumps:
		animation_handler(GlobalVariables.CharacterAnimations.DOUBLEJUMP)
		if gravity!=baseGravity:
			gravity=baseGravity
		velocity.y = -jumpSpeed
		if currentMoveDirection == moveDirection.LEFT && get_input_direction_x() != -1:
			pass
			velocity.x = 0
		elif currentMoveDirection == moveDirection.RIGHT && get_input_direction_x() != 1:
			velocity.x = 0
		jumpCount += 1
	if Input.is_action_just_released(jump) && jumpCount == 1:
		shortHop = true
	#enable collisons with platforms if player is falling down
	if !collidePlatforms && velocity.y >= 0: 
		collidePlatforms = true
		set_collision_mask_bit(1,true)
	#Fastfall
	if Input.is_action_just_pressed(down) && !onSolidGround && int(velocity.y) >= 0:
		gravity = fastFallGravity
	if int(velocity.y) == 0 && onSolidGround:
		switch_to_state(CharacterState.GROUND)
		#if aerial attack is interrupted by ground cancel hitboxes
		toggle_all_hitboxes("off")

func jump_handler():
	animation_handler(GlobalVariables.CharacterAnimations.JUMP)
	#reset gravity if player is jumping
	collidePlatforms = true
	set_collision_mask_bit(1,true)
	dropDownCount = 0
	velocity.y = -jumpSpeed
	jumpCount = 1
	create_jump_timer(0.15)
	switch_to_state(CharacterState.AIR)
		
func double_jump_handler():
	animation_handler(GlobalVariables.CharacterAnimations.DOUBLEJUMP)
	if gravity!=baseGravity:
		gravity=baseGravity
	velocity.y = -jumpSpeed
	if currentMoveDirection == moveDirection.LEFT && get_input_direction_x() != -1:
		pass
		velocity.x = 0
	elif currentMoveDirection == moveDirection.RIGHT && get_input_direction_x() != 1:
		velocity.x = 0
	jumpCount += 1
		
func _on_short_hop_timeout():
	if shortHop: 
		velocity.y = 0
				
func _on_drop_timer_timeout():
	if inputTimeout:
		inputTimeout = false
		dropDownCount = 0
	else:
		switch_to_state(CharacterState.AIR)
		collidePlatforms = false
	
#creates timer to determine if short or fullhop
func create_jump_timer(waittime):
	shortHop = false
	shortHopTimer.set_wait_time(waittime)
	shortHopTimer.start()
	
func hitstun_handler(delta):
	if onSolidGround && int(velocity.y) == 0 && currentState == CharacterState.HITSTUNAIR:
		switch_to_state(CharacterState.HITSTUNGROUND)
		#plays rest of hitstun animation if hitting ground during hitstun
		animationPlayer.play()
		bufferAnimation = false
		create_hitstun_timer(groundHitStun)
	elif currentState == CharacterState.HITSTUNGROUND: 
		#if not in hitstun check for jump, attack or special 
		#todo: check for special
		if Input.is_action_just_pressed(attack):
			switch_to_state(CharacterState.GETUP)
			animation_handler(GlobalVariables.CharacterAnimations.ATTACKGETUP)
		elif Input.is_action_just_pressed(up):
			switch_to_state(CharacterState.GETUP)
			animation_handler(GlobalVariables.CharacterAnimations.NORMALGETUP)
		elif Input.is_action_just_pressed(left):
			print("rolling left")
			switch_to_state(CharacterState.GETUP)
			if currentMoveDirection != moveDirection.LEFT:
				currentMoveDirection = moveDirection.LEFT
				mirror_areas()
			animation_handler(GlobalVariables.CharacterAnimations.ROLLGETUP)
		elif Input.is_action_just_pressed(right):
			print("rolling right")
			switch_to_state(CharacterState.GETUP)
			if currentMoveDirection != moveDirection.RIGHT:
				currentMoveDirection = moveDirection.RIGHT
				mirror_areas()
			animation_handler(GlobalVariables.CharacterAnimations.ROLLGETUP)
	elif currentState == CharacterState.HITSTUNAIR:
		#if not in hitstun check for jump, attack or special 
		#todo: check for special
		if !inHitStun: 
			if Input.is_action_just_pressed(attack):
				switch_to_state(CharacterState.ATTACKAIR)
				attack_handler_air()
			elif Input.is_action_just_pressed(jump):
				switch_to_state(CharacterState.AIR)
				double_jump_handler()
	process_movement_physics(delta)
	#switch to other animation on button press
	
func create_hitstun_timer(stunTime):
	disableInput = true
	disableInputDI = false
	inHitStun = true
	hitStunTimer.set_wait_time(stunTime)
	hitStunTimer.start()
	
func _on_hitstun_timeout():
#	print("hitstun timeout")
	inHitStun = false
#	if velocity.y != 0: 
#		switch_to_state(CharacterState.AIR)
#	else:
#		switch_to_state(CharacterState.GROUND)
	enable_player_input()
	
func shield_handler(delta):
	process_movement_physics(delta)
	if Input.is_action_just_released(shield):
		switch_to_state(CharacterState.GROUND)
	
func snap_edge(edgePosition):
	if !onSolidGround:
		switch_to_state(CharacterState.EDGE)
		disableInput = true
		gravity = baseGravity
		snapEdgePosition = edgePosition
		velocity = Vector2.ZERO
		var targetPosition = edgePosition + characterSprite.frames.get_frame("idle",0).get_size()/2
		if global_position < edgePosition:
			targetPosition = edgePosition + Vector2(-(characterSprite.frames.get_frame("idle",0).get_size()/2).x,(characterSprite.frames.get_frame("idle",0).get_size()/2).y)
		$Tween.interpolate_property(self, "position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		yield($Tween, "tween_all_completed")
		snapEdge = true
		enable_player_input()
		
func edge_handler(delta):
	disableInput = true
	jumpCount = 0
	velocity = Vector2.ZERO
	var targetPosition = Vector2.ZERO
	if Input.is_action_just_pressed(down):
		switch_to_state(CharacterState.AIR)
		snapEdge=false
	elif Input.is_action_just_pressed(jump):
		switch_to_state(CharacterState.AIR)
		velocity.y = -jumpSpeed
		jumpCount += 1
		#disables collisons with platforms if player is jumping upwards
		collidePlatforms = false
		set_collision_mask_bit(1,false)
		snapEdge=false
	elif Input.is_action_just_pressed(left):
		if global_position < snapEdgePosition:
			switch_to_state(CharacterState.AIR)
			velocity.x = -walkMaxSpeed/4
			snapEdge=false
		else:
			targetPosition = snapEdgePosition - get_character_size()/2
			$Tween.interpolate_property(self, "position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			snapEdge=false
			switch_to_state(CharacterState.GROUND)
	elif Input.is_action_just_pressed(right):
		if global_position > snapEdgePosition:
			velocity.x = walkMaxSpeed/4
			snapEdge=false
			switch_to_state(CharacterState.AIR)
		else: 
			targetPosition = snapEdgePosition - Vector2(-(get_character_size()/2).x,(get_character_size()/2).y)
			$Tween.interpolate_property(self, "position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			snapEdge=false
			switch_to_state(CharacterState.GROUND)
	elif Input.is_action_just_pressed(up):
		if global_position > snapEdgePosition:
			#normal getup right edge
			targetPosition = snapEdgePosition - get_character_size()/2
			$Tween.interpolate_property(self, "position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			snapEdge=false 
			switch_to_state(CharacterState.GROUND)
		else: 
			targetPosition = snapEdgePosition - Vector2(-(get_character_size()/2).x,(get_character_size()/2).y)
			$Tween.interpolate_property(self, "position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			snapEdge=false 
			switch_to_state(CharacterState.GROUND)
	elif Input.is_action_just_pressed(shield):
		if global_position > snapEdgePosition:
			#normal getup right edge
			targetPosition = snapEdgePosition - Vector2((get_character_size()/2).x*4,(get_character_size()/2).y)
			$Tween.interpolate_property(self, "position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			snapEdge=false 
			switch_to_state(CharacterState.GROUND)
		else: 
			targetPosition = snapEdgePosition - Vector2(-(get_character_size()/2).x*4,(get_character_size()/2).y)
			$Tween.interpolate_property(self, "position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			snapEdge=false 
			switch_to_state(CharacterState.GROUND)
	enable_player_input()

func get_character_size():
	return characterSprite.frames.get_frame("idle",0).get_size()
	
func animation_handler(animationToPlay):
	match animationToPlay:
		GlobalVariables.CharacterAnimations.IDLE:
			animationPlayer.play("idle")
		GlobalVariables.CharacterAnimations.WALK:
			animationPlayer.play("walk")
		GlobalVariables.CharacterAnimations.RUN:
			pass
		GlobalVariables.CharacterAnimations.JUMP:
			animationPlayer.play("jump")
			animationPlayer.queue("freefall")
#			yield(animationPlayer, "animation_finished")
		GlobalVariables.CharacterAnimations.DOUBLEJUMP:
			animationPlayer.play("doublejump")
			animationPlayer.queue("freefall")
		GlobalVariables.CharacterAnimations.NAIR:
			play_attack_animation("nair")
			disableInputDI = true
		GlobalVariables.CharacterAnimations.DASHATTACK: 
			play_attack_animation("dash_attack")
		GlobalVariables.CharacterAnimations.JAB1:
			play_attack_animation("jab1")
		GlobalVariables.CharacterAnimations.JAB2:
			play_attack_animation("jab2")		
		GlobalVariables.CharacterAnimations.JAB3:
			play_attack_animation("jab2")
		GlobalVariables.CharacterAnimations.FTILT:
			play_attack_animation("ftilt")
		GlobalVariables.CharacterAnimations.UPTILT:
			play_attack_animation("uptilt")
		GlobalVariables.CharacterAnimations.UPAIR:
			play_attack_animation("upair")
			disableInputDI = true
		GlobalVariables.CharacterAnimations.FAIR:
			play_attack_animation("fair")
			disableInputDI = true
		GlobalVariables.CharacterAnimations.BAIR:
			play_attack_animation("bair")
			disableInputDI = true
		GlobalVariables.CharacterAnimations.DTILT:
			play_attack_animation("dtilt")
			disableInputDI = true
		GlobalVariables.CharacterAnimations.DAIR:
			play_attack_animation("dair")
			disableInputDI = true
		GlobalVariables.CharacterAnimations.UPSMASH:
			play_attack_animation("upsmash")
		GlobalVariables.CharacterAnimations.DSMASH:
			play_attack_animation("dsmash")
		GlobalVariables.CharacterAnimations.FSMASH:
			play_attack_animation("fsmash")
		GlobalVariables.CharacterAnimations.HURT:
			animationPlayer.stop(true)
			animationPlayer.play("hurt")
		GlobalVariables.CharacterAnimations.HURTSHORT:
			animationPlayer.stop(true)
			animationPlayer.play("hurt_short")
		GlobalVariables.CharacterAnimations.ATTACKGETUP:
			animationPlayer.play("attack_getup")
		GlobalVariables.CharacterAnimations.ROLLGETUP:
			animationPlayer.play("roll_getup")
			if currentMoveDirection == moveDirection.LEFT:
				getupRollDistance = abs(getupRollDistance) * -1
				if atPlatformEdge == moveDirection.LEFT:
					velocity.x = 0
				else:
					velocity.x = getupRollDistance
			else:
				getupRollDistance = abs(getupRollDistance)
				if atPlatformEdge == moveDirection.RIGHT:
					velocity.x = 0
				else:
					velocity.x = getupRollDistance
		GlobalVariables.CharacterAnimations.NORMALGETUP:
			animationPlayer.play("normal_getup")
		GlobalVariables.CharacterAnimations.SHIELD:
			animationPlayer.play("shield")
			
func play_attack_animation(animationToPlay, playBackSpeed = 1):
	disableInput = true
	animationPlayer.play(animationToPlay, -1, playBackSpeed, false)
	yield(animationPlayer, "animation_finished")
	toggle_all_hitboxes("off")
	if bufferInput == null:
		match currentState:
			CharacterState.ATTACKGROUND:
				switch_to_state(CharacterState.GROUND)
				animationPlayer.queue("idle")
			CharacterState.ATTACKAIR:
				switch_to_state(CharacterState.AIR)
				animationPlayer.queue("freefall")
	bufferInput = null
#	enable_player_input()

func apply_attack_movement_stats(step = 0):
	pass
	
func process_movement_physics(delta):
#	check_buffer_input()
	if currentState == CharacterState.HITSTUNGROUND || currentState == CharacterState.HITSTUNAIR:
#		velocity = velocity.bounce(Vector2(0,1))
		if onSolidGround && int(velocity.y) > 0: 
			velocity.y *= -1
		velocity.x = move_toward(velocity.x, 0, groundStopForce * delta)
	if disableInputDI:
		var walk = disableInputInfluence * get_input_direction_x()
		velocity.x += walk * delta
		velocity.x = clamp(velocity.x, -walkMaxSpeed, walkMaxSpeed)
	else:
		if currentState == CharacterState.GROUND || currentState == CharacterState.ATTACKGROUND:
			velocity.x = move_toward(velocity.x, 0, groundStopForce * delta)
		elif currentState == CharacterState.AIR || currentState == CharacterState.ATTACKAIR:
			velocity.x = move_toward(velocity.x, 0, airStopForce * delta)
		elif currentState == CharacterState.SHIELD:
			velocity.x = move_toward(velocity.x, 0, airStopForce * delta)
	velocity.y += gravity * delta
	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

func input_movement_physics_ground(delta):
	# Horizontal movement code. First, get the player's input.
	var xInput = get_input_direction_x()
	if xInput == 0:
		resetMovementSpeed = true
	if resetMovementSpeed && xInput != 0 && pushingCharacter == null: 
		resetMovementSpeed = false
		change_max_speed(xInput)
	# Slow down the player if they're not trying to move.
	if abs(xInput) < 0.05:
		if(currentState == CharacterState.GROUND):
			animationPlayer.play("idle")
		# The velocity, slowed down a bit, and then reassigned.
		if pushingCharacter == null:
			velocity.x = move_toward(velocity.x, 0, groundStopForce * delta)
	else:
		if currentMaxSpeed == baseWalkMaxSpeed:
			animationPlayer.play("walk")
		else:
			animationPlayer.play("run")
		match currentMoveDirection:
			moveDirection.LEFT:
				if xInput > 0: 
					currentMoveDirection = moveDirection.RIGHT
#						characterSprite.flip_h = false
					mirror_areas()
					directionChange = true
					change_max_speed(xInput)
					emit_signal("character_turnaround")
			moveDirection.RIGHT:
				if xInput < 0: 
					currentMoveDirection = moveDirection.LEFT
#						characterSprite.flip_h = true
					mirror_areas()
					directionChange = true
					change_max_speed(xInput)
					emit_signal("character_turnaround")
		if directionChange && ((velocity.x<= 0 && xInput >= 0) || (velocity.x>= 0 && xInput <= 0)): 
			match currentMoveDirection:
				moveDirection.LEFT:
					velocity.x -= turnaroundCoefficient * delta 
					if velocity.x < 0: 
						directionChange = false
				moveDirection.RIGHT:
					velocity.x += turnaroundCoefficient * delta 
					if velocity.x > 0: 
						directionChange = false
#			directionChange = false
		else: 
			if currentMaxSpeed == baseWalkMaxSpeed:
				if pushingCharacter != null:
					pass
					#handled in character collision response script
	#				velocity.x += xInput * currentMaxSpeed
				else:
					velocity.x = xInput * currentMaxSpeed
					velocity.x = clamp(velocity.x, -currentMaxSpeed, currentMaxSpeed)
			else:
				if pushingCharacter != null: 
					#handled in character collision response script
					pass
	#				velocity.x += xInput * currentMaxSpeed
				else:
					velocity.x = xInput * currentMaxSpeed
					velocity.x = clamp(velocity.x, -currentMaxSpeed, currentMaxSpeed)
		
#	

	# Vertical movement code. Apply gravity.
	velocity.y += gravity * delta
	
func change_max_speed(xInput):
	if abs(xInput) > walkThreashold:
		currentMaxSpeed = baseRunMaxSpeed
	else:
		currentMaxSpeed = baseWalkMaxSpeed

func input_movement_physics_air(delta):
	# Horizontal movement code. First, get the player's input.
	var xInput = get_input_direction_x()
	var walk = airMaxSpeed * xInput
	# Slow down the player if they're not trying to move.
	if abs(xInput) < 0.05:
		if pushingCharacter == null:
			velocity.x = move_toward(velocity.x, 0, airStopForce * delta)
	else:
		#improves are moveability when pressing the opposite direction as currently looking
		if currentMoveDirection == moveDirection.LEFT &&\
		xInput > 0: 
			velocity.x += (walk * delta)*2
		elif currentMoveDirection == moveDirection.RIGHT &&\
		xInput < 0: 
			velocity.x += (walk * delta)*2
			
		else:
			velocity.x += (walk * delta)*2
#	print(currentMaxSpeed)
	velocity.x = clamp(velocity.x, -airMaxSpeed, airMaxSpeed)
	# Vertical movement code. Apply gravity.
	velocity.y += gravity * delta
	
func toggle_all_hitboxes(onOff):
	match onOff: 
		"on":
			for areaHitbox in $AnimatedSprite/HitBoxes.get_children():
				for hitbox in areaHitbox.get_children():
					if hitbox is CollisionShape2D:
						hitbox.disabled = false
		"off":
			if !inHitStun:
				enable_player_input()
			for areaHitbox in $AnimatedSprite/HitBoxes.get_children():
				for hitbox in areaHitbox.get_children():
					if hitbox is CollisionShape2D:
						hitbox.disabled = true
			$InteractionAreas.set_position(Vector2(0,0))
			$InteractionAreas.set_rotation(0)

func mirror_areas():
	match currentMoveDirection:
		moveDirection.LEFT:
			self.set_scale(Vector2(-1, 1))
		moveDirection.RIGHT:
			self.set_scale(Vector2(-1, -1))
				
func get_input_direction_x():
	return Input.get_action_strength(right) - Input.get_action_strength(left)
			
func get_input_direction_y():
	return Input.get_action_strength(down) - Input.get_action_strength(up)
			
func switch_to_state(state):
	match state: 
		CharacterState.GROUND:
			currentState = CharacterState.GROUND
			airCollider.set_disabled(true)
			airCollider.visible = false
			groundCollider.set_disabled(false)
			groundCollider.visible = true
			emit_signal("character_state_changed", currentState)
		CharacterState.AIR:
			currentState = CharacterState.AIR
			airCollider.set_disabled(false)
			airCollider.visible = true
			groundCollider.set_disabled(true)
			groundCollider.visible = false
			emit_signal("character_state_changed", currentState)
		CharacterState.HITSTUNAIR:
			currentState = CharacterState.HITSTUNAIR
			emit_signal("character_state_changed", currentState)
		CharacterState.HITSTUNGROUND:
			currentState = CharacterState.HITSTUNGROUND
			emit_signal("character_state_changed", currentState)
		CharacterState.ATTACKAIR:
			currentState = CharacterState.ATTACKAIR
			emit_signal("character_state_changed", currentState)
		CharacterState.ATTACKGROUND:
			currentState = CharacterState.ATTACKGROUND
			emit_signal("character_state_changed", currentState)
		CharacterState.SPECIAL:
			currentState = CharacterState.SPECIAL
		CharacterState.EDGE:
			currentState = CharacterState.EDGE
		CharacterState.ROLL:
			currentState = CharacterState.ROLL
		CharacterState.GETUP:
			currentState = CharacterState.GETUP
			emit_signal("character_state_changed", currentState)
		CharacterState.SHIELD:
			currentState = CharacterState.SHIELD
			emit_signal("character_state_changed", currentState)

func is_attacked_handler(damage, hitStun, launchVectorX, launchVectorY, launchVelocity):
	if gravity!=baseGravity:
		gravity=baseGravity
	chargingSmashAttack = false
	smashAttack = null
	bufferInput = null
	velocity = Vector2(launchVectorX,launchVectorY)*launchVelocity
	if launchVelocity > tumblingThreashold:
	#todo: calculate if in tumble animation
		switch_to_state(CharacterState.HITSTUNAIR)
	#todo hitstun ground?
	#play idle animation in hitstun 
	#todo: replace with knockback/hurt animation
		animation_handler(GlobalVariables.CharacterAnimations.HURT)
	else: 
		if onSolidGround && velocity.y == 0:
			switch_to_state(CharacterState.GROUND)
		else:
			switch_to_state(CharacterState.AIR)
		animation_handler(GlobalVariables.CharacterAnimations.HURTSHORT)
	create_hitstun_timer(hitStun)

func enable_player_input():
	if buffered_input():
		attack_handler_ground()
	elif bufferAnimation:
		print("Buffer animation")
		animationPlayer.play()
		bufferAnimation = false
	else:
		disableInput = false
		disableInputDI = false
		#reset animationplayer playback speed to default
		animationPlayer.set_speed_scale(1.0)
		#reset InteractionArea Position/Rotation/Scale to default
		$InteractionAreas.reset_global_transform()

func check_buffer_input():
	#todo: add other inputs for buffer
	if bufferInput == null: 
		if currentState == CharacterState.ATTACKGROUND:
			if Input.is_action_just_pressed(attack) && get_input_direction_x() == 0 && get_input_direction_y() == 0:
				bufferInput = attack
	if chargingSmashAttack:
		if Input.is_action_just_released(attack) && chargingSmashAttack:
			chargingSmashAttack = false
			apply_smash_attack_steps(2)
	

func buffered_input():
	if bufferInput == null: 
		jabCount = 0
		return false
	return true

func gravity_on_off(status):
	if status == "on":
		gravity = baseGravity
	elif status == "off":
		gravity = 0

func apply_smash_attack_steps(step = 0):
	match step:
		0:
			disableInputDI = false
			chargingSmashAttack = true
		1:
			if chargingSmashAttack:
				animationPlayer.stop(false)
		2:
			animationPlayer.play()
			smashAttack = null

func apply_hurt_animation_step(step =0):
	match step: 
		0:
			disableInputDI = false
		1:
			if !onSolidGround && velocity.y != 0:
				animationPlayer.stop(false)
		2:
			disableInput = false
			
func ground_getup_handler(step = 0):
	match step: 
		0:
			disableInput = true
			collisionAreaShape.set_disabled(true)
			create_invincible_timer(animationPlayer.current_animation_length)
		1:
			disableInput = false
			collisionAreaShape.set_disabled(false)
			switch_to_state(CharacterState.GROUND)

func create_invincible_timer(duration = 0):
	invincibilityTimer.set_wait_time(duration)
	enable_diable_hurtboxes(false)
	invincibilityTimer.start()

func _on_invincibility_timer_timeout():
	enable_diable_hurtboxes(true)

func enable_diable_hurtboxes(enable = true):
	for singleHurtbox in hurtBox.get_children():
		if enable:
			singleHurtbox.set_disabled(false)
		else:
			singleHurtbox.set_disabled(true)
