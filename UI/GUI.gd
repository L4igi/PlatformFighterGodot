extends CanvasLayer

onready var characterContainer = preload("res://UI/CharacterContainer.tscn")
onready var characterGUI = get_node("CharacterGUI")
onready var timerGUI = get_node("TopScreenGUI/VBoxContainer/HBoxContainer/VBoxContainer/TimerGUI/HBoxContainer/TimerLabel")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func add_character(character):
	var newCharacterContainer = characterContainer.instance()
	newCharacterContainer.setup(character)
	characterGUI.add_child(newCharacterContainer)
	return newCharacterContainer

func set_timer():
	pass
