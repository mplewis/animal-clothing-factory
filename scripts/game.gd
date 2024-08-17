extends Node2D

const SCREEN_WIDTH_PX = 1920
const OFF_SCREEN_DISTANCE_PX = 300
const BELT_SPEED = 20  # px/tick
const SCREEN_CENTER_X = SCREEN_WIDTH_PX / 2

@onready var current_animal: Node2D = $CurrentAnimal


func _ready():
	move_animal_to_start()


func move_animal_to_start():
	current_animal.position.x = -OFF_SCREEN_DISTANCE_PX


func _process(_delta):
	current_animal.position.x += BELT_SPEED
	if current_animal.position.x > SCREEN_WIDTH_PX + OFF_SCREEN_DISTANCE_PX:
		current_animal.position.x = -OFF_SCREEN_DISTANCE_PX
		print("Animal off screen")
