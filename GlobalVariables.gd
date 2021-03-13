extends Node

enum WorldType {Platform = 0, CenterStage = 1, Character = 2, Item = 3}

enum CharacterAnimations{IDLE, WALK, RUN, SLIDE, JUMP, DOUBLEJUMP, FREEFALL, JAB1, JAB2, JAB3, FTILTR, FTILTL ,UPTILT, DTILT, FAIR, BAIR, NAIR, UPAIR, DAIR, DASHATTACK, UPSMASH, DSMASH, FSMASHR, FSMASHL, HURT, HURTSHORT, ROLLGETUP, ATTACKGETUP, NORMALGETUP, SHIELD, ROLL, SPOTDODGE, SHIELDBREAK, GRAB, INGRAB, GRABJAB, BTHROW, FTHROW, UTHROW, DTHROW, GRABRELEASE, EDGESNAP, CROUCH, SHIELDDROP, TURNAROUNDSLOW, TURNAROUNDFAST, LANDINGLAGNORMAL, BACKFLIP, TUMBLE, HURTTRANSITION}

var countCharactersInGame = 2

var charactersInGame = []

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
	"up": "Up2",
	"down" : "Down2",
	"left" : "Left2",
	"right" : "Right2",
	"jump" : "Jump2",
	"attack" : "Attack2",
	"shield" : "Shield2",
	"grab" : "Grab2"
}

var gameRunning = 0
var frameByFrame = false
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _physics_process(delta):
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

