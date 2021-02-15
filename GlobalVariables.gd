extends Node

enum WorldType {Platform = 0, CenterStage = 1, Character = 2, Item = 3}

enum CharacterAnimations{IDLE, WALK, RUN, SLIDE, JUMP, DOUBLEJUMP, FREEFALL, JAB1, JAB2, JAB3, FTILT ,UPTILT, DTILT, FAIR, BAIR, NAIR, UPAIR, DAIR, DASHATTACK, UPSMASH, DSMASH, FSMASH, HURT, HURTSHORT, ROLLGETUP, ATTACKGETUP, NORMALGETUP, SHIELD, ROLL, SPOTDODGE, SHIELDBREAK, GRAB, INGRAB, GRABJAB, BTHROW, FTHROW, UTHROW, DTHROW, GRABRELEASE, EDGESNAP, CROUCH}

enum SmashAttacks{SMASHRIGHT, SMASHLEFT, SMASHUP, SMASHDOWN}

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

