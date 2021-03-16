extends Node

signal timeout(timerType)

var frames = 0
var pauseDuration = 0
var pausedTimer = false
var timerStarted = false
var timerType = null
var character = null

func _init(timerType, character):
	character.add_child(self)
	self.character = character
	self.timerType = timerType
	self.connect("timeout", character, "_on_frametimer_timeout")

func set_frames(frames):
	self.frames = frames
	
func start_timer():
	timerStarted = true
	character.frameTimerManager.add_timer(self)
	
func pause_timer(pause, duration = 0):
	pauseDuration = duration
	pausedTimer = true
	
func stop_timer():
	frames = 0
	timerStarted = false
	character.frameTimerManager.remove_timer(self)
	
func get_frames_left():
	return frames
	
func timer_running(): 
	if frames > 0: 
		return true
	else: 
		return false
