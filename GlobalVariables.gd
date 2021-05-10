extends Node

enum WorldType {Platform = 0, CenterStage = 1, Character = 2, Item = 3}

enum CharacterAnimations{IDLE, WALK, RUN, SLIDE, JUMP, DOUBLEJUMP, FREEFALL, JAB1, JAB2, JAB3, FTILT, FTILTR, FTILTL ,UPTILT, DTILT, FAIR, BAIR, NAIR, UPAIR, DAIR, DASHATTACK, UPSMASH, DSMASH, FSMASH, FSMASHR, FSMASHL, SHORTHOPATTACK, HURT, HURTSHORT, LEDGEATTACKGETUP, LEDGEROLLGETUP, LEDGENORMALGETUP, LEDGEJUMPGETUP, ROLLGETUP, ATTACKGETUP, NORMALGETUP, SHIELD, ROLL, SPOTDODGE, SHIELDBREAK, GRAB, INGRAB, GRABJAB, BTHROW, FTHROW, UTHROW, DTHROW, GRABRELEASE, EDGESNAP, CROUCH, SHIELDDROP, TURNAROUNDSLOW, TURNAROUNDFAST, LANDINGLAGNORMAL, BACKFLIP, TUMBLE, HURTTRANSITION, UPSPECIAL, DOWNSPECIAL, SIDESPECIAL, NSPECIAL, COUNTER, THROWITEMUP, THROWITEMDOWN, THROWITEMFORWARD, ZDROPITEM}

var countCharactersInGame = 2

var charactersInGame = []

var centerStage = null

var currentStage = null

enum TimerType{HITSTUN, SHORTHOP, DROPDOWN, INVINCIBILITY, GRAB, SMASHATTACK, SHIELDSTUN, SHIELDDROP, HITLAG, TURNAROUND, STOPMOVEMENT, SIDESTEP, LANDINGLAG, EDGEGRAB, HITLAGATTACKED, PLATFORMCOLLISION, EDGEDROPTIMER, SHIELDBREAKTIMER, TECHTIMER, TECHCOOLDOWNTIMER}

var attackAnimationList = ["attack_getup", "bair", "dair", "dash_attack", "dsmash", "dtilt", "fair", "fsmash", "ftilt", "jab1", "jab2", "nair", "upair", "upsmash", "uptilt", "throw_item_up", "throw_item_down", "throw_item_forward"]

var specialAnimationList = ["neutralspecial", "downspecial", "sidespecial", "upspecial", "counter"]

enum CharacterState{GROUND, AIR, EDGE, ATTACKGROUND, ATTACKAIR, HITSTUNGROUND, HITSTUNAIR, SPECIALGROUND, SPECIALAIR, SHIELD, ROLL, GRAB, INGRAB, SPOTDODGE, GETUP, SHIELDBREAK, CROUCH, EDGEGETUP, SHIELDSTUN, TECHGROUND, TECHAIR, AIRDODGE, HELPLESS, REBOUND, COUNTER}

enum MoveDirection {LEFT, RIGHT}

enum AirDodgeType{NORMAL, DIRECTIONAL}

enum AttackType {GROUNDED, AERIAL, PROJECTILE}

enum SpecialHitboxType {REFLECT, REVERSE, ABSORB, COUNTER, NEUTRAL}

enum ProjectileInteractions {REFLECTED, ABSORBED, DESTROYED, IMPACTED, COUNTERED, CONTINOUS, CATCH, HITOTHERCHARACTER, HITOTHERCHARACTERSHIELD}

#connected if hitbox conneted with hurtbox, clashes if two hitboxes connected with each other
enum HitBoxInteractionType {CONNECTED, CLASHED}

enum ProjectileState {SHOOT, IMPACT, CONTROL, DESTROYED, HOLD}

enum ProjectileAnimations {SHOOT, IMPACT}

var controlsP1 = {
	"up": "Up1",
	"down" : "Down1",
	"left" : "Left1",
	"right" : "Right1",
	"jump" : "Jump1",
	"attack" : "Attack1",
	"shield" : "Shield1",
	"grab" : "Grab1", 
	"special" : "Special1"
}

var controlsP2 = {
	"up": "Up2",
	"down" : "Down2",
	"left" : "Left2",
	"right" : "Right2",
	"jump" : "Jump2",
	"attack" : "Attack2",
	"shield" : "Shield2",
	"grab" : "Grab2", 
	"special": "Special2"
}
#var controlsP2 = {
#	"up": "Up1",
#	"down" : "Down1",
#	"left" : "Right1",
#	"right" : "Left1",
#	"jump" : "Jump1",
#	"attack" : "Attack1",
#	"shield" : "Shield1",
#	"grab" : "Grab1", 
#	"special": "Special1"
#}

var gameRunning = 0
var frameByFrame = false
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(_delta):
	if Input.is_action_just_pressed("toggleFrameByFrame"):
		if frameByFrame == false: 
			frameByFrame = true
		else:
			frameByFrame = false
			get_tree().set_pause(false)
	if frameByFrame:
		get_tree().set_pause(true)
		if Input.is_action_just_pressed("AdvanceFrame"):
			if get_tree().is_paused():
				get_tree().set_pause(false)
		if Input.is_action_pressed("AdvanceFrame"):
			gameRunning += 1
			if gameRunning > 10:
				get_tree().set_pause(false)
		if Input.is_action_just_released("AdvanceFrame"):
			gameRunning = 0

func match_attack_type_character(object, attack):
	var attackType = null
	match attack:
		GlobalVariables.CharacterAnimations.JAB1:
			attackType = AttackType.GROUNDED
		GlobalVariables.CharacterAnimations.JAB2:
			attackType = AttackType.GROUNDED
		GlobalVariables.CharacterAnimations.JAB2:
			attackType = AttackType.GROUNDED
		GlobalVariables.CharacterAnimations.FTILT:
			attackType = AttackType.GROUNDED
		GlobalVariables.CharacterAnimations.UPTILT:
			attackType = AttackType.GROUNDED
		GlobalVariables.CharacterAnimations.DTILT:
			attackType = AttackType.GROUNDED
		GlobalVariables.CharacterAnimations.DASHATTACK:
			attackType = AttackType.GROUNDED
		GlobalVariables.CharacterAnimations.FSMASH:
			attackType = AttackType.GROUNDED
		GlobalVariables.CharacterAnimations.UPSMASH:
			attackType = AttackType.GROUNDED
		GlobalVariables.CharacterAnimations.DSMASH:
			attackType = AttackType.GROUNDED
		GlobalVariables.CharacterAnimations.NAIR:
			attackType = AttackType.AERIAL
		GlobalVariables.CharacterAnimations.FAIR:
			attackType = AttackType.AERIAL
		GlobalVariables.CharacterAnimations.DAIR:
			attackType = AttackType.AERIAL
		GlobalVariables.CharacterAnimations.UPAIR:
			attackType = AttackType.AERIAL
		GlobalVariables.CharacterAnimations.BAIR:
			attackType = AttackType.AERIAL
		GlobalVariables.CharacterAnimations.BTHROW:
			attackType = AttackType.GROUNDED
		GlobalVariables.CharacterAnimations.DTHROW:
			attackType = AttackType.GROUNDED
		GlobalVariables.CharacterAnimations.UTHROW:
			attackType = AttackType.GROUNDED
		GlobalVariables.CharacterAnimations.BTHROW:
			attackType = AttackType.GROUNDED
		#special moves
		GlobalVariables.CharacterAnimations.DOWNSPECIAL:
			if object.onSolidGround:
				attackType = AttackType.GROUNDED
			else: 
				attackType = AttackType.AERIAL
		GlobalVariables.CharacterAnimations.UPSPECIAL:
			if object.onSolidGround:
				attackType = AttackType.GROUNDED
			else: 
				attackType = AttackType.AERIAL
		GlobalVariables.CharacterAnimations.SIDESPECIAL:
			if object.onSolidGround:
				attackType = AttackType.GROUNDED
			else: 
				attackType = AttackType.AERIAL
		GlobalVariables.CharacterAnimations.NSPECIAL:
			if object.onSolidGround:
				attackType = AttackType.GROUNDED
			else: 
				attackType = AttackType.AERIAL
		GlobalVariables.CharacterAnimations.GRAB:
			attackType = AttackType.GROUNDED
	return attackType

func launchVector_inversion(currentAttackData, attackingObject, attackedObject):
	var launchVectorInversion = false
	if currentAttackData["facing_direction"] == 0:
		match attackingObject.currentMoveDirection:
			GlobalVariables.MoveDirection.RIGHT:
				launchVectorInversion = false
			GlobalVariables.MoveDirection.LEFT:
				launchVectorInversion = true
	elif currentAttackData["facing_direction"] == 1\
	&& attackedObject.global_position.x < attackingObject.global_position.x:
		match attackingObject.currentMoveDirection:
			GlobalVariables.MoveDirection.RIGHT:
				launchVectorInversion = false
			GlobalVariables.MoveDirection.LEFT:
				launchVectorInversion = true
	#opposit direction player if facing
	if currentAttackData["facing_direction"] == 2:
		match attackingObject.currentMoveDirection:
			GlobalVariables.MoveDirection.RIGHT:
				launchVectorInversion = true
			GlobalVariables.MoveDirection.LEFT:
				launchVectorInversion = false
	#always send attacked attackingObject in the direction it is in comparison to attacker
	elif currentAttackData["facing_direction"] == 3:
		if attackedObject.global_position.x <= attackingObject.global_position.x:
			launchVectorInversion = true
		else:
			launchVectorInversion = false
	return launchVectorInversion

func create_timer(timeout_function, timerName, object):
	var timer = Timer.new()    
	timer.set_name(timerName)
	object.add_child (timer)
	timer.connect("timeout", object, timeout_function) 
	return timer
	
func start_timer(timer, waitTime, oneShot = true):
	timer.set_wait_time(waitTime/60.0)
	timer.set_one_shot(oneShot)
	timer.start()
