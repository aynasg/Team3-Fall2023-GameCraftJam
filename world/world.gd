extends Node2D

onready var PhaseTimer := $PhaseTimer

func _ready():
	PhaseTimer.wait_time = 0
