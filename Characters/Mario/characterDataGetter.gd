extends Node

func get_character_name():
	return "Mario"

func get_character_icon():
	return preload("res://Characters/Mario/guielements/characterIcon.png")

func get_character_logo():
	return preload("res://Characters/Mario/guielements/characterLogo.png")

func get_instance_path():
	var characterNode = load("res://Characters/Mario/Mario.tscn")
	return characterNode
