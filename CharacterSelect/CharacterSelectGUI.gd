extends VBoxContainer

onready var characterButton = preload("res://CharacterSelect/CharacterButton.tscn")
onready var characterGridContainer = get_node("CharacterSelectContainer/HBoxContainer/GridContainer")

# Called when the node enters the scene tree for the first time.
func _ready():
	for character in Globals.availableCharacters.keys():
		var newCharacterButton = characterButton.instance()
		newCharacterButton.setup(character)
		characterGridContainer.add_child(newCharacterButton)
