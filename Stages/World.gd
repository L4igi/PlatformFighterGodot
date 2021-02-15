extends Node2D

onready var characterStateUI = preload("res://UI/CharacterDamage.tscn")

#var characters = [$Mario, $Dark_Mario]
# Called when the node enters the scene tree for the first time.
#func _ready():
#	for character in characters: 
#		set_up_character_ui(character)


func set_up_character_ui(character):
	var charUI = characterStateUI.instance()
	$CanvasLayer.add_child(charUI)
	charUI.set_name("Character"+str($CanvasLayer.get_child_count())+"UI")
	
