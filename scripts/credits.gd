class_name Credits
extends Control

signal go_back_requested


func _ready():
	%CreditsLink.pressed.connect(_on_go_back_pressed)


func _on_go_back_pressed():
	go_back_requested.emit()
