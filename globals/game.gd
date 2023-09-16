extends Node

const MAX_PHASES = 5
const TIME_UNTIL_BOSS_ARRIVAL = MAX_PHASES * 60
var current_phase := 1

var player_position := Vector2.ZERO
