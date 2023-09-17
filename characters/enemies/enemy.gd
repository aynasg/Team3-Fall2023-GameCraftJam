class_name Enemy
extends KinematicBody2D

signal spawn_requested(script, pos);

enum states {
	IDLE,
	MOVE,
	ATTACK
}

var direction := 1
var velocity := Vector2.ZERO

func hit():
	queue_free();
