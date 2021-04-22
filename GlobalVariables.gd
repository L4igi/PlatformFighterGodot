extends Node

enum WorldType {Platform = 0, CenterStage = 1, Character = 2, Item = 3}

enum CharacterAnimations{IDLE, WALK, RUN, SLIDE, JUMP, DOUBLEJUMP, FREEFALL, JAB1, JAB2, JAB3, FTILT, FTILTR, FTILTL ,UPTILT, DTILT, FAIR, BAIR, NAIR, UPAIR, DAIR, DASHATTACK, UPSMASH, DSMASH, FSMASH, FSMASHR, FSMASHL, SHORTHOPATTACK, HURT, HURTSHORT, LEDGEATTACKGETUP, LEDGEROLLGETUP, LEDGENORMALGETUP, LEDGEJUMPGETUP, ROLLGETUP, ATTACKGETUP, NORMALGETUP, SHIELD, ROLL, SPOTDODGE, SHIELDBREAK, GRAB, INGRAB, GRABJAB, BTHROW, FTHROW, UTHROW, DTHROW, GRABRELEASE, EDGESNAP, CROUCH, SHIELDDROP, TURNAROUNDSLOW, TURNAROUNDFAST, LANDINGLAGNORMAL, BACKFLIP, TUMBLE, HURTTRANSITION}

var countCharactersInGame = 2

var charactersInGame = []

var centerStage = null

enum TimerType{HITSTUN, SHORTHOP, DROPDOWN, INVINCIBILITY, GRAB, SMASHATTACK, SHIELDSTUN, SHIELDDROP, HITLAG, TURNAROUND, STOPMOVEMENT, SIDESTEP, LANDINGLAG, EDGEGRAB, HITLAGATTACKED, PLATFORMCOLLISION, EDGEDROPTIMER, SHIELDBREAKTIMER, TECHTIMER, TECHCOOLDOWNTIMER}

var attackAnimationList = ["attack_getup", "bair", "dair", "dash_attack", "dsmash", "dtilt", "fair", "fsmash", "ftilt", "jab1", "jab2", "nair", "upair", "upsmash", "uptilt"]

enum CharacterState{GROUND, AIR, EDGE, ATTACKGROUND, ATTACKAIR, HITSTUNGROUND, HITSTUNAIR, SPECIALGROUND, SPECIALAIR, SHIELD, ROLL, GRAB, INGRAB, SPOTDODGE, GETUP, SHIELDBREAK, CROUCH, EDGEGETUP, SHIELDSTUN, TECHGROUND, TECHAIR, AIRDODGE, HELPLESS}

enum MoveDirection {LEFT, RIGHT}

enum AirDodgeType{NORMAL, DIRECTIONAL}

enum AttackType {GROUNDED, AERIAL, SPECIALGROUNDED, SPECIALAERIAL}

var controlsP1 = {
	"up": "Up1",
	"down" : "Down1",
	"left" : "Left1",
	"right" : "Right1",
	"jump" : "Jump1",
	"attack" : "Attack1",
	"shield" : "Shield1",
	"grab" : "Grab1"
}

var controlsP2 = {
	"up": "Up1",
	"down" : "Down2",
	"left" : "Left2",
	"right" : "Right2",
	"jump" : "Jump1",
	"attack" : "Attack1",
	"shield" : "Shield2",
	"grab" : "Grab2"
}

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

func match_attack_type(attack):
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
	return attackType
