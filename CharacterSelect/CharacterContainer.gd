extends MarginContainer

class_name CharacterContainer

onready var characterIcon = get_node("HBoxContainer/MarginContainer/CharacterIcon")
onready var characterLogo = get_node("HBoxContainer/MarginContainer2/VBoxContainer2/CharacterLogo")
onready var charactername = get_node("HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer/CharacterName")
onready var playerName = get_node("HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer2/PlayerName")
onready var playerNumber = get_node("HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer3/PlayerNumber")

onready var playerNamesPopUp = get_node("HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer2/PlayerName/PlayerNamesPopUp")
onready var playerNameSelectAres = get_node("HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer2/PlayerName/PlayerNameSelectArea")
onready var playerNameList = get_node("HBoxContainer/MarginContainer2/VBoxContainer/MarginContainer2/PlayerName/PlayerNamesPopUp/ItemList")

#player name select variables
var enablePlayerNameSelect = false
var playerNameSelectPopedUp = false
var playerNameSelectedItem = 0 

#player select 
var enablePlayerSelectCount = []
var uiController = null

func _ready():
	for i in 15:
		playerNameList.add_item("L4igi")

func _process(delta):
	if enablePlayerNameSelect:
		handle_player_name_select()
	elif !enablePlayerSelectCount.empty():
		handle_player_select_input()
		
func handle_player_name_select():
	if playerNameSelectPopedUp:
		if Input.is_action_just_pressed(uiController.select):
			var selectedName = playerNameList.get_item_text(playerNameSelectedItem)
			print(selectedName)
		if Input.is_action_just_pressed(uiController.down):
			if playerNameSelectedItem < playerNameList.get_item_count()-1:
				playerNameSelectedItem += 1
				playerNameList.select(playerNameSelectedItem)
				playerNameList.ensure_current_is_visible()
		elif Input.is_action_just_pressed(uiController.up):
			if playerNameSelectedItem > 0:
				playerNameSelectedItem -= 1
				playerNameList.select(playerNameSelectedItem)
				playerNameList.ensure_current_is_visible()
	if Input.is_action_just_pressed(uiController.select):
		if !playerNameSelectPopedUp:
			playerNameList.select(playerNameSelectedItem)
			playerNameSelectPopedUp = true
			playerNamesPopUp.popup()
			playerNamesPopUp.rect_position = playerNameSelectAres.global_position
			var allPlayerNames = playerNamesPopUp.get_child(0).get_children()
	elif Input.is_action_just_pressed(uiController.cancel):
		playerNameSelectedItem = 0
		playerNameList.select(playerNameSelectedItem)
		playerNameList.ensure_current_is_visible()
		playerNameSelectPopedUp = false
		playerNamesPopUp.hide()
		
func handle_player_select_input():
	for control in enablePlayerSelectCount:
		if Input.is_action_just_pressed(control.select):
			uiController.toggle_player_select()
		
func disable_uiNode_movement():
	if playerNameSelectPopedUp:
		return true 
	else: 
		return false

func setup(playerName, playerNumber, uiController):
	set_player_name(playerName)
	set_player_number(playerNumber)
	self.uiController = uiController
	
func setup_hover(characterIcon, characterLogo, characterName, currentColor):
	set_icon(characterIcon, currentColor)
	set_logo(characterLogo)
	set_character_name(characterName)
	
func remove_hover():
	set_icon(null)
	set_logo(null)
	set_character_name("")
	
func set_icon(characterIcon, currentColor= null):
	self.characterIcon.set_texture(characterIcon)
	if currentColor:
		self.characterIcon.set_modulate(currentColor)
	else:
		self.characterIcon.set_modulate(Color(1,1,1,1))
		
func update_color(newColor):
	self.characterIcon.set_modulate(newColor)
	
func set_logo(characterLogo):
	self.characterLogo.set_texture(characterLogo)
	
func set_character_name(characterName):
	self.charactername.set_bbcode("[center]"+str(characterName)+"[/center]")
	
func set_player_name(playerName):
	self.playerName.set_bbcode("[center]"+str(playerName)+"[/center]")
	
func set_player_number(playerNumber):
	self.playerNumber.set_bbcode("[center]"+str(playerNumber)+"[/center]")



func _on_PlayerNameSelectArea_body_entered(body):
	if body == uiController: 
		enablePlayerNameSelect = true


func _on_PlayerNameSelectArea_body_exited(body):
	if body == uiController: 
		enablePlayerNameSelect = false

#update popupcontainer and uinode position if new charactercontainer spawns
func update_positions():
	if playerNameSelectPopedUp:
		playerNamesPopUp.rect_position = playerNameSelectAres.global_position
		uiController.global_position = playerNameSelectAres.global_position
	


func _on_PlayerNumberArea_body_entered(body):
	enablePlayerSelectCount.append(body)


func _on_PlayerNumberArea_body_exited(body):
	enablePlayerSelectCount.erase(body)
