extends Node

var availableColors = [Color(1,1,1,1), Color(0,1,0,1), Color(1,1,0,1), Color(0,1,1,1)]
var usedColors = []
var playersOnButton = 0

func get_character_name():
	return "Mario"

func get_character_icon():
	return preload("res://Characters/Mario/guielements/characterIcon.png")

func get_character_logo():
	return preload("res://Characters/Mario/guielements/characterLogo.png")

func get_instance_path():
	var characterNode = load("res://Characters/Mario/Mario.tscn")
	return characterNode
	
func get_first_availavle_color():
	if playersOnButton == 0:
		usedColors.append(availableColors[0]) 
		return availableColors[0]
	else: 
		for color in availableColors:
			if !usedColors.has(color):
				usedColors.append(color)
				return color

func get_next_color(currentColor):
	var colorPosition = availableColors.find(currentColor)
	for idx in range(colorPosition, availableColors.size()):
		var color = availableColors[idx]
		if !usedColors.has(color):
			usedColors.append(color)
			usedColors.erase(currentColor)
			return color
	for color in availableColors:
		if !usedColors.has(color):
			usedColors.append(color)
			usedColors.erase(currentColor)
			return color
			
func get_previous_color(currentColor):
	var colorPosition = availableColors.find(currentColor)
	for idx in range(colorPosition, -1, -1):
		var color = availableColors[idx]
		if !usedColors.has(color):
			usedColors.append(color)
			usedColors.erase(currentColor)
			return color
	var invertedColorArray = availableColors.duplicate(true)
	invertedColorArray.invert()
	for color in invertedColorArray:
		if !usedColors.has(color):
			usedColors.append(color)
			usedColors.erase(currentColor)
			return color
			
func on_charactercontainer_delete(color):
	usedColors.erase(color)

func increase_players_on_buttons():
	playersOnButton += 1
	
func decrease_players_on_buttons(color):
	usedColors.erase(color)
	playersOnButton -= 1
