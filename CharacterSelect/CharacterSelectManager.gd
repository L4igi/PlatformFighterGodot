extends Node2D

onready var uiControl = preload("res://CharacterSelect/UIControl.tscn")
onready var characterSelectGUI = get_node("CharacterSelectGUI")
onready var gameStartContainer = get_node("GameStartContainer")

var setupControls = []

var currentPlayerNumber = 1

var characterSelectedUIControl = []

func _ready():
	setupControls.append(Globals.controlsP1)
	setupControls.append(Globals.controlsP2)
	
func _input(event):
	check_action_event(event)

func process():
	pass

func check_action_event(event):
	var currentControl = 0
	for control in setupControls:
		for input in control.values():
			if event.is_action(input):
				setupControls.erase(control)
				spawn_uiControl(control)
				return
		currentControl += 1

func spawn_uiControl(control):
	var newUiControl = uiControl.instance()
	newUiControl.setup(control, currentPlayerNumber)
	add_child(newUiControl)
	newUiControl.characterContainer = spawn_character_container()
	
func spawn_character_container():
	var playerName = "Player"+str(currentPlayerNumber)
	var playerNumber = currentPlayerNumber
	currentPlayerNumber += 1
	return characterSelectGUI.instance_character_container(playerName, playerNumber)
	
func character_selected(UIControl):
	characterSelectedUIControl.append(UIControl)
	if characterSelectedUIControl.size() >= 2\
	&& characterSelectedUIControl.size() == currentPlayerNumber-1:
		toggle_start_game("on")
	
func character_deselected(UIControl):
	toggle_start_game("off")
	UIControl.remove_preview_character()
	characterSelectedUIControl.erase(UIControl)
	
func toggle_start_game(onOff):
	match onOff:
		"on":
			gameStartContainer.set_visible(true)
		"off":
			gameStartContainer.set_visible(false)
	for uiControl in characterSelectedUIControl:
		uiControl.toggle_game_start(onOff)
		
func start_game():
	Globals.setup_new_game(characterSelectedUIControl)
