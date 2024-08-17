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
var resizing: bool = false
var score: int = 0

@onready var current_animal: Node2D = $CurrentAnimal
@onready var current_clothing: Node2D = $CurrentClothing
@onready var grow_tool: Node2D = $GrowTool
@onready var shrink_tool: Node2D = $ShrinkTool
@onready var score_label: Label = $UI/StarLabel/ScoreLabel


func _ready():
	set_animal_to_start()


func set_animal_to_start():
	current_animal.position.x = -OFF_SCREEN_DISTANCE_PX
	belt_state = BeltState.MOVE_ANIMAL_IN
	reset_clothing()


func reset_clothing():
	current_clothing.scale = Vector2(1, 1)


func incr_score(points: int):
	score += points
	score_label.text = str(score)


func move_animal_on_belt():
	match belt_state:
		BeltState.MOVE_ANIMAL_IN:
			current_animal.position.x += BELT_SPEED
			if current_animal.position.x > SCREEN_CENTER_X:
				belt_state = BeltState.WAITING

		BeltState.WAITING:
			pass

		BeltState.MOVE_ANIMAL_OUT:
			current_animal.position.x += BELT_SPEED
			if current_animal.position.x > SCREEN_WIDTH_PX + OFF_SCREEN_DISTANCE_PX:
				set_animal_to_start()


func grow_shrink_clothing():
	if belt_state != BeltState.WAITING:
		return

	var grow = Input.is_action_pressed("ui_grow")
	var shrink = Input.is_action_pressed("ui_shrink")

	if grow && !shrink:
		resizing = true
		if current_clothing.scale.x >= CLOTHING_MAX_SCALE:
			grow = false  # stop at max
		else:
			current_clothing.scale += Vector2(GROW_SHRINK_RATE, GROW_SHRINK_RATE)
			grow_tool.rotation_degrees = randf_range(-GROW_SHAKE_MAX_ROT, GROW_SHAKE_MAX_ROT)

	if shrink && !grow:
		resizing = true
		if current_clothing.scale.x <= CLOTHING_MIN_SCALE:
			shrink = false  # stop at min
		else:
			current_clothing.scale -= Vector2(GROW_SHRINK_RATE, GROW_SHRINK_RATE)
			shrink_tool.rotation_degrees = randf_range(-GROW_SHAKE_MAX_ROT, GROW_SHAKE_MAX_ROT)

	if resizing && !grow && !shrink:  # player released the key
		resizing = false
		grow_tool.rotation_degrees = 0
		shrink_tool.rotation_degrees = 0
		belt_state = BeltState.MOVE_ANIMAL_OUT
		incr_score(1)


func _process(_delta):
	move_animal_on_belt()
	grow_shrink_clothing()
