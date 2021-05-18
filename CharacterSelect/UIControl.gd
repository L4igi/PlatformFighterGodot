extends KinematicBody2D

var characterSelect = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var up = null
var down = null
var left = null
var right = null
var select = null
var cancel = null
var selectSkinFw = null
var selectSkinBw = null
var startGame = null

var velocity = Vector2.ZERO
var acceleration = 10
var stopForce = 100

var previewCharacter = null
var selectedCharacter = null

var characterContainer = null
var controls = null

onready var characterToken = preload("res://CharacterSelect/CharacterToken.tscn")
var setToken = null

var enableStartGame = false

var playerName = "Player"
var playerNumber = ""
var characterIcon = null
var characterLogo = null
var characterName = null
var currentColor = null
var characterDataPath = null
var characterDataGetter = null
# Called when the node enters the scene tree for the first time.
func _ready():
	characterSelect = get_parent()
	global_position =  get_viewport().get_size()/2
	
func setup(control, currentPlayerNumber):
	playerName += str(currentPlayerNumber)
	playerNumber = currentPlayerNumber
	self.controls = control
	setup_controls(control)
	
func setup_controls(controls):
	up = controls.get("up")
	down = controls.get("down")
	left = controls.get("left")
	right = controls.get("right")
	select = controls.get("attack")
	cancel = controls.get("special")
	selectSkinFw = controls.get("shield")
	selectSkinBw = controls.get("grab")
	startGame = controls.get("start")

func handle_input():
	if Input.is_action_just_pressed(left):
		pass
	if Input.is_action_just_pressed(right):
		pass
	if Input.is_action_just_pressed(up):
		pass
	if Input.is_action_just_pressed(down):
		pass
	if Input.is_action_just_pressed(select):
		select_character()
	elif Input.is_action_just_pressed(cancel):
		deselect_character()
	if Input.is_action_just_pressed(selectSkinFw):
		if characterDataGetter:
			currentColor = characterDataGetter.get_next_color(currentColor)
			characterContainer.update_color(currentColor)
	elif Input.is_action_just_pressed(selectSkinBw):
		if characterDataGetter:
			currentColor = characterDataGetter.get_previous_color(currentColor)
			characterContainer.update_color(currentColor)
	if Input.is_action_just_pressed(startGame)\
	&& enableStartGame:
		characterSelect.start_game()
		print("START GAME LEZZZ GO")
#
#func _input(event):
#   # Mouse in viewport coordinates.
#   if event is InputEventMouseButton:
#	   print("Mouse Click/Unclick at: ", event.position)
##   elif event is InputEventMouseMotion:
##	   print("Mouse Motion at: ", event.position)

#func click_the_left_mouse_button(onOff):
#	var evt = InputEventMouseButton.new()
#	evt.button_index = BUTTON_LEFT
#	var screenSizeModifier = Vector2.ZERO
##	if OS.is_window_fullscreen():
##		#get screen pixels not covered by game
##		screenSizeModifier = OS.get_screen_size() - get_viewport().get_size()
##		#get value by which game is scaled up
##		screenSizeModifier /= get_viewport().get_size()/get_viewport().get_visible_rect().size
##	else:
#	#get screen pixels not covered by game
#	screenSizeModifier = OS.get_window_size() - get_viewport().get_size()
#	#get value by which game is scaled up
#	screenSizeModifier /= get_viewport().get_size()/get_viewport().get_visible_rect().size
##	screenSizeModifier = Vector2(0,0)
#	evt.set_position((get_viewport_transform() * get_global_transform() * (self.position+screenSizeModifier))/2)
#	match onOff: 
#		"on":
#			evt.pressed = true
#		"off":
#			evt.pressed = false
#	get_tree().input_event(evt)

func select_character():
	if previewCharacter && !selectedCharacter:
		selectedCharacter = previewCharacter
		print("character selected")
		create_character_token()
		characterSelect.character_selected(self)
	
func deselect_character():
	if selectedCharacter:
		selectedCharacter = null
		print("character deselected")
		delete_character_token()
		characterSelect.character_deselected(self, previewCharacter)

func handle_control_physics(_delta):
	var xInput = get_input_direction_x()
	var yInput = get_input_direction_y()
	if xInput == 0 && yInput == 0:
		velocity = Vector2.ZERO
	velocity = Vector2(acceleration * xInput, acceleration * yInput) 
	move_and_collide(velocity)

func _physics_process(_delta):
	handle_input()
	handle_control_physics(_delta)
	
func get_input_direction_x():
	return Input.get_action_strength(right) - Input.get_action_strength(left)
	
func get_input_direction_y():
	return Input.get_action_strength(down) - Input.get_action_strength(up)

func set_preview_character(characterDataGetter, characterDataPath):
	self.characterDataPath = characterDataPath
	self.characterDataGetter = characterDataGetter
	characterIcon = characterDataGetter.get_character_icon()
	characterLogo = characterDataGetter.get_character_logo()
	characterName = characterDataGetter.get_character_name()
	currentColor = characterDataGetter.get_first_availavle_color()
	previewCharacter = characterName
	characterContainer.setup_hover(characterIcon, characterLogo, characterName, currentColor)
	
func remove_preview_character():
	if !selectedCharacter:
		previewCharacter = null
		characterContainer.remove_hover()
	
func create_character_token():
	var newToken = characterToken.instance()
	characterSelect.add_child(newToken)
	newToken.set_deferred("global_position", self.global_position)
	setToken = newToken
	
func delete_character_token():
	setToken.queue_free()
	setToken = null
	
func toggle_game_start(onOff):
	match onOff:
		"on":
			enableStartGame = true
		"off":
			enableStartGame = false
