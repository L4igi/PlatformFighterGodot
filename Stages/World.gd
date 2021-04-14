extends Node2D

onready var characterMario = preload("res://Characters/Mario/Mario.tscn")

onready var characterStateUI = preload("res://UI/CharacterDamage.tscn")

var characterList = []

#var characters = [$Mario, $Dark_Mario]
# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_characters()
		

func set_up_character_ui(character):
	var charUI = characterStateUI.instance()
	$CanvasLayer.add_child(charUI)
	charUI.set_name("Character"+str($CanvasLayer.get_child_count())+"UI")
	
func spawn_characters():
	var char1 = characterMario.instance()
	self.add_child(char1)
	char1.global_position = Vector2(300, -500)
	char1.set_name("Mario")
	characterList.append(char1)
	setup_controls_characters(char1, GlobalVariables.controlsP1)
	var char2 = characterMario.instance()
	self.add_child(char2)
	char2.global_position = Vector2(700, -500)
	char2.set_name("DarkMario")
	characterList.append(char2)
	char2.get_node("AnimatedSprite").set_self_modulate(Color(0,1,0,1))
	setup_controls_characters(char2, GlobalVariables.controlsP2)
	
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
