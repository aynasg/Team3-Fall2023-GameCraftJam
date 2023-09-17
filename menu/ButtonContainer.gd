extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#highlights start button so that either mouse or keyboard can be used to select
func _ready():
	$Start.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#load world when the start button is pressed
func _on_Start_pressed():
	get_tree().change_scene("res://world/world.tscn")

#exit game when quit button is pressed
func _on_Quit_pressed():
	get_tree().quit()


func _on_Credits_pressed():
	var creditsPopup = get_node("../CreditsPopup")
	creditsPopup.popup()

