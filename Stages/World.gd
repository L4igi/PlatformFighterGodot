extends Node2D

onready var characterMario = preload("res://Characters/Mario/Mario.tscn")

onready var gameplayGUI = get_node("GameplayGUI")

var characterList = []

#var characters = [$Mario, $Dark_Mario]
# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalVariables.currentStage = self
	spawn_characters()
	setup_gui()
	
func spawn_characters():
	var char1 = characterMario.instance()
	self.add_child(char1)
	char1.global_position = Vector2(300, -500)
	char1.set_name("Mario")
	char1.characterName = "Mario"
	char1.stocks = 3
	characterList.append(char1)
	char1.characterControls = GlobalVariables.controlsP1
	setup_controls_characters(char1, GlobalVariables.controlsP1)
	var char2 = characterMario.instance()
	self.add_child(char2)
	char2.global_position = Vector2(700, -500)
	char2.set_name("DarkMario")
	char2.characterName = "DarkMario"
	char2.stocks = 3
	characterList.append(char2)
	char2.characterControls = GlobalVariables.controlsP2
	char2.get_node("AnimatedSprite").set_self_modulate(Color(0,1,0,1))
	setup_controls_characters(char2, GlobalVariables.controlsP2)
	char2.set_attack_data_file()
	
func setup_gui():
	for character in characterList: 
		character.characterGUI = gameplayGUI.add_character(character)
	
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
