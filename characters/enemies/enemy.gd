class_name Enemy
extends KinematicBody2D

enum states {
	IDLE,
	FOLLOW,
	ATTACK
}

var direction := 1
var velocity := Vector2.ZERO
