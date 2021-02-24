extends KinematicBody2D
#base stats to return to after changes were made
var baseDisableInputInfluence = 1200
var baseWalkMaxSpeed = 100
var baseRunMaxSpeed = 600
var baseStopForce = 1500
var baseJumpSpeed = 850
var baseAirSpeed = 600
var damagePercent = 0.0
#walkforce is only used when no input is detected to slow the character down
var disableInputInfluence = 1200
var walkMaxSpeed = 100
var runMaxSpeed = 600
var airMaxSpeed = 600
var airStopForce = 1000
var groundStopForce = 1500
var jumpSpeed = 800
var shortHopSpeed = 600
var currentMaxSpeed = runMaxSpeed
#jump
var jumpCount = 0
var availabelJumps = 2
var justJumped = false
var shortHopFrames = 3
var shortHop = false
onready var shortHopTimer
#platform
onready var dropDownTimer
var inputTimeout = false
var platformCollision = null
var atPlatformEdge = null
onready var lowestCheckYPoint = get_node("LowestCheckYPoint")
#edge
var snappedEdge = null
var disableInput = false
#attack 
var smashAttack = null
var currentAttack = null
var jabCount = 0
var jabCombo = 3
var dashAttackSpeed = 800
var chargingSmashAttack = false
var smashAttackTimer 
var smashAttackInputTime = 3
var bufferedSmashAttack
var pushingAttack = false
#movement
enum moveDirection {LEFT, RIGHT}
var currentMoveDirection = moveDirection.RIGHT
var turnaroundCoefficient = 1500
var pushingCharacter =  null
var disableInputDI = false
var resetMovementSpeed = false
var walkThreashold = 0.3
var currentPushSpeed = 0
var directionChange = false
var velocity = Vector2()
var onSolidGround = null
var onSolidGroundThreashold = 10
#crouch 
var crouchMovement = false
#bufferInput
var bufferInput = null
#animation needs to finish 
var bufferAnimation = false
#hitstun 
var initLaunchVelocity = Vector2.ZERO
var launchSpeedDecay = 0.025
var inHitStun = false
var shortHitStun = false
onready var hitStunTimer 
var groundHitStun = 3.0
var getupRollDistance = 100
var tumblingThreashold = 500
var characterBouncing = false
var lastVelocity = 0
var bounceThreashold = 800
var bounceReduction = 0.7
#invincibility
onready var invincibilityTimer
#shield
onready var characterShield = get_node("Shield")
var rollDistance = 150
var rolling = false
var shieldStunTimer
var shieldDropTimer
var shieldDropFrames = 15
#grab
onready var grabTimer
var grabbedCharacter = null
var inGrabByCharacter = null
var grabTime = 60
onready var grabPoint = get_node("GrabPoint")
#character stats
var weight = 100
var fastFallGravity = 4000
onready var gravity = 2000
onready var baseGravity = gravity
#hitlag 
var hitLagTimer
var backUpVelocity = 0
var backUpHitStunTime = 0
var backUpDisableInputDI = false

enum CharacterState{GROUND, AIR, EDGE, ATTACKGROUND, ATTACKAIR, HITSTUNGROUND, HITSTUNAIR, SPECIALGROUND, SPECIALAIR, SHIELD, ROLL, GRAB, INGRAB, SPOTDODGE, GETUP, SHIELDBREAK, CROUCH}
#signal for character state change
signal character_state_changed(state)

var currentState = CharacterState.GROUND

onready var collisionAreaShape = $InteractionAreas/CollisionArea/CollisionArea

onready var characterSprite = $AnimatedSprite
onready var animationPlayer = $AnimatedSprite/AnimationPlayer

onready var hurtBox = $InteractionAreas/Hurtbox

onready var frameTimer = preload("res://FrameTimer.tscn")

var attackData = null

#inputs
var up = ""
var down = ""
var left = ""
var right = ""
var jump = ""
var attack = ""
var shield = ""
var grab = ""

var framecounter = 0

func _ready():
	self.set_collision_mask_bit(0,false)
	self.set_collision_mask_bit(2,true)
	#self.set_collision_mask_bit(1,false)
	var file = File.new()
	file.open("res://Characters/Mario/marioAttacks.json", file.READ)
	var attacks = JSON.parse(file.get_as_text())
	file.close()
	attackData = attacks.get_result()
	if !onSolidGround:
		switch_to_state(CharacterState.AIR)
	GlobalVariables.charactersInGame.append(self)
	#create all timers and connect signals 
	hitStunTimer = frameTimer.instance()
	add_child(hitStunTimer)
	hitStunTimer.connect("timeout", self, "_on_hitstun_timeout")
	hitStunTimer.set_name("HitStunTimer")
	shortHopTimer = frameTimer.instance()
	add_child(shortHopTimer)
	shortHopTimer.connect("timeout", self, "_on_short_hop_timeout")
	shortHopTimer.set_name("ShortHopTimer")
	dropDownTimer = frameTimer.instance()
	add_child(dropDownTimer)
	dropDownTimer.connect("timeout", self, "_on_drop_timer_timeout")
	dropDownTimer.set_name("DropDownTimer")
	invincibilityTimer = frameTimer.instance()
	add_child(invincibilityTimer)
	invincibilityTimer.connect("timeout", self, "_on_invincibility_timer_timeout")
	invincibilityTimer.set_name("InvincibilityTimer")
	grabTimer = frameTimer.instance()
	add_child(grabTimer)
	grabTimer.connect("timeout", self, "_on_grab_timer_timeout")
	grabTimer.set_name("GrabTimer")
	smashAttackTimer = frameTimer.instance()
	add_child(smashAttackTimer)
	smashAttackTimer.connect("timeout", self, "_on_smashAttack_timer_timeout")
	smashAttackTimer.set_name("SmashAttackTimer")
	shieldStunTimer = frameTimer.instance()
	add_child(shieldStunTimer)
	shieldStunTimer.connect("timeout", self, "_on_shieldStunTimer_timer_timeout")
	shieldStunTimer.set_name("ShieldStunTimer")
	shieldDropTimer = frameTimer.instance()
	add_child(shieldDropTimer)
	shieldDropTimer.connect("timeout", self, "_on_shieldDropTimer_timer_timeout")
	shieldDropTimer.set_name("shieldDropTimer")
	hitLagTimer = frameTimer.instance()
	add_child(hitLagTimer)
	hitLagTimer.connect("timeout", self, "_on_hitLagTimer_timer_timeout")
	hitLagTimer.set_name("hitLagTimer")
	animationPlayer.set_animation_process_mode(0)

func _physics_process(delta):
	#if character collides with floor/ground velocity instantly becomes zero
	#to apply bounce save last velocity not zero
	if abs(int(velocity.y)) >= onSolidGroundThreashold: 
		lastVelocity = velocity
	if disableInput:
		process_movement_physics(delta)
		check_buffer_input()
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
		CharacterState.GRAB:
			grab_handler(delta)
		CharacterState.INGRAB:
			in_grab_handler(delta)
		CharacterState.CROUCH: 
			crouch_handler(delta)

func check_input(delta):
	if Input.is_action_just_pressed(jump) && currentState == CharacterState.GROUND:
		jump_handler()
	if Input.is_action_just_pressed(right) && currentState == CharacterState.GROUND:
		create_smashAttack_timer()
		bufferedSmashAttack = GlobalVariables.CharacterAnimations.FSMASHR
	elif Input.is_action_just_pressed(left) && currentState == CharacterState.GROUND:
		create_smashAttack_timer()
		bufferedSmashAttack = GlobalVariables.CharacterAnimations.FSMASHL
	elif Input.is_action_just_pressed(up) && currentState == CharacterState.GROUND:
		create_smashAttack_timer()
		bufferedSmashAttack = GlobalVariables.CharacterAnimations.UPSMASH
	elif Input.is_action_just_pressed(down) && currentState == CharacterState.GROUND:
		create_smashAttack_timer()
		bufferedSmashAttack = GlobalVariables.CharacterAnimations.DSMASH
	if smashAttackTimer.timer_running()\
	&& Input.is_action_just_pressed(attack)\
	&& bufferedSmashAttack != null\
	&& Input.is_action_pressed(right)\
	&& currentState == CharacterState.GROUND:
		smashAttack = bufferedSmashAttack
		switch_to_state(CharacterState.ATTACKGROUND)
	elif smashAttackTimer.timer_running()\
	&& Input.is_action_just_pressed(attack)\
	&& bufferedSmashAttack != null\
	&& Input.is_action_pressed(left)\
	&& currentState == CharacterState.GROUND:
		smashAttack = bufferedSmashAttack
		switch_to_state(CharacterState.ATTACKGROUND)
	elif smashAttackTimer.timer_running()\
	&& Input.is_action_just_pressed(attack)\
	&& bufferedSmashAttack != null\
	&& Input.is_action_pressed(up)\
	&& currentState == CharacterState.GROUND:
		smashAttack = bufferedSmashAttack
		switch_to_state(CharacterState.ATTACKGROUND)
	elif smashAttackTimer.timer_running()\
	&& Input.is_action_just_pressed(attack)\
	&& bufferedSmashAttack != null\
	&& Input.is_action_pressed(down)\
	&& currentState == CharacterState.GROUND:
		smashAttack = bufferedSmashAttack
		switch_to_state(CharacterState.ATTACKGROUND)
	elif Input.is_action_just_pressed(attack) && !inHitStun:
		match currentState:
			CharacterState.AIR:
				switch_to_state(CharacterState.ATTACKAIR)
			CharacterState.GROUND:
				switch_to_state(CharacterState.ATTACKGROUND)
	elif Input.is_action_pressed(shield) && (currentState == CharacterState.GROUND\
	|| currentState == CharacterState.CROUCH):
		switch_to_state(CharacterState.SHIELD)
	elif Input.is_action_just_pressed(grab) && currentState == CharacterState.GROUND:
		switch_to_state(CharacterState.GRAB)
		
func attack_handler_ground():
	if disableInput:
		if abs(int(velocity.y)) >= onSolidGroundThreashold:
			switch_from_state_to_airborn()
	if chargingSmashAttack:
		if (Input.is_action_just_released(attack) || !Input.is_action_pressed(attack)) && chargingSmashAttack:
			chargingSmashAttack = false
			smashAttack = null
			apply_smash_attack_steps(2)
	elif !disableInput:
		if smashAttack != null: 
			attack_handler_ground_smash_attacks()
		elif (abs(get_input_direction_x()) == 0 || jabCount > 0) \
		&& get_input_direction_y() == 0:
			jab_handler()
		elif get_input_direction_y() < 0:
			animation_handler(GlobalVariables.CharacterAnimations.UPTILT)
			currentAttack = GlobalVariables.CharacterAnimations.UPTILT
		elif get_input_direction_y() > 0:
			animation_handler(GlobalVariables.CharacterAnimations.DTILT)
			currentAttack = GlobalVariables.CharacterAnimations.DTILT
		elif currentMaxSpeed == baseWalkMaxSpeed: 
			if currentMoveDirection == moveDirection.LEFT:
				animation_handler(GlobalVariables.CharacterAnimations.FTILTL)
				currentAttack = GlobalVariables.CharacterAnimations.FTILTL
			elif currentMoveDirection == moveDirection.RIGHT:
				animation_handler(GlobalVariables.CharacterAnimations.FTILTR)
				currentAttack = GlobalVariables.CharacterAnimations.FTILTR
		else: 
			#dash attack
			match currentMoveDirection:
				moveDirection.LEFT:
					velocity.x = -dashAttackSpeed
				moveDirection.RIGHT:
					velocity.x = dashAttackSpeed
			pushingAttack = true
			animation_handler(GlobalVariables.CharacterAnimations.DASHATTACK)
			currentAttack = GlobalVariables.CharacterAnimations.DASHATTACK
			
func attack_handler_ground_smash_attacks():
	match smashAttack: 
		GlobalVariables.CharacterAnimations.FSMASHR:
			if currentMoveDirection != moveDirection.RIGHT:
				currentMoveDirection = moveDirection.RIGHT
				mirror_areas()
			animation_handler(smashAttack)
			currentAttack = smashAttack
		GlobalVariables.CharacterAnimations.FSMASHL:
			if currentMoveDirection != moveDirection.LEFT:
				currentMoveDirection = moveDirection.LEFT
				mirror_areas()
	animation_handler(smashAttack)
	currentAttack = smashAttack
			
			
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
	if onSolidGround && abs(int(velocity.y)) <= onSolidGroundThreashold\
	&& !dropDownTimer.timer_running() && !hitLagTimer.timer_running():
		switch_to_state(CharacterState.GROUND)
		#toggle_all_hitboxes("off")
	elif !disableInput:
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
	if velocity.y > 0 && get_input_direction_y() >= 0.5: 
		set_collision_mask_bit(1,false)
	elif velocity.y > 0 && get_input_direction_y() < 0.5 && platformCollision == null:
		set_collision_mask_bit(1,true)
			
func ground_handler(delta):
	if disableInput:
		if abs(int(velocity.y)) >= onSolidGroundThreashold:
			switch_from_state_to_airborn()
	elif !disableInput:
		#reset gravity if player is grounded
		if gravity!=baseGravity:
			gravity=baseGravity
		input_movement_physics_ground(delta)
		# Move based on the velocity and snap to the ground.
		velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
		#checks if player walked off platform/stage
		if abs(int(velocity.y)) >= onSolidGroundThreashold:
			switch_from_state_to_airborn()

#creates timer after dropping through platform to enable/diable collision
func create_drop_platform_timer(waittime):
	dropDownTimer.set_frames(waittime)
	dropDownTimer.start_timer()
	
#is called when player is in the air 
func air_handler(delta):
	if onSolidGround && abs(int(velocity.y)) <= onSolidGroundThreashold\
	&& !dropDownTimer.timer_running():
		switch_to_state(CharacterState.GROUND)
#				animationPlayer.play("idle")
		#if aerial attack is interrupted by ground cancel hitboxes
	elif !disableInput:
		input_movement_physics_air(delta)
		# Move based on the velocity and snap to the ground.
		velocity = move_and_slide(velocity)
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
		#Fastfall
		if Input.is_action_just_pressed(down) && !onSolidGround && abs(int(velocity.y)) >= onSolidGroundThreashold:
			gravity = fastFallGravity
		if abs(int(velocity.y)) <= onSolidGroundThreashold && onSolidGround:
			switch_to_state(CharacterState.GROUND)
			#if aerial attack is interrupted by ground cancel hitboxes
		if velocity.y > 0 && get_input_direction_y() >= 0.5: 
			set_collision_mask_bit(1,false)
		elif velocity.y > 0 && get_input_direction_y() < 0.5 && platformCollision == null:
			set_collision_mask_bit(1,true)

func jump_handler():
	#todo: if currentstate == edge : create edge hop
	shortHop = false
	jumpCount = 1
	disableInput = true
	create_shorthop_timer()
		
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
	
func create_shorthop_timer():
	shortHopTimer.set_frames(shortHopFrames)
	shortHopTimer.start_timer()
		
func _on_short_hop_timeout():
	if !bufferInput:
		if shortHop:
			velocity.y = -shortHopSpeed
		else: 
			velocity.y = -jumpSpeed
		disableInput = false
		switch_to_state(CharacterState.AIR)
		animation_handler(GlobalVariables.CharacterAnimations.JUMP)
				
func _on_drop_timer_timeout():
	if inputTimeout:
		inputTimeout = false
	
	
func calc_hitstun_velocity(delta):
	if velocity.x < 0: 
		if(velocity.x - initLaunchVelocity.x *launchSpeedDecay) <= 0:
			velocity.x -= (initLaunchVelocity.x *launchSpeedDecay)
		else: 
			velocity.x = 0
	elif velocity.x > 0: 
		if(velocity.x - initLaunchVelocity.x *launchSpeedDecay) >= 0:
			velocity.x -= (initLaunchVelocity.x *launchSpeedDecay)
		else: 
			velocity.x = 0
	else: 
		velocity.x = 0
	velocity.y += gravity * delta
	
func hitstun_handler(delta):
	if disableInput && inHitStun:
		if shortHitStun: 
			return
#		if abs(int(velocity.y)) >= onSolidGroundThreashold && currentState == CharacterState.HITSTUNGROUND:
#			switch_from_state_to_airborn_hitstun()
		if currentState == CharacterState.HITSTUNAIR:
			#BOUNCING CHARACTER
			if onSolidGround && lastVelocity.y > bounceThreashold && inHitStun:
				velocity = Vector2(lastVelocity.x,lastVelocity.y*(-1))*bounceReduction
				initLaunchVelocity = velocity
			elif onSolidGround && abs(int(velocity.y)) <= onSolidGroundThreashold && abs(int(velocity.x)) == 0:
#				#plays rest of hitstun animation if hitting ground during hitstun
				animationPlayer.play()
				bufferAnimation = false
				create_hitstun_timer(groundHitStun)
				switch_to_state(CharacterState.HITSTUNGROUND)
#		elif currentState == CharacterState.HITSTUNGROUND:
#			if abs(int(velocity.y)) >= onSolidGroundThreashold:
#				switch_from_state_to_airborn()
	elif !disableInput:
		if onSolidGround && lastVelocity.y > bounceThreashold && inHitStun:
			velocity = Vector2(lastVelocity.x,lastVelocity.y*(-1))*bounceReduction
		if onSolidGround && abs(int(velocity.y)) <= onSolidGroundThreashold && currentState == CharacterState.HITSTUNAIR:
			switch_to_state(CharacterState.HITSTUNGROUND)
			#plays rest of hitstun animation if hitting ground during hitstun
			animationPlayer.play()
			bufferAnimation = false
			create_hitstun_timer(groundHitStun)
		elif currentState == CharacterState.HITSTUNGROUND: 
			if abs(int(velocity.y)) >= onSolidGroundThreashold:
				switch_from_state_to_airborn()
			#if not in hitstun check for jump, attack or special 
			#todo: check for special
			if Input.is_action_just_pressed(attack):
				switch_to_state(CharacterState.GETUP)
				animation_handler(GlobalVariables.CharacterAnimations.ATTACKGETUP)
			elif Input.is_action_just_pressed(up):
				switch_to_state(CharacterState.GETUP)
				animation_handler(GlobalVariables.CharacterAnimations.NORMALGETUP)
			elif Input.is_action_just_pressed(left):
				switch_to_state(CharacterState.GETUP)
				if currentMoveDirection != moveDirection.LEFT:
					currentMoveDirection = moveDirection.LEFT
					mirror_areas()
				animation_handler(GlobalVariables.CharacterAnimations.ROLLGETUP)
			elif Input.is_action_just_pressed(right):
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
	hitStunTimer.set_frames(stunTime)
	hitStunTimer.start_timer()
	
func _on_hitstun_timeout():
	inHitStun = false
	disableInput = false
	if shortHitStun: 
		if abs(int(velocity.y)) <= onSolidGroundThreashold:
			animationPlayer.play("idle")
			switch_to_state(CharacterState.GROUND)
		else:
			switch_from_state_to_airborn()
	else:
		pass
#		switch_to_state(CharacterState.AIR)
#	else:
#		switch_to_state(CharacterState.GROUND)
#	enable_player_input()
	
func shield_handler(delta):
	process_movement_physics(delta)
	if !shieldStunTimer.timer_running() && !shieldDropTimer.timer_running():
		if Input.is_action_just_released(shield):
			characterShield.disable_shield()
			switch_to_state(CharacterState.GROUND)
			create_shield_drop_timer()
		elif Input.is_action_just_pressed(jump):
			characterShield.disable_shield()
			jump_handler()
		elif Input.is_action_just_pressed(attack):
			#todo implement grab mechanic
			characterShield.disable_shield()
			switch_to_state(CharacterState.GRAB)
		elif Input.is_action_just_pressed(right):
			#todo implement roll mechanic
			characterShield.disable_shield()
			if currentMoveDirection != moveDirection.RIGHT:
				currentMoveDirection = moveDirection.RIGHT
				mirror_areas()
			switch_to_state(CharacterState.ROLL)
		elif Input.is_action_just_pressed(left):
			#todo implement roll mechanic
			characterShield.disable_shield()
			if currentMoveDirection != moveDirection.LEFT:
				currentMoveDirection = moveDirection.LEFT
				mirror_areas()
			switch_to_state(CharacterState.ROLL)
		elif Input.is_action_just_pressed(down):
			#todo implement spotdodge mechanic
			characterShield.disable_shield()
			switch_to_state(CharacterState.SPOTDODGE)

func create_shieldStun_timer(shieldStunFrames):
	#todo replace frames with shieldstunframes
	shieldStunTimer.set_frames(60)
	shieldStunTimer.start_timer()
	
func _on_shieldStunTimer_timer_timeout():
	characterShield.disable_shield()
	switch_to_state(CharacterState.GROUND)
	create_shield_drop_timer()
			
func create_shield_drop_timer():
	shieldDropTimer.set_frames(shieldDropFrames)
	shieldDropTimer.start_timer()
	disableInput = true
	animation_handler(GlobalVariables.CharacterAnimations.SHIELDDROP)

func _on_shieldDropTimer_timer_timeout():
	if get_input_direction_y() >= 0.5:
		switch_to_state(CharacterState.CROUCH)
	disableInput = false

func grab_handler(delta):
	process_movement_physics(delta)
	if abs(int(velocity.y)) >= onSolidGroundThreashold:
		grabTimer.stop_timer()
		switch_to_state(CharacterState.GROUND)
		if grabbedCharacter != null:
			grabbedCharacter.on_grab_release()
	if grabbedCharacter != null && !disableInput:
#		if !grabTimer.timer_running():
#				velocity.x = 0
#				create_grab_timer()
		if Input.is_action_just_pressed(attack):
			currentAttack = GlobalVariables.CharacterAnimations.GRABJAB
			animation_handler(GlobalVariables.CharacterAnimations.GRABJAB)
		elif Input.is_action_just_pressed(left):
			if currentMoveDirection == moveDirection.LEFT:
				currentAttack = GlobalVariables.CharacterAnimations.FTHROW
				animation_handler(GlobalVariables.CharacterAnimations.FTHROW)
				grabTimer.stop_timer()
			else:
				currentAttack = GlobalVariables.CharacterAnimations.BTHROW
				animation_handler(GlobalVariables.CharacterAnimations.BTHROW)
			grabTimer.stop_timer()
		elif Input.is_action_just_pressed(right):
			if currentMoveDirection == moveDirection.RIGHT:
				currentAttack = GlobalVariables.CharacterAnimations.FTHROW
				animation_handler(GlobalVariables.CharacterAnimations.FTHROW)
			else:
				currentAttack = GlobalVariables.CharacterAnimations.BTHROW
				animation_handler(GlobalVariables.CharacterAnimations.BTHROW)
			grabTimer.stop_timer()
		elif Input.is_action_just_pressed(up):
			currentAttack = GlobalVariables.CharacterAnimations.UTHROW
			animation_handler(GlobalVariables.CharacterAnimations.UTHROW)
			grabTimer.stop_timer()
		elif Input.is_action_just_pressed(down):
			currentAttack = GlobalVariables.CharacterAnimations.DTHROW
			animation_handler(GlobalVariables.CharacterAnimations.DTHROW)
			grabTimer.stop_timer()
	
func on_grab_release():
	#todo grab release motion
	gravity_on_off("on")
	inGrabByCharacter = null
	switch_to_state(CharacterState.AIR)
	match currentMoveDirection: 
		0: 
			velocity = Vector2(400,-400)
		1: 
			velocity = Vector2(-400,-400)
			
func in_grab_handler(delta):
	if abs(int(inGrabByCharacter.velocity.x)) != 0: 
		self.global_position = inGrabByCharacter.grabPoint.global_position
	process_movement_physics(delta)
	
func create_grab_timer():
	grabTimer.set_frames(grabTime)
	grabTimer.start_timer()
	
func _on_grab_timer_timeout():
	print("Grab timer timeout")
	if grabbedCharacter:
		grabbedCharacter.on_grab_release()
		switch_to_state(CharacterState.GROUND)
	
func create_smashAttack_timer():
	smashAttackTimer.set_frames(smashAttackInputTime)
	smashAttackTimer.start_timer()
	
func _on_smashAttack_timer_timeout():
	if currentState == CharacterState.GROUND && get_input_direction_y() == 1.0:
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("Platform"):
				jumpCount = 1
				set_collision_mask_bit(1,false)
				create_drop_platform_timer(30)
				switch_from_state_to_airborn()
			elif collision.get_collider().is_in_group("Ground"):
				switch_to_state(CharacterState.CROUCH)
	elif currentState == CharacterState.GROUND && get_input_direction_y() >=0.2:
		switch_to_state(CharacterState.CROUCH)
	
func crouch_handler(delta):
	if get_input_direction_y() <= 0.3:
		switch_to_state(CharacterState.GROUND)
	elif Input.is_action_just_pressed(attack):
		switch_to_state(CharacterState.ATTACKGROUND)
		animation_handler(GlobalVariables.CharacterAnimations.DTILT)
		currentAttack = GlobalVariables.CharacterAnimations.DTILT
	elif Input.is_action_just_pressed(jump):
		jump_handler()
#	elif Input.is_action_just_pressed(shield):
		
	
func snap_edge(collidingEdge):
	if get_input_direction_y() > 0:
		return
	var character_towards_edge = false
	var character_over_edge = false
	if collidingEdge.edgeSnapDirection == "left" \
	&& self.global_position.x <= collidingEdge.global_position.x:
		character_over_edge = true 
		if velocity.x >= 0 || currentMoveDirection == moveDirection.RIGHT:
			character_towards_edge = true
			
	elif collidingEdge.edgeSnapDirection == "right" \
	&& self.global_position.x >= collidingEdge.global_position.x:
		character_over_edge = true
		if velocity.x <= 0 || currentMoveDirection == moveDirection.LEFT:
			character_towards_edge = true
			
	if character_over_edge && currentState == CharacterState.AIR && (character_towards_edge && velocity.y >= 0):
		switch_to_state(CharacterState.EDGE)
		disableInput = true
		gravity = baseGravity
		velocity = Vector2.ZERO
		jumpCount = 1
		if currentMoveDirection == moveDirection.RIGHT && collidingEdge.edgeSnapDirection == "right": 
			currentMoveDirection = moveDirection.LEFT
			mirror_areas()
		elif currentMoveDirection == moveDirection.LEFT && collidingEdge.edgeSnapDirection == "left": 
			currentMoveDirection = moveDirection.RIGHT
			mirror_areas()
		var targetPosition = collidingEdge.global_position + Vector2((characterSprite.frames.get_frame("idle",0).get_size()/2).x,(characterSprite.frames.get_frame("idle",0).get_size()/4).y)
		if self.global_position < collidingEdge.global_position:
			targetPosition = collidingEdge.global_position + Vector2(-(characterSprite.frames.get_frame("idle",0).get_size()/2).x,(characterSprite.frames.get_frame("idle",0).get_size()/4).y)
		animation_handler(GlobalVariables.CharacterAnimations.EDGESNAP)
		$Tween.interpolate_property(self, "global_position", global_position, targetPosition , animationPlayer.get_current_animation_length(), Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		yield($Tween, "tween_all_completed")
		snappedEdge = collidingEdge
		
func edge_handler(delta):
	if snappedEdge != null: 
		var targetPosition = Vector2.ZERO
		if Input.is_action_just_pressed(down):
			snappedEdge._on_EdgeSnap_area_exited(collisionAreaShape.get_parent())
			snappedEdge = null
			switch_to_state(CharacterState.AIR)
		elif Input.is_action_just_pressed(jump):
			snappedEdge._on_EdgeSnap_area_exited(collisionAreaShape.get_parent())
			snappedEdge = null
			jump_handler()
		elif Input.is_action_just_pressed(left):
			if global_position.x < snappedEdge.global_position.x:
				snappedEdge._on_EdgeSnap_area_exited(collisionAreaShape.get_parent())
				snappedEdge = null
				switch_to_state(CharacterState.AIR)
				velocity.x = -walkMaxSpeed/2
			else:
				targetPosition = snappedEdge.global_position - Vector2(get_character_size().x*2, get_character_size().y)
				snappedEdge = null
				$Tween.interpolate_property(self, "global_position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
				$Tween.start()
				yield($Tween, "tween_all_completed")
				switch_to_state(CharacterState.GROUND)
		elif Input.is_action_just_pressed(right):
			if global_position.x > snappedEdge.global_position.x:
				snappedEdge._on_EdgeSnap_area_exited(collisionAreaShape.get_parent())
				snappedEdge = null
				switch_to_state(CharacterState.AIR)
				velocity.x = walkMaxSpeed/2
			else: 
				targetPosition = snappedEdge.global_position - Vector2(-get_character_size().x*2, get_character_size().y)
				snappedEdge = null
				$Tween.interpolate_property(self, "global_position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
				$Tween.start()
				yield($Tween, "tween_all_completed")
				switch_to_state(CharacterState.GROUND)
		elif Input.is_action_just_pressed(up):
			if global_position > snappedEdge.global_position:
				#normal getup right edge
				targetPosition = snappedEdge.global_position - get_character_size()
				snappedEdge = null
				$Tween.interpolate_property(self, "global_position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
				$Tween.start()
				yield($Tween, "tween_all_completed")
				switch_to_state(CharacterState.GROUND)
			else: 
				targetPosition = snappedEdge.global_position - Vector2(-(get_character_size()).x,(get_character_size()).y)
				snappedEdge = null
				$Tween.interpolate_property(self, "global_position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
				$Tween.start()
				yield($Tween, "tween_all_completed")
				switch_to_state(CharacterState.GROUND)
		elif Input.is_action_just_pressed(shield):
			if global_position > snappedEdge.global_position:
				#normal getup right edge
				targetPosition = snappedEdge.global_position - Vector2((get_character_size()).x*4,(get_character_size()).y)
				snappedEdge = null
				$Tween.interpolate_property(self, "global_position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
				$Tween.start()
				yield($Tween, "tween_all_completed")
				switch_to_state(CharacterState.GROUND)
			else: 
				targetPosition = snappedEdge.global_position - Vector2(-(get_character_size()).x*4,(get_character_size()).y)
				snappedEdge = null
				$Tween.interpolate_property(self, "global_position", global_position, targetPosition , 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
				$Tween.start()
				yield($Tween, "tween_all_completed")
				switch_to_state(CharacterState.GROUND)
		enable_player_input()

func get_character_size():
	return characterSprite.frames.get_frame("idle",0).get_size()
	
func animation_handler(animationToPlay):
	#print("Switch to animation " +str(animationToPlay))
	animationPlayer.playback_speed = 1
	match animationToPlay:
		GlobalVariables.CharacterAnimations.IDLE:
			animationPlayer.queue("idle")
		GlobalVariables.CharacterAnimations.WALK:
			animationPlayer.play("walk")
		GlobalVariables.CharacterAnimations.RUN:
			pass
		GlobalVariables.CharacterAnimations.JUMP:
			animationPlayer.play("jump")
			animationPlayer.queue("freefall")
		GlobalVariables.CharacterAnimations.DOUBLEJUMP:
			animationPlayer.play("doublejump")
			animationPlayer.queue("freefall")
		GlobalVariables.CharacterAnimations.FREEFALL: 
			animationPlayer.play("freefall")
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
		GlobalVariables.CharacterAnimations.FTILTR:
			play_attack_animation("ftilt")
		GlobalVariables.CharacterAnimations.FTILTL:
			play_attack_animation("ftilt")
		GlobalVariables.CharacterAnimations.UPTILT:
			play_attack_animation("uptilt")
		GlobalVariables.CharacterAnimations.DTILT:
			play_attack_animation("dtilt")
		GlobalVariables.CharacterAnimations.UPAIR:
			play_attack_animation("upair")
			disableInputDI = true
		GlobalVariables.CharacterAnimations.FAIR:
			play_attack_animation("fair")
			disableInputDI = true
		GlobalVariables.CharacterAnimations.BAIR:
			play_attack_animation("bair")
			disableInputDI = true
		GlobalVariables.CharacterAnimations.DAIR:
			play_attack_animation("dair")
			disableInputDI = true
		GlobalVariables.CharacterAnimations.UPSMASH:
			play_attack_animation("upsmash")
		GlobalVariables.CharacterAnimations.DSMASH:
			play_attack_animation("dsmash")
		GlobalVariables.CharacterAnimations.FSMASHR:
			play_attack_animation("fsmash")
		GlobalVariables.CharacterAnimations.FSMASHL:
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
			roll_calculator(getupRollDistance)
		GlobalVariables.CharacterAnimations.NORMALGETUP:
			animationPlayer.play("normal_getup")
		GlobalVariables.CharacterAnimations.SHIELD:
			animationPlayer.play("shield")
		GlobalVariables.CharacterAnimations.ROLL:
			animationPlayer.play("roll")
			roll_calculator(rollDistance)
		GlobalVariables.CharacterAnimations.SPOTDODGE:
			animationPlayer.play("spotdodge")
		GlobalVariables.CharacterAnimations.GRAB:
			animationPlayer.play("grab")
		GlobalVariables.CharacterAnimations.INGRAB:
			animationPlayer.play("ingrab")
		GlobalVariables.CharacterAnimations.GRABJAB:
			animationPlayer.play("grabjab")
		GlobalVariables.CharacterAnimations.FTHROW:
			animationPlayer.play("fthrow")
		GlobalVariables.CharacterAnimations.BTHROW:
			animationPlayer.play("bthrow")
		GlobalVariables.CharacterAnimations.UTHROW:
			animationPlayer.play("uthrow")
		GlobalVariables.CharacterAnimations.DTHROW:
			animationPlayer.play("dthrow")
		GlobalVariables.CharacterAnimations.EDGESNAP: 
			animationPlayer.play("edgeSnap")
		GlobalVariables.CharacterAnimations.CROUCH:
			animationPlayer.play("crouch")
		GlobalVariables.CharacterAnimations.SHIELDDROP:
			animationPlayer.play("shielddrop")
			
func roll_calculator(distance): 
	if currentMoveDirection == moveDirection.LEFT:
		distance = abs(distance) * -1
		if atPlatformEdge == moveDirection.LEFT:
			velocity.x = 0
		else:
			velocity.x = distance
	else:
		distance = abs(distance)
		if atPlatformEdge == moveDirection.RIGHT:
			velocity.x = 0
		else:
			velocity.x = distance
	
func play_attack_animation(animationToPlay, playBackSpeed = 1):
	disableInput = true
	animationPlayer.play(animationToPlay, -1, playBackSpeed, false)
	yield(animationPlayer, "animation_finished")
	if bufferInput == null:
		match currentState:
			CharacterState.ATTACKGROUND:
				if get_input_direction_y() >= 0.5: 
					switch_to_state(CharacterState.CROUCH)
				else:
					switch_to_state(CharacterState.GROUND)
				smashAttack = null
			CharacterState.ATTACKAIR:
				switch_to_state(CharacterState.AIR)
		toggle_all_hitboxes("off")
	else:
		enable_player_input()

func apply_attack_movement_stats(step = 0):
	pass
	
func process_movement_physics(delta):
	if currentState == CharacterState.HITSTUNAIR:
#		print(self.name + "  " + str(onSolidGround) + "  " +str(velocity))
		calc_hitstun_velocity(delta)
#		velocity.x = move_toward(velocity.x, 0, groundStopForce * delta)
	if disableInputDI:
		var walk = disableInputInfluence * get_input_direction_x()
		velocity.x += walk * delta
		velocity.x = clamp(velocity.x, -walkMaxSpeed, walkMaxSpeed)
		velocity.y += gravity * delta
	else:
		if currentState == CharacterState.GROUND\
		|| currentState == CharacterState.ATTACKGROUND\
		|| currentState == CharacterState.SHIELD\
		|| currentState == CharacterState.GRAB\
		|| currentState == CharacterState.INGRAB\
		|| currentState == CharacterState.HITSTUNGROUND:
			velocity.x = move_toward(velocity.x, 0, groundStopForce * delta)
			velocity.y += gravity * delta
		elif currentState == CharacterState.AIR\
		|| currentState == CharacterState.ATTACKAIR:
#		|| currentState == CharacterState.HITSTUNAIR:
			velocity.x = move_toward(velocity.x, 0, airStopForce * delta)
			velocity.y += gravity * delta
	# Move based on the velocity and snap to the ground.
#	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN, Vector2.UP)
	velocity = move_and_slide(velocity)

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
			moveDirection.RIGHT:
				if xInput < 0: 
					currentMoveDirection = moveDirection.LEFT
#						characterSprite.flip_h = true
					mirror_areas()
					directionChange = true
					change_max_speed(xInput)
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
	if currentState == CharacterState.HITSTUNGROUND || currentState == CharacterState.HITSTUNAIR:
		calc_hitstun_velocity(delta)
	# Vertical movement code. Apply gravity.
	else:
		velocity.y += gravity * delta
	
func toggle_all_hitboxes(onOff):
	match onOff: 
		"on":
			for areaHitbox in $AnimatedSprite/HitBoxes.get_children():
				for hitbox in areaHitbox.get_children():
					if hitbox is CollisionShape2D:
						hitbox.set_deferred('disabled',false)
		"off":
			if !inHitStun && bufferInput == null:
				enable_player_input()
			for areaHitbox in $AnimatedSprite/HitBoxes.get_children():
				for hitbox in areaHitbox.get_children():
					if hitbox is CollisionShape2D:
						hitbox.set_deferred('disabled',true)
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
	toggle_all_hitboxes("off")
	pushingAttack = false
	currentAttack = null
	#todo: reset all hitboxes and collision shapes
	match state: 
		CharacterState.GROUND:
			currentState = CharacterState.GROUND
			animation_handler(GlobalVariables.CharacterAnimations.IDLE)
			emit_signal("character_state_changed", self, currentState)
		CharacterState.AIR:
			currentState = CharacterState.AIR
			emit_signal("character_state_changed", self, currentState)
			animation_handler(GlobalVariables.CharacterAnimations.FREEFALL)
		CharacterState.HITSTUNAIR:
			currentState = CharacterState.HITSTUNAIR
			emit_signal("character_state_changed", self, currentState)
		CharacterState.HITSTUNGROUND:
			currentState = CharacterState.HITSTUNGROUND
			emit_signal("character_state_changed", self, currentState)
		CharacterState.ATTACKAIR:
			currentState = CharacterState.ATTACKAIR
			emit_signal("character_state_changed", self, currentState)
		CharacterState.ATTACKGROUND:
			currentState = CharacterState.ATTACKGROUND
			emit_signal("character_state_changed", self, currentState)
		CharacterState.SPECIALGROUND:
			currentState = CharacterState.SPECIALGROUND
		CharacterState.SPECIALAIR:
			currentState = CharacterState.SPECIALAIR
		CharacterState.EDGE:
			currentState = CharacterState.EDGE
		CharacterState.GETUP:
			currentState = CharacterState.GETUP
			emit_signal("character_state_changed", self, currentState)
		CharacterState.SHIELD:
			currentState = CharacterState.SHIELD
			characterShield.enable_shield()
			emit_signal("character_state_changed", self, currentState)
			animation_handler(GlobalVariables.CharacterAnimations.SHIELD)
		CharacterState.ROLL:
			currentState = CharacterState.ROLL
			emit_signal("character_state_changed", self, currentState)
			animation_handler(GlobalVariables.CharacterAnimations.ROLL)
		CharacterState.SPOTDODGE:
			currentState = CharacterState.SPOTDODGE
			emit_signal("character_state_changed", self, currentState)
			animation_handler(GlobalVariables.CharacterAnimations.SPOTDODGE)
		CharacterState.GRAB:
			currentState = CharacterState.GRAB
			disableInput = true
			emit_signal("character_state_changed", self, currentState)
			animation_handler(GlobalVariables.CharacterAnimations.GRAB)
		CharacterState.INGRAB:
			currentState = CharacterState.INGRAB
			emit_signal("character_state_changed", self, currentState)
			animation_handler(GlobalVariables.CharacterAnimations.INGRAB)
		CharacterState.CROUCH: 
			currentState = CharacterState.CROUCH
			emit_signal("character_state_changed", self, currentState)
			animation_handler(GlobalVariables.CharacterAnimations.CROUCH)
	
func is_attacked_handler(damage, hitStun, launchVectorX, launchVectorY, launchVelocity, knockBackScaling):
	if gravity!=baseGravity:
		gravity=baseGravity
	chargingSmashAttack = false
	smashAttack = null
	bufferInput = null
	damagePercent += damage
	var calulatedVelocity = calculate_attack_knockback(damage, launchVelocity, knockBackScaling)
	#print(damagePercent)
	velocity = Vector2.ZERO
	initLaunchVelocity = Vector2(launchVectorX,launchVectorY) * calulatedVelocity
	backUpVelocity = initLaunchVelocity
	hitStunTimer.stop_timer()
	#collisionAreaShape.set_deferred('disabled',true)
	if launchVelocity > tumblingThreashold || currentState == CharacterState.INGRAB:
	#todo: calculate if in tumble animation
		shortHitStun = false
		switch_to_state(CharacterState.HITSTUNAIR)
		animation_handler(GlobalVariables.CharacterAnimations.HURT)
	else: 
		shortHitStun = true
		switch_to_state(CharacterState.HITSTUNAIR)
		animation_handler(GlobalVariables.CharacterAnimations.HURTSHORT)
	backUpHitStunTime = hitStun
	create_hitlag_timer()
	
func is_attacked_in_shield_handler(damage, shieldStunMultiplier):
	var shieldStunFrames = int(floor(damage * 0.8 * shieldStunMultiplier + 2))
	create_shieldStun_timer(shieldStunFrames)
	#calculate shielddamge 
	#calculate shield hit pushback
	
func calculate_attack_knockback(attackDamage, attackBaseKnockBack, knockBackScaling):
#	print("CALCULATING")
	var calculatedKnockBack = (((((damagePercent/2+(damagePercent*attackDamage)/4)*200/(weight*100/2+100)*1.4)+18)*knockBackScaling)+(attackBaseKnockBack))*1
#	print("calculatedKnockBack " +str(calculatedKnockBack))
	return calculatedKnockBack

func create_hitlag_timer():
	animationPlayer.stop(false)
	gravity_on_off("off")
	if currentState == CharacterState.HITSTUNAIR || currentState == CharacterState.HITSTUNGROUND:
		backUpVelocity = initLaunchVelocity
	else: 
		backUpVelocity = velocity
	velocity = Vector2(0,0)
	disableInput = true
	backUpDisableInputDI = disableInputDI
	disableInputDI = false
	hitLagTimer.set_frames(60)
	hitLagTimer.start_timer()

func _on_hitLagTimer_timer_timeout():
	gravity_on_off("on")
	velocity = backUpVelocity
	animationPlayer.play()
	disableInputDI = backUpDisableInputDI
	if currentState == CharacterState.HITSTUNAIR: 
		create_hitstun_timer(backUpHitStunTime)

func is_grabbed_handler(byCharacter):
	characterShield.disable_shield()
	inGrabByCharacter = byCharacter
	if gravity!=baseGravity:
		gravity=baseGravity
	chargingSmashAttack = false
	smashAttack = null
	bufferInput = null
	self.global_position = byCharacter.grabPoint.global_position
	velocity = Vector2.ZERO
	gravity_on_off("off")
	#collisionAreaShape.set_deferred("disabled",true)
	switch_to_state(CharacterState.INGRAB)
	
func is_thrown_grabjabbed_handler(actionType):
	gravity_on_off("on")
	apply_throw(actionType)
	
func apply_throw(actionType):
	var currentAttackData = (inGrabByCharacter.attackData[GlobalVariables.CharacterAnimations.keys()[actionType]])
	var attackDamage = currentAttackData["damage"]
	if actionType == GlobalVariables.CharacterAnimations.GRABJAB:
		return
	var hitStun = currentAttackData["hitStun"]
	var launchAngle = deg2rad(currentAttackData["launchAngle"])
	var launchVector = Vector2(cos(launchAngle), sin(launchAngle))
	var launchVectorX = launchVector.x
	var knockBackScaling = currentAttackData["knockBackGrowth"]/100
	#inverse x launch diretion depending on character position
	if global_position.x < inGrabByCharacter.global_position.x:
		launchVectorX *= -1
#	else:
#		launchVectorX = abs(launchVectorX)
	var launchVectorY = launchVector.y
	var launchVelocity = currentAttackData["launchVelocity"]
	self.global_position = inGrabByCharacter.global_position
	is_attacked_handler(attackDamage, hitStun, launchVectorX, launchVectorY, launchVelocity, knockBackScaling)
	inGrabByCharacter = null
	
func enable_player_input():
	if buffered_input():
		return
	elif bufferAnimation:
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
	if shortHopTimer.timer_running():
		if Input.is_action_just_released(jump):
			shortHop = true
#	print(animationPlayer.get_current_animation_length()-animationPlayer.get_current_animation_position())
#	print(int((animationPlayer.get_current_animation_length()-animationPlayer.get_current_animation_position())*60))
# if 10 or less frames of current animation remain allow buffer input
	#todo: add other inputs for buffer
	var animationFramesLeft = int((animationPlayer.get_current_animation_length()-animationPlayer.get_current_animation_position())*60)
	if  (animationFramesLeft <= 10 || currentState == CharacterState.SHIELD)\
	&& bufferInput == null: 
		if currentState == CharacterState.ATTACKGROUND\
		|| currentState == CharacterState.ROLL\
		|| currentState == CharacterState.SHIELD:
			if Input.is_action_just_pressed(attack) && get_input_direction_x() == 0 && get_input_direction_y() == 0:
				bufferInput = GlobalVariables.CharacterAnimations.JAB1
			elif Input.is_action_just_pressed(jump):
				bufferInput = GlobalVariables.CharacterAnimations.JUMP
				shortHop = false
				jumpCount = 1
				create_shorthop_timer()
			elif Input.is_action_just_pressed(grab):
				bufferInput = GlobalVariables.CharacterAnimations.GRAB
			elif Input.is_action_just_pressed(right):
				create_smashAttack_timer()
				bufferedSmashAttack = GlobalVariables.CharacterAnimations.FSMASHR
			elif Input.is_action_just_pressed(left):
				create_smashAttack_timer()
				bufferedSmashAttack = GlobalVariables.CharacterAnimations.FSMASHL
			elif Input.is_action_just_pressed(up):
				create_smashAttack_timer()
				bufferedSmashAttack = GlobalVariables.CharacterAnimations.UPSMASH
			elif Input.is_action_just_pressed(down):
				create_smashAttack_timer()
				bufferedSmashAttack = GlobalVariables.CharacterAnimations.DSMASH
			if smashAttackTimer.timer_running()\
			&& Input.is_action_just_pressed(attack)\
			&& bufferedSmashAttack != null\
			&& Input.is_action_pressed(right):
				smashAttack = bufferedSmashAttack
				bufferInput = bufferedSmashAttack
			elif smashAttackTimer.timer_running()\
			&& Input.is_action_just_pressed(attack)\
			&& bufferedSmashAttack != null\
			&& Input.is_action_pressed(left):
				smashAttack = bufferedSmashAttack
				bufferInput = bufferedSmashAttack
			elif smashAttackTimer.timer_running()\
			&& Input.is_action_just_pressed(attack)\
			&& bufferedSmashAttack != null\
			&& Input.is_action_pressed(up):
				smashAttack = bufferedSmashAttack
				bufferInput = bufferedSmashAttack
			elif smashAttackTimer.timer_running()\
			&& Input.is_action_just_pressed(attack)\
			&& bufferedSmashAttack != null\
			&& Input.is_action_pressed(down):
				smashAttack = bufferedSmashAttack
				bufferInput = bufferedSmashAttack
			elif !smashAttackTimer.timer_running()\
			&& Input.is_action_just_pressed(attack)\
			&& Input.is_action_pressed(right):
				bufferInput = GlobalVariables.CharacterAnimations.FTILTR
			elif !smashAttackTimer.timer_running()\
			&& Input.is_action_just_pressed(attack)\
			&& Input.is_action_pressed(left):
				bufferInput = GlobalVariables.CharacterAnimations.FTILTL
			elif !smashAttackTimer.timer_running()\
			&& Input.is_action_just_pressed(attack)\
			&& Input.is_action_pressed(up):
				bufferInput = GlobalVariables.CharacterAnimations.UPTILT
			elif !smashAttackTimer.timer_running()\
			&& Input.is_action_just_pressed(attack)\
			&& Input.is_action_pressed(down):
				bufferInput = GlobalVariables.CharacterAnimations.DTILT
				
		elif currentState == CharacterState.ATTACKAIR: 
			if Input.is_action_just_pressed(attack) && get_input_direction_x() == 0 && get_input_direction_y() == 0:
				bufferInput = GlobalVariables.CharacterAnimations.NAIR
			elif Input.is_action_just_pressed(attack)\
			&& Input.is_action_pressed(right):
				if currentMoveDirection == moveDirection.RIGHT:
					bufferInput = GlobalVariables.CharacterAnimations.FAIR
				elif currentMoveDirection == moveDirection.LEFT:
					bufferInput = GlobalVariables.CharacterAnimations.BAIR
			elif Input.is_action_just_pressed(attack)\
			&& Input.is_action_pressed(left):
				if currentMoveDirection == moveDirection.LEFT:
					bufferInput = GlobalVariables.CharacterAnimations.FAIR
				elif currentMoveDirection == moveDirection.RIGHT:
					bufferInput = GlobalVariables.CharacterAnimations.BAIR
			elif Input.is_action_just_pressed(attack)\
			&& Input.is_action_pressed(up):
				bufferInput = GlobalVariables.CharacterAnimations.UPAIR
			elif Input.is_action_just_pressed(attack)\
			&& Input.is_action_pressed(down):
				bufferInput = GlobalVariables.CharacterAnimations.DAIR

func buffered_input():
	if bufferInput == null:
		jabCount = 0
		return false
	else: 
		match bufferInput: 
			GlobalVariables.CharacterAnimations.JAB1:
				jab_handler()
			GlobalVariables.CharacterAnimations.JUMP:
				shortHopTimer.stop_timer()
				if shortHop:
					velocity.y = -shortHopSpeed
				else: 
					velocity.y = -jumpSpeed
				disableInput = false
				switch_to_state(CharacterState.AIR)
				animation_handler(GlobalVariables.CharacterAnimations.JUMP)
			GlobalVariables.CharacterAnimations.GRAB:
				switch_to_state(CharacterState.GRAB)
			GlobalVariables.CharacterAnimations.FSMASHR:
				attack_handler_ground_smash_attacks()
			GlobalVariables.CharacterAnimations.FSMASHL:
				attack_handler_ground_smash_attacks()
			GlobalVariables.CharacterAnimations.UPSMASH:
				attack_handler_ground_smash_attacks()
			GlobalVariables.CharacterAnimations.DSMASH: 
				attack_handler_ground_smash_attacks()
			GlobalVariables.CharacterAnimations.UPTILT:
				animation_handler(GlobalVariables.CharacterAnimations.UPTILT)
				currentAttack = GlobalVariables.CharacterAnimations.UPTILT
			GlobalVariables.CharacterAnimations.DTILT:
				animation_handler(GlobalVariables.CharacterAnimations.DTILT)
				currentAttack = GlobalVariables.CharacterAnimations.DTILT
			GlobalVariables.CharacterAnimations.FTILTR:
				if currentMoveDirection != moveDirection.RIGHT:
					currentMoveDirection = moveDirection.RIGHT
					mirror_areas()
				animation_handler(GlobalVariables.CharacterAnimations.FTILTR)
				currentAttack = GlobalVariables.CharacterAnimations.FTILTR
			GlobalVariables.CharacterAnimations.FTILTL:
				if currentMoveDirection != moveDirection.LEFT:
					currentMoveDirection = moveDirection.LEFT
					mirror_areas()
				animation_handler(GlobalVariables.CharacterAnimations.FTILTL)
				currentAttack = GlobalVariables.CharacterAnimations.FTILTL
			GlobalVariables.CharacterAnimations.NAIR: 
				animation_handler(GlobalVariables.CharacterAnimations.NAIR)
				currentAttack = GlobalVariables.CharacterAnimations.NAIR
			GlobalVariables.CharacterAnimations.FAIR: 
				animation_handler(GlobalVariables.CharacterAnimations.FAIR)
				currentAttack = GlobalVariables.CharacterAnimations.FAIR
			GlobalVariables.CharacterAnimations.BAIR: 
				animation_handler(GlobalVariables.CharacterAnimations.BAIR)
				currentAttack = GlobalVariables.CharacterAnimations.BAIR
			GlobalVariables.CharacterAnimations.UPAIR: 
				animation_handler(GlobalVariables.CharacterAnimations.UPAIR)
				currentAttack = GlobalVariables.CharacterAnimations.UPAIR
			GlobalVariables.CharacterAnimations.DAIR: 
				animation_handler(GlobalVariables.CharacterAnimations.DAIR)
				currentAttack = GlobalVariables.CharacterAnimations.DAIR
	if bufferInput != GlobalVariables.CharacterAnimations.JAB1: 
		jabCount = 0
	bufferInput = null
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

func apply_hurt_animation_step(step =0):
	match step: 
		0:
			disableInputDI = false
		1:
			#if !onSolidGround:
			if currentState == CharacterState.HITSTUNAIR:
				animationPlayer.stop(false)
			#else:
				#print(onSolidGround.name)
		2:
			disableInput = false
			
func animation_invincibility_handler(step = 0):
	match step: 
		0:
			disableInput = true
			collisionAreaShape.set_deferred("disabled",true)
			create_invincible_timer(int(animationPlayer.current_animation_length *60))
		1:
			disableInput = false
			collisionAreaShape.set_deferred("disabled",false)
			switch_to_state(CharacterState.GROUND)
			
func apply_grab_animation_step(step = 0):
	match step: 
		0:
			grabbedCharacter = null
		1:
			if grabbedCharacter == null: 
				disableInput = false
				switch_to_state(CharacterState.GROUND)
			else: 
				velocity.x = 0
				create_grab_timer()
				
func disable_input_animation_step(step = 0):
	match step: 
		0:
			disableInput = true
		1:
			disableInput = false
			#apply grabjab to grabbed enemy
			if currentState == CharacterState.GRAB\
			&& currentAttack == GlobalVariables.CharacterAnimations.GRABJAB:
				grabbedCharacter.is_thrown_grabjabbed_handler(currentAttack)
			
func apply_throw_animation_step(step = 0):
	match step: 
		0:
			disableInput = true
		1:
			grabbedCharacter.is_thrown_grabjabbed_handler(currentAttack)
			grabbedCharacter = null
		2: 
			disableInput = false
			switch_to_state(CharacterState.GROUND)
			
func create_invincible_timer(duration = 0):
	enable_disable_hurtboxes(false)
	invincibilityTimer.set_frames(duration)
	print("duration " +str(duration))
	invincibilityTimer.start_timer()

func _on_invincibility_timer_timeout():
	print("invincibility timeout")
	enable_disable_hurtboxes(true)

func enable_disable_hurtboxes(enable = true):
	for singleHurtbox in hurtBox.get_children():
		if enable:
			singleHurtbox.set_deferred("disabled",false)
		else:
			singleHurtbox.set_deferred("disabled",true)

func switch_from_state_to_airborn():
	jumpCount = 1
	switch_to_state(CharacterState.AIR)
	enable_player_input()
	if currentState == CharacterState.HITSTUNGROUND:
		inHitStun = false
		hitStunTimer.stop_timer()
		
func switch_from_state_to_airborn_hitstun():
	switch_to_state(CharacterState.HITSTUNAIR)
	jumpCount = 1

func other_character_state_changed():
	emit_signal("character_state_changed", self, currentState)
	
#resets character hitbox/hurtbox/collisionshapes to default layout
#currentl 
func reset_character_to_default():
	pass

func disable_pushing_attack():
	pushingAttack = false
