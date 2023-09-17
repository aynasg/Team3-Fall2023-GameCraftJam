extends Node2D

signal boss_fight
signal phase
# PhaseTimer waits for a certain amount of time and then changes|
# the current phase we are on.
onready var PhaseTimer := $PhaseTimer
onready var PauseMenu := $PauseMenuPopup

func _ready():
	# Everytime we reload the world, we need to reset the current
	# phase back to 1 by going to the next phase, emit phase1
	Game.current_phase = 0
	next_phase()
	
	# PhaseTimer Setup
	PhaseTimer.wait_time = Game.TIME_UNTIL_BOSS_ARRIVAL / Game.MAX_PHASES
	PhaseTimer.connect("timeout", self, "next_phase")
	PhaseTimer.start()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		PauseMenu.visible = true
		get_tree().paused = true


func next_phase():
	# Change Phase
	Game.current_phase += 1
	if Game.current_phase > Game.MAX_PHASES:
		PhaseTimer.stop()
		emit_signal("boss_fight")
		return
	print("starting phase %s" % Game.current_phase)
	
	emit_signal("phase", [Game.current_phase])
