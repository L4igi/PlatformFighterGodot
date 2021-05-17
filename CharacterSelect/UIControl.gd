extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var up = null
var down = null
var left = null
var right = null
var select = null
var cancel = null
var selectSkinFw = null
var selectSkinBw = null

var velocity = Vector2.ZERO
var acceleration = 10
var stopForce = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	setup_controls(Globals.controlsP1)
	
func setup_controls(controls):
	up = controls.get("up")
	down = controls.get("down")
	left = controls.get("left")
	right = controls.get("right")
	select = controls.get("attack")
	cancel = controls.get("special")
	selectSkinFw = controls.get("shield")
	selectSkinBw = controls.get("grab")

func handle_input():
	if Input.is_action_just_pressed(left):
		pass
	if Input.is_action_just_pressed(right):
		pass
	if Input.is_action_just_pressed(up):
		pass
	if Input.is_action_just_pressed(down):
		pass
	if Input.is_action_just_pressed(select):
		call_deferred("click_the_left_mouse_button")
	elif Input.is_action_just_pressed(cancel):
		pass
	if Input.is_action_just_pressed(selectSkinFw):
		pass
	elif Input.is_action_just_pressed(selectSkinBw):
		pass
		
func _input(event):
   # Mouse in viewport coordinates.
   if event is InputEventMouseButton:
	   print("Mouse Click/Unclick at: ", event.position)
#   elif event is InputEventMouseMotion:
#	   print("Mouse Motion at: ", event.position)

func click_the_left_mouse_button():
	var evt = InputEventMouseButton.new()
	evt.button_index = BUTTON_LEFT
#	evt.set_position(self.position)
	#get screen pixels not covered by game
	var screenSizeModifier = OS.get_screen_size() - get_viewport().get_size()
	#get value by which game is scaled up
	screenSizeModifier /= get_viewport().get_size()/get_viewport().get_visible_rect().size
	evt.set_position((get_viewport_transform() * get_global_transform() * (self.position+screenSizeModifier))/2)
	evt.pressed = true
	get_tree().input_event(evt)
	evt.pressed = false
	get_tree().input_event(evt)

func handle_control_physics(_delta):
	var xInput = get_input_direction_x()
	var yInput = get_input_direction_y()
	if xInput == 0 && yInput == 0:
		velocity = Vector2.ZERO
	velocity = Vector2(acceleration * xInput, acceleration * yInput) 
	move_and_collide(velocity)

func _physics_process(_delta):
	handle_input()
	handle_control_physics(_delta)
	
func get_input_direction_x():
	return Input.get_action_strength(right) - Input.get_action_strength(left)
	
func get_input_direction_y():
	return Input.get_action_strength(down) - Input.get_action_strength(up)
