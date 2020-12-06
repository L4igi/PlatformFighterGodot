extends KinematicBody2D

var WALK_FORCE = 1200
var WALK_MAX_SPEED = 600
var STOP_FORCE = 1500
var JUMP_SPEED = 800
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
#attack 
var jabCount = 0
var jabCombo = 3
var dashAttackSpeed = 800
#movement
enum moveDirection {LEFT, RIGHT}
var currentMoveDirection = moveDirection.RIGHT
var turnaroundCoefficient = 600
var pushingCharacter =  null

var directionChange = false

var velocity = Vector2()

#character stats
var weight = 100
onready var gravity = 2000
onready var baseGravity = gravity

enum CharacterState{GROUND, AIR, EDGE,ATTACKGROUND, ATTACKAIR, SPECIAL, ROLL, STUN}

enum CharacterAnimations{IDLE, WALK, RUN, SLIDE, JUMP, DOUBLEJUMP, FREEFALL, JAB1, NAIR, DASHATTACK}

var currentState = CharacterState.GROUND

onready var characterSprite = $AnimatedSprite
onready var animationPlayer = $AnimatedSprite/AnimationPlayer

#inputs
var up = ""
var down = ""
var left = ""
var right = ""
var jump = ""
var attack = ""
var shield = ""

func _physics_process(delta):
	print(str(self.name) + " " + str(self.get_collision_mask_bit(0)))
	switch_WorldColliders()
	if disableInput:
		process_movement_physics(delta)
		if currentState == CharacterState.AIR:
			if is_on_floor():
				currentState = CharacterState.GROUND
				
				#if aerial attack is interrupted by ground cancel hitboxes
				toggle_all_hitboxes("off")
		elif currentState == CharacterState.GROUND:
			if velocity.y != 0:
				jumpCount = 1
				currentState = CharacterState.AIR
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
				attack_handler_air(delta)
			CharacterState.ATTACKGROUND:
				attack_handler_ground(delta)
			CharacterState.GROUND:
				ground_handler(delta)

func check_input(delta):
	if Input.is_action_just_pressed(attack):
		match currentState:
			CharacterState.AIR:
				currentState = CharacterState.ATTACKAIR
			CharacterState.GROUND:
				currentState = CharacterState.ATTACKGROUND
		
func attack_handler_ground(delta):
	if abs(velocity.x) < 150:
		animation_handler(CharacterAnimations.JAB1)
	else: 
		#dashattack
		match currentMoveDirection:
			moveDirection.LEFT:
				velocity.x = -dashAttackSpeed
			moveDirection.RIGHT:
				velocity.x = dashAttackSpeed
		print(velocity.x)
		animation_handler(CharacterAnimations.DASHATTACK)
	currentState = CharacterState.GROUND
			
func attack_handler_air(delta):
	if abs((Input.get_action_strength(right) - Input.get_action_strength(left))) < 0.1:
		animation_handler(CharacterAnimations.NAIR)
	currentState = CharacterState.AIR
			
func ground_handler(delta):
	#reset gravity if player is grounded
	if gravity!=baseGravity:
		gravity=baseGravity
	input_movement_physics(delta)
	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	# Check for jumping. is_on_floor() must be called after movement code
	if Input.is_action_just_pressed(jump):
		animation_handler(CharacterAnimations.JUMP)
		#reset gravity if player is jumping
		collidePlatforms = true
		set_collision_mask_bit(1,true)
		dropDownCount = 0
		velocity.y = -JUMP_SPEED
		jumpCount = 1
		create_jump_timer(0.15)
		currentState = CharacterState.AIR
	#shorthop depending on button press length 
	if Input.is_action_just_pressed(down):
		dropDownCount += 1
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			#print("is in group " + str(collision.get_collider().is_in_group("Platform")))
			if collision.get_collider().is_in_group("Platform") && dropDownCount >=2:
				set_collision_mask_bit(1,false)
				create_drop_platform_timer(0.3, false)
			else: 
				create_drop_platform_timer(0.5, true)
	#checks if player walked off platform/stage
	if velocity.y != 0:
		jumpCount = 1
		currentState = CharacterState.AIR
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
		animation_handler(CharacterAnimations.DOUBLEJUMP)
		if gravity!=baseGravity:
			gravity=baseGravity
		velocity.y = -JUMP_SPEED
		if currentMoveDirection == moveDirection.LEFT && get_input_direction() != -1:
			velocity.x = 0
		elif currentMoveDirection == moveDirection.RIGHT && get_input_direction() != 1:
			velocity.x = 0
		jumpCount += 1
	if Input.is_action_just_released(jump) && jumpCount == 1:
		shortHop = true
	#enable collisons with platforms if player is falling down
	if !collidePlatforms && velocity.y >= 0: 
		collidePlatforms = true
		set_collision_mask_bit(1,true)
	#Fastfall
	if Input.is_action_just_pressed(down) && !is_on_floor() && velocity.y >= 0:
		gravity = 4000
	if is_on_floor():
		currentState = CharacterState.GROUND
		#if aerial attack is interrupted by ground cancel hitboxes
		toggle_all_hitboxes("off")
	
func _on_short_hop_timeout():
	if shortHop: 
		velocity.y=0
				
func _on_drop_platform_timeout():
	currentState = CharacterState.AIR
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
	
func snap_edge(edgePosition):
	if !is_on_floor():
		currentState = CharacterState.EDGE
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
		disableInput = false
		
func edge_handler(delta):
	disableInput = true
	jumpCount = 0
	velocity = Vector2.ZERO
	var targetPosition = Vector2.ZERO
	if Input.is_action_just_pressed(down):
		currentState = CharacterState.AIR
		snapEdge=false
	elif Input.is_action_just_pressed(jump):
		currentState = CharacterState.AIR
		velocity.y = -JUMP_SPEED
		jumpCount += 1
		#disables collisons with platforms if player is jumping upwards
		collidePlatforms = false
		set_collision_mask_bit(1,false)
		snapEdge=false
	elif Input.is_action_just_pressed(left):
		if global_position < snapEdgePosition:
			currentState = CharacterState.AIR
			velocity.x = -WALK_MAX_SPEED/4
			snapEdge=false
		else:
			targetPosition = snapEdgePosition - get_character_size()/2
			$Tween.interpolate_property(self, "position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			snapEdge=false
			currentState = CharacterState.GROUND
	elif Input.is_action_just_pressed(right):
		if global_position > snapEdgePosition:
			velocity.x = WALK_MAX_SPEED/4
			snapEdge=false
			currentState = CharacterState.AIR
		else: 
			targetPosition = snapEdgePosition - Vector2(-(get_character_size()/2).x,(get_character_size()/2).y)
			$Tween.interpolate_property(self, "position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			snapEdge=false
			currentState = CharacterState.GROUND
	elif Input.is_action_just_pressed(up):
		if global_position > snapEdgePosition:
			#normal getup right edge
			targetPosition = snapEdgePosition - get_character_size()/2
			$Tween.interpolate_property(self, "position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			snapEdge=false 
			currentState = CharacterState.GROUND
		else: 
			targetPosition = snapEdgePosition - Vector2(-(get_character_size()/2).x,(get_character_size()/2).y)
			$Tween.interpolate_property(self, "position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			snapEdge=false 
			currentState = CharacterState.GROUND
	elif Input.is_action_just_pressed(shield):
		if global_position > snapEdgePosition:
			#normal getup right edge
			targetPosition = snapEdgePosition - Vector2((get_character_size()/2).x*4,(get_character_size()/2).y)
			$Tween.interpolate_property(self, "position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			snapEdge=false 
			currentState = CharacterState.GROUND
		else: 
			targetPosition = snapEdgePosition - Vector2(-(get_character_size()/2).x*4,(get_character_size()/2).y)
			$Tween.interpolate_property(self, "position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			snapEdge=false 
			currentState = CharacterState.GROUND
	disableInput = false

func get_character_size():
	return characterSprite.frames.get_frame("idle",0).get_size()
	
func animation_handler(animationToPlay):
	match animationToPlay:
		CharacterAnimations.IDLE:
			animationPlayer.play("idle")
		CharacterAnimations.WALK:
			animationPlayer.play("walk")
		CharacterAnimations.RUN:
			pass
		CharacterAnimations.JUMP:
			animationPlayer.play("jump")
			animationPlayer.queue("freefall")
#			yield(animationPlayer, "animation_finished")
		CharacterAnimations.DOUBLEJUMP:
			animationPlayer.play("doublejump")
			animationPlayer.queue("freefall")
		CharacterAnimations.NAIR:
			play_attack_animation("nair")
		CharacterAnimations.DASHATTACK: 
			play_attack_animation("dash_attack")
		CharacterAnimations.JAB1:
			play_attack_animation("jab1")

func play_attack_animation(animationToPlay):
	disableInput = true
	animationPlayer.play(animationToPlay)
	yield(animationPlayer, "animation_finished")
	toggle_all_hitboxes("off")
	match CharacterState:
		CharacterState.GROUND:
			animationPlayer.play("freefall")
		CharacterState.AIR:
			animationPlayer.play("idle")
	disableInput = false
	
func process_movement_physics(delta):
	velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
#	handle_pushing_character()
#	velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)
	# Vertical movement code. Apply gravity.
	velocity.y += gravity * delta
	# Move based on the velocity and snap to the ground.
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)

func input_movement_physics(delta):
	# Horizontal movement code. First, get the player's input.
	var walk = WALK_FORCE * (Input.get_action_strength(right) - Input.get_action_strength(left))
	# Slow down the player if they're not trying to move.
	if abs(walk) < WALK_FORCE * 0.2:
		if(currentState == CharacterState.GROUND):
			animationPlayer.play("idle")
		# The velocity, slowed down a bit, and then reassigned.
		velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
	else:
		if(currentState == CharacterState.GROUND):
			animationPlayer.play("walk")
			match currentMoveDirection:
				moveDirection.LEFT:
					if walk > 0: 
						currentMoveDirection = moveDirection.RIGHT
						characterSprite.flip_h = false
						mirror_areas()
						directionChange = true
						if pushingCharacter:
							pushingCharacter.pushingCharacter = null
						pushingCharacter = null
				moveDirection.RIGHT:
					if walk < 0: 
						currentMoveDirection = moveDirection.LEFT
						characterSprite.flip_h = true
						mirror_areas()
						directionChange = true
						if pushingCharacter:
							pushingCharacter.pushingCharacter = null
						pushingCharacter = null
					
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
		#pushes other character if in push area
#			velocity.x = walk + pushingCharacter.velocity.x*pushingCharacter.get_input_direction()
	# Clamp to the maximum horizontal movement speed.
	handle_pushing_character()
	velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)

	# Vertical movement code. Apply gravity.
	velocity.y += gravity * delta
	
func toggle_all_hitboxes(onOff):
	match onOff: 
		"on":
			for hitbox in $AnimatedSprite/HitBoxes.get_children():
				if hitbox is CollisionShape2D:
					hitbox.disabled = false
		"off":
			disableInput = false
			for hitbox in $AnimatedSprite/HitBoxes.get_children():
				if hitbox is CollisionShape2D:
					hitbox.disabled = true

func mirror_areas():
	#mirror hitboxes
	var hitboxes = $AnimatedSprite/HitBoxes
	for hitbox in hitboxes.get_children():
		match currentMoveDirection:
			moveDirection.LEFT:
				hitbox.scale = Vector2(-1, 1)
			moveDirection.RIGHT:
				hitbox.scale = Vector2(1, 1)
	#mirror hurt and collisionareas
	var hurtInteractionArea = $InteractionAreas
	for mirrorArea in hurtInteractionArea.get_children():
		match currentMoveDirection:
			moveDirection.LEFT:
				mirrorArea.scale = Vector2(-1, 1)
				if mirrorArea is RayCast2D:
					mirrorArea.position*=-1
			moveDirection.RIGHT:
				mirrorArea.scale = Vector2(1, 1)
				if mirrorArea is RayCast2D:
					mirrorArea.position*=-1
				
func get_input_direction():
#	print(Input.get_action_strength(right) - Input.get_action_strength(left))
	return Input.get_action_strength(right) - Input.get_action_strength(left)

func handle_pushing_character():
	if pushingCharacter!=null:
		if currentMoveDirection == moveDirection.LEFT && pushingCharacter.currentMoveDirection == moveDirection.RIGHT:
			velocity.x += pushingCharacter.velocity.x * pushingCharacter.get_input_direction()
		elif currentMoveDirection == moveDirection.RIGHT && pushingCharacter.currentMoveDirection == moveDirection.LEFT:
			velocity.x -= pushingCharacter.velocity.x * pushingCharacter.get_input_direction()
		elif currentMoveDirection == moveDirection.RIGHT && pushingCharacter.currentMoveDirection == moveDirection.RIGHT:
			velocity.x += pushingCharacter.velocity.x * pushingCharacter.get_input_direction()
		elif currentMoveDirection == moveDirection.LEFT && pushingCharacter.currentMoveDirection == moveDirection.LEFT:
			velocity.x -= pushingCharacter.velocity.x * pushingCharacter.get_input_direction()

func switch_WorldColliders():
	if currentState == CharacterState.AIR:
		$AirCollider.disabled = false
		$GroundCollider.disabled = true
	elif currentState == CharacterState.GROUND:
		$AirCollider.disabled = true
		$GroundCollider.disabled = false
