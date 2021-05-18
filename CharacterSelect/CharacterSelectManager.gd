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

func add_controls(controls):
	setupControls.append(controls)

func check_action_event(event):
	for control in setupControls:
		for input in control.values():
			if event.is_action_pressed(input):
				setupControls.erase(control)
				spawn_uiControl(control)
				return

func spawn_uiControl(control):
	var newUiControl = uiControl.instance()
	add_child(newUiControl)
	newUiControl.setup(control, currentPlayerNumber)
	newUiControl.characterContainer = spawn_character_container(newUiControl)
	
func spawn_character_container(newUiControl):
	var playerName = "Player"+str(currentPlayerNumber)
	var playerNumber = currentPlayerNumber
	currentPlayerNumber += 1
	return characterSelectGUI.instance_character_container(playerName, playerNumber, newUiControl)
	
func character_selected(UIControl):
	characterSelectedUIControl.append(UIControl)
	if characterSelectedUIControl.size() >= 2\
	&& characterSelectedUIControl.size() == currentPlayerNumber-1:
		toggle_game_start("on")
	
func character_deselected(UIControl, previewCharacter = null):
	toggle_game_start("off")
	if !previewCharacter:
		UIControl.remove_preview_character()
	characterSelectedUIControl.erase(UIControl)
	
func toggle_game_start(onOff):
	match onOff:
		"on":
			gameStartContainer.set_visible(true)
		"off":
			gameStartContainer.set_visible(false)
	for uiControl in characterSelectedUIControl:
		uiControl.toggle_game_start(onOff)
		
func start_game():
	Globals.setup_new_game(characterSelectedUIControl)

func update_player_numbers(playerNumber):
	var uiController = []
	for child in get_children():
		if child.is_in_group("UIControl"):
			uiController.append(child)
	for uiControl in uiController:
		if uiControl.playerNumber > playerNumber:
			uiControl.playerNumber -= 1
			uiControl.characterContainer.set_player_number(uiControl.playerNumber)
	currentPlayerNumber -= 1
