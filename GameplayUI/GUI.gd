extends CanvasLayer

onready var characterContainer = preload("res://GameplayUI/CharacterContainer.tscn")
onready var characterGUI = get_node("CharacterGUI")
onready var timerGUILabel = get_node("TopScreenGUI/VBoxContainer/HBoxContainer/VBoxContainer/TimerGUI/HBoxContainer/TimerLabel")
onready var gameGUITimer = get_node("TopScreenGUI/VBoxContainer/HBoxContainer/VBoxContainer/TimerGUI/HBoxContainer/GameGUITimer")
onready var gameStartOverlay = get_node("GameStartOverlay")

var gameSetTimer = null
var gameSetFrames = 30

var timerSet = false
# Called when the node enters the scene tree for the first time.
func _ready():
	update_timer(Globals.roundTime/60)
	
func _process(delta):
	if timerSet:
		update_timer()

func add_character(character):
	var newCharacterContainer = characterContainer.instance()
	newCharacterContainer.setup(character)
	characterGUI.add_child(newCharacterContainer)
	return newCharacterContainer

func set_timer(waitTime):
	timerSet = true
	gameGUITimer.set_wait_time(waitTime/60.0)
	gameGUITimer.set_one_shot(true)
	gameGUITimer.start()

func update_timer(timeleft = 0):
	if !timeleft:
		timeleft = gameGUITimer.get_time_left()
	var minutes = floor(timeleft/60)
	var seconds = floor(timeleft)
	var milliseconds = stepify(timeleft-seconds,0.01)*100
	if minutes != 0: 
		seconds -= 60
	if minutes < 10:
		minutes = str("0")+String(minutes)
	if seconds < 10:
		seconds = str("0")+String(seconds)
	if milliseconds < 10:
		milliseconds = str("0")+String(milliseconds)
	timerGUILabel.set_bbcode(str(minutes) + ":" + str(seconds) + "." + str(milliseconds))

func game_set():
	gameStartOverlay.game_set()
	gameGUITimer.stop()
	timerSet = false
	gameSetTimer = Globals.create_timer("on_gameset_timeout", "Gamesettimer", self)
	create_gameset_timer(gameSetFrames)
	
func create_gameset_timer(waittime):
	Globals.start_timer(gameSetTimer, waittime)
	
func on_gameset_timeout():
	SceneSwitcher.goto_scene(SceneSwitcher.resultScreen)
