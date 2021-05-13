extends CanvasLayer

onready var characterGUI = preload("res://UI/CharacterContainer.tscn")
onready var TimerGUI = get_node("TopScreenGUI/VBoxContainer/HBoxContainer/VBoxContainer/TimerGUI/TimerLabel")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func add_character():
	var newCharacterGUI = characterGUI.instance()
	return newCharacterGUI

func set_timer():
	pass
