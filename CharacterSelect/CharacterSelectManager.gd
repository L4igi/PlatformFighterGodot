extends Node2D

onready var uiControl = preload("res://CharacterSelect/UIControl.tscn")

var setupControls = []

func _ready():
	setupControls.append(Globals.controlsP1)
	setupControls.append(Globals.controlsP2)
	
func _input(event):
	check_action_event(event)

func process():
	pass

func check_action_event(event):
	var currentControl = 0
	for control in setupControls:
		for input in control.values():
			if event.is_action(input):
				setupControls.erase(control)
				spawn_uiControl(control)
				return
		currentControl += 1

func spawn_uiControl(control):
	var newUiControl = uiControl.instance()
	newUiControl.setup(control)
	add_child(newUiControl)
