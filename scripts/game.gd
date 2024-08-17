extends Node2D

enum BeltState { MOVE_ANIMAL_IN, WAITING, MOVE_ANIMAL_OUT }

const SCREEN_WIDTH_PX = 1920
const OFF_SCREEN_DISTANCE_PX = 300
const BELT_SPEED = 20  # px/tick
const SCREEN_CENTER_X = SCREEN_WIDTH_PX * 1.0 / 2
const CENTER_WAIT_SEC = 3.0  # seconds to wait in the middle
const GROW_SHRINK_RATE = 0.02  # scale factor per tick
const GROW_SHAKE_MAX_ROT = 10  # degrees in either direction to wiggle the tool
const CLOTHING_MAX_SCALE = 2.0
const CLOTHING_MIN_SCALE = 0.5

var belt_state: BeltState = BeltState.MOVE_ANIMAL_IN
var stop_waiting_at: float = 0

@onready var current_animal: Node2D = $CurrentAnimal
@onready var current_clothing: Node2D = $CurrentClothing
@onready var grow_tool: Node2D = $GrowTool
@onready var shrink_tool: Node2D = $ShrinkTool


func _ready():
	set_animal_to_start()


func set_animal_to_start():
	current_animal.position.x = -OFF_SCREEN_DISTANCE_PX
	belt_state = BeltState.MOVE_ANIMAL_IN


func move_animal_on_belt():
	match belt_state:
		BeltState.MOVE_ANIMAL_IN:
			current_animal.position.x += BELT_SPEED
			if current_animal.position.x > SCREEN_CENTER_X:
				belt_state = BeltState.WAITING
				stop_waiting_at = Time.get_ticks_msec() + CENTER_WAIT_SEC * 1000

		BeltState.WAITING:
			if Time.get_ticks_msec() > stop_waiting_at:
				belt_state = BeltState.MOVE_ANIMAL_OUT

		BeltState.MOVE_ANIMAL_OUT:
			current_animal.position.x += BELT_SPEED
			if current_animal.position.x > SCREEN_WIDTH_PX + OFF_SCREEN_DISTANCE_PX:
				set_animal_to_start()


func grow_shrink_clothing():
	if Input.is_action_pressed("ui_grow"):
		if current_clothing.scale.x < CLOTHING_MAX_SCALE:
			current_clothing.scale += Vector2(GROW_SHRINK_RATE, GROW_SHRINK_RATE)
			grow_tool.rotation_degrees = randf_range(-GROW_SHAKE_MAX_ROT, GROW_SHAKE_MAX_ROT)
	else:
		grow_tool.rotation_degrees = 0

	if Input.is_action_pressed("ui_shrink"):
		if current_clothing.scale.x > CLOTHING_MIN_SCALE:
			current_clothing.scale -= Vector2(GROW_SHRINK_RATE, GROW_SHRINK_RATE)
			shrink_tool.rotation_degrees = randf_range(-GROW_SHAKE_MAX_ROT, GROW_SHAKE_MAX_ROT)
		else:
			shrink_tool.rotation_degrees = 0


func _process(_delta):
	move_animal_on_belt()
	grow_shrink_clothing()
