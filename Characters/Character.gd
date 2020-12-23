extends KinematicBody2D

#base stats to return to after changes were made
var baseWalkForce = 1200
var baseWalkMaxSpeed = 600
var baseStopForce = 1500
var baseJumpSpeed = 800

var walkForce = 1200
var walkMaxSpeed = 600
var stopForce = 1500
var jumpSpeed = 850
#jump
var jumpCount = 0
var availabelJumps = 2
var shortHop = true
#platform
var collidePlatforms = true
var dropDownCount = 0
#edge
var snapEdge = false
var snapEdgePosition = Vector2()
var disableInput = false
var hitStun = false
#attack 
var currentAttack = null
var jabCount = 0
var jabCombo = 3
var dashAttackSpeed = 800
#movement
enum moveDirection {LEFT, RIGHT}
var currentMoveDirection = moveDirection.RIGHT
var turnaroundCoefficient = 600
var pushingCharacter =  null
var disableInputDI = false
var inHitStun = false
#bufferInput
var bufferInput = null
#animation needs to finish 
var bufferAnimation = false

var directionChange = false

var velocity = Vector2()

var onSolidGround = false

#character stats
var weight = 100
var fastFallGravity = 4000
onready var gravity = 2000
onready var baseGravity = gravity

enum CharacterState{GROUND, AIR, EDGE,ATTACKGROUND, ATTACKAIR, SPECIAL, ROLL}
#signal for character state change
signal character_state_changed(state)
signal character_turnaround()

var currentState = CharacterState.GROUND

#character aircollider node
onready var airCollider = $AirCollider 
onready var groundCollider = $GroundCollider 

onready var characterSprite = $AnimatedSprite
onready var animationPlayer = $AnimatedSprite/AnimationPlayer

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

func check_input(delta):
	if Input.is_action_just_pressed(attack):
		match currentState:
			CharacterState.AIR:
				switch_to_state(CharacterState.ATTACKAIR)
			CharacterState.GROUND:
				switch_to_state(CharacterState.ATTACKGROUND)
		
func attack_handler_ground():
	if bufferInput != null: 
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
	elif ((abs(get_input_direction_x()) == 0 || jabCount > 0) \
	&& get_input_direction_y() == 0):
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
	elif get_input_direction_y() < 0:
		animation_handler(GlobalVariables.CharacterAnimations.UPTILT)
		currentAttack = GlobalVariables.CharacterAnimations.UPTILT
	elif get_input_direction_y() > 0:
		animation_handler(GlobalVariables.CharacterAnimations.DTILT)
		currentAttack = GlobalVariables.CharacterAnimations.DTILT
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
	input_movement_physics(delta)
	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	# Check for jumping. grounded must be called after movement code
	if Input.is_action_just_pressed(jump):
		animation_handler(GlobalVariables.CharacterAnimations.JUMP)
		#reset gravity if player is jumping
		collidePlatforms = true
		set_collision_mask_bit(1,true)
		dropDownCount = 0
		velocity.y = -jumpSpeed
		jumpCount = 1
		create_jump_timer(0.15)
		switch_to_state(CharacterState.AIR)
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
func create_drop_platform_timer(waittime,inputTimeout):
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(waittime)
	timer.autostart = true
	if inputTimeout:
		timer.connect("timeout", self, "_on_drop_input_timeout")
	else: 
		timer.connect("timeout", self, "_on_drop_platform_timeout")
	add_child(timer)
	
#is called when player is in the air 
func air_handler(delta):
	input_movement_physics(delta)
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
	
func _on_short_hop_timeout():
	if shortHop: 
		velocity.y = 0
				
func _on_drop_platform_timeout():
	switch_to_state(CharacterState.AIR)
	collidePlatforms = false

func _on_drop_input_timeout():
	dropDownCount = 0
	
#creates timer to determine if short or fullhop
func create_jump_timer(waittime):
	shortHop = false
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(waittime)
	timer.autostart = true
	timer.connect("timeout", self, "_on_short_hop_timeout")
	add_child(timer)
	
func create_hitstun_timer(stunTime):
	disableInput = true
	disableInputDI = false
	inHitStun = true
	var timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(stunTime)
	timer.autostart = true
	timer.connect("timeout", self, "_on_hitstun_timeout")
	add_child(timer)
	
func _on_hitstun_timeout():
	inHitStun = false
	enable_player_input()
	
#func create_jab_timer(jabTime):
#	var timer = Timer.new()
#	jabCount += 1
#	timer.set_one_shot(true)
#	timer.set_wait_time(jabTime)
#	timer.autostart = true
#	timer.connect("timeout", self, "_on_jab_timeout")
#	add_child(timer)
#
#func _on_jab_timeout():
#	if jabCount == jabCombo:
#		jabCount = 0
	
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
	check_buffer_input()
	if inHitStun:
#		velocity = velocity.bounce(Vector2(0,1))
		if onSolidGround && int(velocity.y) > 0: 
			velocity.y *= -1
	if disableInputDI:
		var walk = walkForce * get_input_direction_x()
		velocity.x += walk * delta
		velocity.x = clamp(velocity.x, -walkMaxSpeed, walkMaxSpeed)
	else:
		velocity.x = move_toward(velocity.x, 0, stopForce * delta)
	velocity.y += gravity * delta
	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

func input_movement_physics(delta):
	# Horizontal movement code. First, get the player's input.
	var walk = walkForce * get_input_direction_x()
	# Slow down the player if they're not trying to move.
	if abs(walk) < walkForce * 0.2:
		if(currentState == CharacterState.GROUND):
			animationPlayer.play("idle")
		# The velocity, slowed down a bit, and then reassigned.
		if pushingCharacter == null:
			velocity.x = move_toward(velocity.x, 0, stopForce * delta)
	else:
		if(currentState == CharacterState.GROUND):
			animationPlayer.play("walk")
			match currentMoveDirection:
				moveDirection.LEFT:
					if walk > 0: 
						currentMoveDirection = moveDirection.RIGHT
#						characterSprite.flip_h = false
						mirror_areas()
						directionChange = true
						emit_signal("character_turnaround")
				moveDirection.RIGHT:
					if walk < 0: 
						currentMoveDirection = moveDirection.LEFT
#						characterSprite.flip_h = true
						mirror_areas()
						directionChange = true
						emit_signal("character_turnaround")
	if directionChange && ((velocity.x<= 0 && walk >= 0) || (velocity.x>= 0 && walk <= 0)): 
		match currentMoveDirection:
			moveDirection.LEFT:
				velocity.x -= turnaroundCoefficient
				if velocity.x < 0: 
					velocity.x = 0
			moveDirection.RIGHT:
				velocity.x += turnaroundCoefficient
				if velocity.x > 0: 
					velocity.x = 0
		directionChange = false
	else: 
		velocity.x += walk * delta
		
	velocity.x = clamp(velocity.x, -walkMaxSpeed, walkMaxSpeed)

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
		CharacterState.ATTACKAIR:
			currentState = CharacterState.ATTACKAIR
		CharacterState.ATTACKGROUND:
			currentState = CharacterState.ATTACKGROUND
		CharacterState.SPECIAL:
			currentState = CharacterState.SPECIAL
		CharacterState.EDGE:
			currentState = CharacterState.EDGE
		CharacterState.ROLL:
			currentState = CharacterState.ROLL

func is_attacked_handler(damage, hitStun, launchVectorX, launchVectorY, launchVelocity):
	if gravity!=baseGravity:
		gravity=baseGravity
	velocity = Vector2(launchVectorX,launchVectorY)*launchVelocity
	create_hitstun_timer(hitStun)

func enable_player_input():
	if buffered_input():
		attack_handler_ground()
	elif bufferAnimation:
		animationPlayer.play()
		bufferAnimation = false
	else:
		disableInput = false
		disableInputDI = false
		#reset animationplayer playback speed to default
		animationPlayer.set_speed_scale(1.0)

func check_buffer_input():
	#todo: add other inputs for buffer
	if bufferInput == null: 
		if Input.is_action_just_pressed(attack) && get_input_direction_x() == 0 && get_input_direction_y() == 0:
			bufferInput = attack

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
