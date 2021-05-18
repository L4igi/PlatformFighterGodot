extends MarginContainer

var character = "Mario"

var characterDataGetter = null
var characterDataPath = ""

func _ready():
	pass # Replace with function body.

func setup(character):
	self.character = character
	characterDataPath = str("res://Characters/"+str(character)+"/characterDataGetter.gd")
	characterDataGetter = load(characterDataPath).new()
	add_child(characterDataGetter)
	set_character_name()
	set_character_icon()


func _on_CharacterPreviewArea_body_entered(body):
	if body.is_in_group("UIControl"):
		body.areaEntered = self
		if body.set_preview_character(characterDataGetter, characterDataPath):
			characterDataGetter.increase_players_on_buttons()

func _on_CharacterPreviewArea_body_exited(body):
	if body.is_in_group("UIControl") && !body.bodyDeleted:
		body.areaEntered = null
		if body.remove_preview_character():
			characterDataGetter.decrease_players_on_buttons(body.currentColor)


func set_character_icon():
	var characterIcon = get_node("CharacterIcon")
	characterIcon.set_texture(characterDataGetter.get_character_icon())
	
func set_character_name():
	var characterNameLabel = get_node("CharacterName")
	var characterName = characterDataGetter.get_character_name()
	characterNameLabel.set_bbcode("[center]"+str(characterName)+"[/center]")
