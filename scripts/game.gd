extends Node2D

enum BeltState { MOVE_ANIMAL_IN, WAITING, MOVE_ANIMAL_OUT }

const SCREEN_WIDTH_PX = 1920
const OFF_SCREEN_DISTANCE_PX = 300
const BELT_SPEED = 20  # px/tick
const SCREEN_CENTER_X = 908  # center of the screen
const CENTER_WAIT_SEC = 3.0  # seconds to wait in the middle

var belt_state: BeltState = BeltState.MOVE_ANIMAL_IN
var stop_waiting_at: float = 0

@onready var current_animal: Node2D = $CurrentAnimal
@onready var alpaca_shirt: Node2D = $AlpacaShirt


func _ready():
	set_animal_to_start()


func set_animal_to_start():
	current_animal.position.x = -OFF_SCREEN_DISTANCE_PX
	belt_state = BeltState.MOVE_ANIMAL_IN
	print("-> in")


func move_animal_on_belt():
	match belt_state:
		BeltState.MOVE_ANIMAL_IN:
			current_animal.position.x += BELT_SPEED
			if current_animal.position.x > SCREEN_CENTER_X:
				print("-> waiting")
				belt_state = BeltState.WAITING
				stop_waiting_at = Time.get_ticks_msec() + CENTER_WAIT_SEC * 1000

		BeltState.WAITING:
			if Time.get_ticks_msec() > stop_waiting_at:
				print("-> out")
				belt_state = BeltState.MOVE_ANIMAL_OUT

		BeltState.MOVE_ANIMAL_OUT:
			current_animal.position.x += BELT_SPEED
			if current_animal.position.x > SCREEN_WIDTH_PX + OFF_SCREEN_DISTANCE_PX:
				set_animal_to_start()


func _process(_delta):
	move_animal_on_belt()
