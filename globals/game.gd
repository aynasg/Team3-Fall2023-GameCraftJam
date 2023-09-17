extends Node

const TIME_BETWEEEN_PHASES = 5;
const TIME_UNTIL_BOSS_ARRIVAL = 300;
const MAX_PHASES = TIME_UNTIL_BOSS_ARRIVAL/TIME_BETWEEEN_PHASES;
var current_phase := 1

var player_position := Vector2.ZERO

class EnemyTypes:
	const BASIC_SKELETON = preload("res://characters/enemies/ground/basic.tscn");
