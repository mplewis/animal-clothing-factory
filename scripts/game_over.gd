class_name GameOver
extends Node2D

## The label showing the full game over message
@onready var label: Label = $Label


func _ready() -> void:
	label.text = message(Global.score)


func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_select"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")


## Build the game over message from the given score
func message(score: int) -> String:
	return "Game over\nScore: %d\n\nPress SPACE to continue" % score
