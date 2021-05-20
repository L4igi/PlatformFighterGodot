extends Node2D

onready var characterMario = preload("res://Characters/Mario/Mario.tscn")
onready var characterLink = preload("res://Characters/Link/Link.tscn")

onready var gameplayGUI = get_node("GameplayGUI")

var characterList = []

onready var spawnPoints = get_node("SpawnPoints").get_children()
onready var multiTargetCamera = preload("res://MultiTargetCamera2D.tscn")

var gameStartTimer = null

class_name CurrentStage

#var characters = [$Mario, $Dark_Mario]
# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.currentStage = self
	characterList = Globals.smashCharacters
	print(Globals.smashCharacters)
	if characterList.empty():
		spawn_characters()
	else:
		add_character_to_stage()
	setup_gui()
	gameStartTimer = Globals.create_timer("on_gameStart_timeout", "GameStartTimer", self)
	create_gamestart_timer()
	var newMultiTargetCamera = multiTargetCamera.instance()
	add_child(newMultiTargetCamera)
	newMultiTargetCamera.setup_multitarget_camera(characterList)
	
func set_up_stage():
	pass
	
func add_character_to_stage():
	var spawnPosition = 0
	for character in characterList:
		self.add_child(character)
		character.global_position = spawnPoints[spawnPosition].global_position
		if !spawnPosition%2:
			character.currentMoveDirection = Globals.MoveDirection.RIGHT
		else:
			character.currentMoveDirection = Globals.MoveDirection.LEFT
			character.mirror_areas()
		spawnPosition += 1
	
func setup_controls_characters(character, globalControls):
	character.up = globalControls.get("up")
	character.down = globalControls.get("down")
	character.left = globalControls.get("left")
	character.right = globalControls.get("right")
	character.shield = globalControls.get("shield")
	character.jump = globalControls.get("jump")
	character.attack = globalControls.get("attack")
	character.shield = globalControls.get("shield")
	character.grab = globalControls.get("grab")
	character.special = globalControls.get("special")
	
func spawn_characters():
	var char1 = characterMario.instance()
	self.add_child(char1)
	char1.global_position = spawnPoints[0].global_position
	char1.currentMoveDirection = Globals.MoveDirection.RIGHT
	char1.set_name("Mario")
	char1.characterName = "Mario"
	char1.stocks = 1
	characterList.append(char1)
	char1.characterControls = Globals.controlsP1
	char1.resultData.resultdata_setup(char1.get_name(), 1, char1.stocks)
	setup_controls_characters(char1, Globals.controlsP2)
	var char2 = characterLink.instance()
	self.add_child(char2)
	char2.global_position = spawnPoints[1].global_position
	char2.currentMoveDirection = Globals.MoveDirection.LEFT
	char2.mirror_areas()
	char2.set_name("Link")
	char2.characterName = "Link"
	char2.stocks = 1
	characterList.append(char2)
	char2.characterControls = Globals.controlsP2
	char2.resultData.resultdata_setup(char2.get_name(), 2, char2.stocks)
	setup_controls_characters(char2, Globals.controlsP1)
	
func setup_gui():
	for character in characterList: 
		character.characterGUI = gameplayGUI.add_character(character)


func create_gamestart_timer():
	Globals.start_timer(gameStartTimer, Globals.gameStartFrames)
	gameplayGUI.gameStartOverlay.gameStartTimer = gameStartTimer
	
func on_gameStart_timeout():
	gameplayGUI.set_timer(Globals.roundTime)
	for character in characterList:
		character.start_game()
