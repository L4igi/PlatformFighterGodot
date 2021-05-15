extends HBoxContainer

onready var characterResultGUI = preload("res://Results/CharacterResult.tscn")

func add_character_result_gui(character):
	var newCharacterGUI = characterResultGUI.instance()
	newCharacterGUI.setup(character)
	add_child(newCharacterGUI)

func enable_result_gui():
	for gui in get_children():
		gui.set_current_step_zero()
