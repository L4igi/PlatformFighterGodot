extends MarginContainer

var character = null
var currentStep = 0
var enableInput = false
var resultScreenUI = null

func setup(character):
	self.character = character
	set_base_stats()
	set_advanced_stats()
	
	
func _process(delta):
	if enableInput:
		if Input.is_action_just_pressed(character.attack):
			advance_menu(currentStep)
		elif Input.is_action_just_pressed(character.special):
			revert_menu(currentStep)
		if currentStep == 2:
			if Input.is_action_pressed(character.down):
				scroll_down()
			if Input.is_action_pressed(character.up):
				scroll_up()

func advance_menu(step = 0):
	match step: 
		0: 
			get_node("CharacterInfo").move_child(get_node("CharacterInfo/CharPlayerInfo"),0)
			get_node("BaseResults").set_visible(true)
			currentStep += 1
		1:
			get_node("BaseResults").set_visible(false)
			get_node("ExtendedResults").set_visible(true)
			currentStep += 1
		2:
			get_node("ExtendedResults").set_visible(false)
			get_node("ReadyContainer").set_visible(true)
			get_node("BGContainer/BG2").set_visible(false)
			get_node("CharacterInfo").set_visible(false)
			resultScreenUI = get_parent()
			resultScreenUI.ready_next_battle(character)
			currentStep += 1
			
func revert_menu(step = 0):
	match step: 
		0:
			pass
		1:
			get_node("CharacterInfo").move_child(get_node("CharacterInfo/CharPlayerInfo"),1)
			get_node("BaseResults").set_visible(false)
			currentStep -= 1
		2:
			get_node("BaseResults").set_visible(true)
			get_node("ExtendedResults").set_visible(false)
			currentStep -= 1
		3:
			get_node("ExtendedResults").set_visible(true)
			get_node("ReadyContainer").set_visible(false)
			get_node("BGContainer/BG2").set_visible(true)
			get_node("CharacterInfo").set_visible(true)
			resultScreenUI = get_parent()
			resultScreenUI.not_ready_next_battle(character)
			currentStep -= 1
	
func scroll_up():
	var scrollContainer = get_node("ExtendedResults/ScrollContainer")
	scrollContainer.set_v_scroll(scrollContainer.get_v_scroll()-8)
	
func scroll_down():
	var scrollContainer = get_node("ExtendedResults/ScrollContainer")
	scrollContainer.set_v_scroll(scrollContainer.get_v_scroll()+8)
#	get_node("ExtendedResults/ScrollContainer").update()

func set_base_stats():
	var outAtValue = get_node("BaseResults/VBoxContainer/MarginContainer/HBoxContainer/OutAtValue")
	outAtValue.set_bbcode("[center]" + str(character.resultData.statDictionary.get("characterOutAt")) +"[/center]")
	var baseStatContainer = get_node("BaseResults/VBoxContainer/MarginContainer2/BaseStatsContainer")
	var statNodes = baseStatContainer.get_children()
	var step = 0
	for node in statNodes:
		if node.is_in_group("StatContainer"):
			var textLables = node.get_children()
			match step:
				0:
					textLables[1].set_bbcode("[center]" + str(character.resultData.statDictionary.get("kos")) +"[/center]")
					step += 1
				1:
					textLables[1].set_bbcode("[center]" + str(character.resultData.statDictionary.get("falls")) +"[/center]")
					step += 1
				2:
					textLables[1].set_bbcode("[center]" + str(character.resultData.statDictionary.get("sds")) +"[/center]")
					step += 1
					pass

func set_advanced_stats():
	var advancedStatsList = get_node("ExtendedResults/ScrollContainer/AdvancedStatsList")
	var advancedStatsContainer = preload("res://Results/AdvancedStatContainer.tscn")
	for stat in character.resultData.statDictionary:
		var newAdvancedStatsContainer = advancedStatsContainer.instance()
		newAdvancedStatsContainer.set_label(stat)
		newAdvancedStatsContainer.set_value(character.resultData.statDictionary.get(stat))
		advancedStatsList.add_child(newAdvancedStatsContainer)
		
