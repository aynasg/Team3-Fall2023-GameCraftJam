class_name Enemy
extends KinematicBody2D

signal spawn_requested(script, pos);

enum states {
	IDLE,
	MOVE,
	ATTACK
}

onready var EffectsPlayer := $Effects

export var max_health := 5
var health := max_health

var direction := 1
var velocity := Vector2.ZERO

func hit(amount):
	EffectsPlayer.play("hit")
	health -= amount
	if health <= 0:
		queue_free()
