extends VBoxContainer

func set_label(value):
	var statLabel = get_node("MarginContainer/HBoxContainer/StatLabel")
	statLabel.set_bbcode(String(value))
	
func set_value(value):
	var statValue = get_node("MarginContainer2/HBoxContainer/StatValue")
	statValue.set_bbcode(String(value))
