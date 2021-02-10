extends Node

signal timeout()

var frames = 0
var pauseDuration = 0
var pausedTimer = false
var timerStarted = false

func _physics_process(delta):
	if timerStarted && frames > 0 && !pausedTimer: 
		frames -= 1
		print(self.name + " : " + str(frames))
	elif pausedTimer && pauseDuration > 0: 
		pauseDuration -= 1
		if pauseDuration == 0: 
			pausedTimer = false
	elif frames == 0 && timerStarted: 
		timerStarted = false
		emit_signal("timeout")
	
func set_frames(frames):
	self.frames = frames
	
func start_timer():
	timerStarted = true
	
func pause_timer(pause, duration = 0):
	pauseDuration = duration
	pausedTimer = true
	
func stop_timer():
	frames = 0
	timerStarted = false
	
func get_frames_left():
	return frames
	
func timer_running(): 
	if frames > 0: 
		return true
	else: 
		return false
