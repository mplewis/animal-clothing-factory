class_name Menu
extends Node2D

## The slider to control sound volume
@export var volume_sound_slider: HSlider
## The slider to control music volume
@export var volume_music_slider: HSlider
## The slider to control ambience volume
@export var volume_ambience_slider: HSlider

## The button to show the game's credits
@onready var credits_btn: LinkButton = $CreditsLink
## The credits modal
@onready var credits_modal: Control = $CreditsModal

@onready var sfx_bus = AudioServer.get_bus_index("sfx")
@onready var music_bus = AudioServer.get_bus_index("music")
@onready var ambience_bus = AudioServer.get_bus_index("ambience")


func _ready() -> void:
	volume_sound_slider.value_changed.connect(_on_sound_changed)
	volume_music_slider.value_changed.connect(_on_music_changed)
	volume_ambience_slider.value_changed.connect(_on_sound_changed)

	volume_sound_slider.value = AudioServer.get_bus_volume_db(sfx_bus)
	volume_music_slider.value = AudioServer.get_bus_volume_db(music_bus)
	volume_ambience_slider.value = AudioServer.get_bus_volume_db(ambience_bus)

	credits_btn.pressed.connect(_on_credits_pressed)


func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_select"):
		get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_sound_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus, value)


func _on_music_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, value)


func _on_ambience_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(ambience_bus, value)


func _on_credits_pressed() -> void:
	credits_modal.show()

func _on_credits_modal_go_back_requested() -> void:
	credits_modal.hide()
