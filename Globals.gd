extends Node

enum WorldType {Platform = 0, CenterStage = 1, Character = 2, Item = 3}

enum CharacterAnimations{IDLE, WALK, RUN, SLIDE, JUMP, DOUBLEJUMP, FREEFALL, JAB1, JAB2, JAB3, FTILT, FTILTR, FTILTL ,UPTILT, DTILT, FAIR, BAIR, NAIR, UPAIR, DAIR, DASHATTACK, UPSMASH, DSMASH, FSMASH, FSMASHR, FSMASHL, SHORTHOPATTACK, HURT, HURTSHORT, LEDGEATTACKGETUP, LEDGEROLLGETUP, LEDGENORMALGETUP, LEDGEJUMPGETUP, ROLLGETUP, ATTACKGETUP, NORMALGETUP, SHIELD, ROLL, SPOTDODGE, SHIELDBREAK, GRAB, INGRAB, GRABJAB, BTHROW, FTHROW, UTHROW, DTHROW, GRABRELEASE, EDGESNAP, CROUCH, SHIELDDROP, TURNAROUNDSLOW, TURNAROUNDFAST, LANDINGLAGNORMAL, BACKFLIP, TUMBLE, HURTTRANSITION, UPSPECIAL, DOWNSPECIAL, SIDESPECIAL, NSPECIAL, COUNTER, THROWITEMUP, THROWITEMDOWN, THROWITEMFORWARD, ZDROPITEM, AIRDODGE}

var countCharactersInGame = 2

var charactersInGame = []

var centerStage = null

var currentStage = null

enum TimerType{HITSTUN, SHORTHOP, DROPDOWN, INVINCIBILITY, GRAB, SMASHATTACK, SHIELDSTUN, SHIELDDROP, HITLAG, TURNAROUND, STOPMOVEMENT, SIDESTEP, LANDINGLAG, EDGEGRAB, HITLAGATTACKED, PLATFORMCOLLISION, EDGEDROPTIMER, SHIELDBREAKTIMER, TECHTIMER, TECHCOOLDOWNTIMER}

var attackAnimationList = ["attack_getup", "bair", "dair", "dash_attack", "dsmash", "dtilt", "fair", "fsmash", "ftilt", "jab1", "jab2", "nair", "upair", "upsmash", "uptilt", "throw_item_up", "throw_item_down", "throw_item_forward"]

var specialAnimationList = ["neutralspecial", "downspecial", "sidespecial", "upspecial", "counter", "cancel_charge"]

enum CharacterState{GROUND, AIR, EDGE, ATTACKGROUND, ATTACKAIR, HITSTUNGROUND, HITSTUNAIR, SPECIALGROUND, SPECIALAIR, SHIELD, ROLL, GRAB, INGRAB, SPOTDODGE, GETUP, SHIELDBREAK, CROUCH, EDGEGETUP, SHIELDSTUN, TECHGROUND, TECHAIR, AIRDODGE, HELPLESS, REBOUND, COUNTER, RESPAWN, GAMESTART, DEFEAT, GAMEOVER}

enum MoveDirection {LEFT, RIGHT}

enum AirDodgeType{NORMAL, DIRECTIONAL}

enum AttackType {GROUNDED, AERIAL, PROJECTILE}

enum SpecialHitboxType {REFLECT, REVERSE, ABSORB, COUNTER, NEUTRAL, FIRE, BOMB}

enum ProjectileInteractions {REFLECTED, ABSORBED, DESTROYED, IMPACTED, COUNTERED, CONTINOUS, CATCH, HITOTHERCHARACTER, HITOTHERCHARACTERSHIELD}

#connected if hitbox conneted with hurtbox, clashes if two hitboxes connected with each other
enum HitBoxInteractionType {CONNECTED, CLASHED}

enum ProjectileState {SHOOT, IMPACT, CONTROL, DESTROYED, HOLD, CHARGE, IDLE}

enum ProjectileAnimations {SHOOT, IMPACT}

var respawningCharacters = []

var gameStartFrames = 180

var roundTime = 6000

enum availableCharacters {Mario}

var controlsP1 = {
	"up": "Up1",
	"down" : "Down1",
	"left" : "Left1",
	"right" : "Right1",
	"jump" : "Jump1",
	"attack" : "Attack1",
	"shield" : "Shield1",
	"grab" : "Grab1", 
	"special" : "Special1", 
	"start" : "Start1"
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
	"special": "Special2", 
	"start" : "Start2"
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
		Globals.CharacterAnimations.JAB1:
			attackType = AttackType.GROUNDED
		Globals.CharacterAnimations.JAB2:
			attackType = AttackType.GROUNDED
		Globals.CharacterAnimations.JAB2:
			attackType = AttackType.GROUNDED
		Globals.CharacterAnimations.FTILT:
			attackType = AttackType.GROUNDED
		Globals.CharacterAnimations.UPTILT:
			attackType = AttackType.GROUNDED
		Globals.CharacterAnimations.DTILT:
			attackType = AttackType.GROUNDED
		Globals.CharacterAnimations.DASHATTACK:
			attackType = AttackType.GROUNDED
		Globals.CharacterAnimations.FSMASH:
			attackType = AttackType.GROUNDED
		Globals.CharacterAnimations.UPSMASH:
			attackType = AttackType.GROUNDED
		Globals.CharacterAnimations.DSMASH:
			attackType = AttackType.GROUNDED
		Globals.CharacterAnimations.NAIR:
			attackType = AttackType.AERIAL
		Globals.CharacterAnimations.FAIR:
			attackType = AttackType.AERIAL
		Globals.CharacterAnimations.DAIR:
			attackType = AttackType.AERIAL
		Globals.CharacterAnimations.UPAIR:
			attackType = AttackType.AERIAL
		Globals.CharacterAnimations.BAIR:
			attackType = AttackType.AERIAL
		Globals.CharacterAnimations.BTHROW:
			attackType = AttackType.GROUNDED
		Globals.CharacterAnimations.DTHROW:
			attackType = AttackType.GROUNDED
		Globals.CharacterAnimations.UTHROW:
			attackType = AttackType.GROUNDED
		Globals.CharacterAnimations.BTHROW:
			attackType = AttackType.GROUNDED
		#special moves
		Globals.CharacterAnimations.DOWNSPECIAL:
			if object.onSolidGround:
				attackType = AttackType.GROUNDED
			else: 
				attackType = AttackType.AERIAL
		Globals.CharacterAnimations.UPSPECIAL:
			if object.onSolidGround:
				attackType = AttackType.GROUNDED
			else: 
				attackType = AttackType.AERIAL
		Globals.CharacterAnimations.SIDESPECIAL:
			if object.onSolidGround:
				attackType = AttackType.GROUNDED
			else: 
				attackType = AttackType.AERIAL
		Globals.CharacterAnimations.NSPECIAL:
			if object.onSolidGround:
				attackType = AttackType.GROUNDED
			else: 
				attackType = AttackType.AERIAL
		Globals.CharacterAnimations.GRAB:
			attackType = AttackType.GROUNDED
	return attackType

func launchVector_inversion(currentAttackData, attackingObject, attackedObject):
	var launchVectorInversion = false
	if currentAttackData["facing_direction"] == 0:
		match attackingObject.currentMoveDirection:
			Globals.MoveDirection.RIGHT:
				launchVectorInversion = false
			Globals.MoveDirection.LEFT:
				launchVectorInversion = true
	elif currentAttackData["facing_direction"] == 1\
	&& attackedObject.global_position.x < attackingObject.global_position.x:
		match attackingObject.currentMoveDirection:
			Globals.MoveDirection.RIGHT:
				launchVectorInversion = false
			Globals.MoveDirection.LEFT:
				launchVectorInversion = true
	#opposit direction player if facing
	if currentAttackData["facing_direction"] == 2:
		match attackingObject.currentMoveDirection:
			Globals.MoveDirection.RIGHT:
				launchVectorInversion = true
			Globals.MoveDirection.LEFT:
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

#character ranking
var characterRanking = []

func check_game_set():
	var countDefeated = 0
	for character in currentStage.characterList:
		if character.currentState == Globals.CharacterState.DEFEAT:
			countDefeated += 1
			characterRanking.push_front(character)
	if countDefeated == currentStage.characterList.size()-1:
		#find out winning character
		var winner = null
		for character in currentStage.characterList: 
			if !characterRanking.has(character):
				winner = character
		characterRanking.push_front(winner)
		Engine.set_time_scale(0.25)
		currentStage.gameplayGUI.game_set()
	
func remove_characters_from_parent():
	for character in characterRanking:
		print(character.get_parent().remove_child(character))

func create_result_data(character):
	var newResultData = ResultData.new()
	character.add_child(newResultData)
	return newResultData

#start new game from character select
func setup_new_game():
	pass
