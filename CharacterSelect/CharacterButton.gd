extends MarginContainer

var character = null
onready var textureButton = get_node("TextureButton")

func _ready():
	pass # Replace with function body.

func setup(character):
	self.character = character


func _on_CharacterPreviewArea_body_entered(body):
	if body.is_in_group("UIControl"):
		body.set_preview_character(character)
		print("aaaaaaaaaaaaa")
