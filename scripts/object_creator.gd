extends Node

class_name ObjectCreator

## The animals that this instance can create
@export var PossibleAnimals: Array[PackedScene]


func _ready() -> void:
	# var animal = self.create_random_animal()
	# animal.position.x = 500
	# animal.position.y = 500
	pass  # Replace with function body.


func _process(_delta: float) -> void:
	pass


func create_random_animal() -> Animal:
	var animal_scene = PossibleAnimals.pick_random()
	var animal = animal_scene.instantiate()
	add_child(animal)
	return animal


func create_random_clothing(animal: Animal) -> Clothing:
	var clothing_scene = animal.PossibleClothing.pick_random()
	var clothing = clothing_scene.instantiate()
	add_child(clothing)
	return clothing
