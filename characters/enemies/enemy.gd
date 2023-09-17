class_name Enemy
extends KinematicBody2D

enum states {
	IDLE,
	MOVE,
	ATTACK
}

var direction := 1
var velocity := Vector2.ZERO

