extends Node2D

enum PlayState { MOVE_ANIMAL_IN, SIZING_CLOTHING, WEARING_CLOTHING, MOVE_ANIMAL_OUT }

## Width of the game window, in pixels
const SCREEN_WIDTH_PX = 1920
## How far off-screen to start/end the animal motion, in pixels
const OFF_SCREEN_DISTANCE_PX = 300
## Speed of belt that moves animals in/out, in px/tick
const BELT_SPEED = 20
## The X coord for the center of the screen. This is where the animal stops.
const SCREEN_CENTER_X = SCREEN_WIDTH_PX * 1.0 / 2
## How fast to grow/shrink clothing when the player holds the button
const GROW_SHRINK_RATE = 0.02
## degrees in either direction to wiggle the tool during a grow/shrink operation
const GROW_SHAKE_MAX_ROT = 10
## Max scale of clothing when growing
const CLOTHING_MAX_SCALE = 2.0
## Min scale of clothing when shrinking
const CLOTHING_MIN_SCALE = 0.5

## The current state of the interactive player elements
var play_state: PlayState = PlayState.MOVE_ANIMAL_IN
## If true, the player is currently holding down a "resize" key
var resizing: bool = false
## The player's score
var score: int = 0

## The current animal to dress
@onready var current_animal: Node2D = $CurrentAnimal
## Where the shirt sits on the alpaca
@onready var alpaca_clothing_anchor: Node2D = $CurrentAnimal/Alpaca/ClothingAnchor
## Where clothing sits during sizing
@onready var new_clothing_anchor: Node2D = $NewClothingAnchor
## The current clothing to resize
@onready var current_clothing: Node2D = $CurrentClothing
## The tool used to grow clothing
@onready var grow_tool: Node2D = $GrowTool
## The tool used to shrink clothing
@onready var shrink_tool: Node2D = $ShrinkTool
## The label showing the player's score
@onready var score_label: Label = $UI/StarLabel/ScoreLabel


func _ready():
	set_animal_to_start()


func set_animal_to_start():
	current_animal.position.x = -OFF_SCREEN_DISTANCE_PX
	play_state = PlayState.MOVE_ANIMAL_IN
	reset_clothing()


func reset_clothing():
	current_clothing.scale = Vector2(1, 1)
	current_clothing.position = new_clothing_anchor.position


func incr_score(points: int):
	score += points
	score_label.text = str(score)


func move_animal_on_belt():
	match play_state:
		PlayState.MOVE_ANIMAL_IN:
			if %BeltSound.playing == false:
				%BeltSound.play()
			current_animal.position.x += BELT_SPEED
			if current_animal.position.x > SCREEN_CENTER_X:
				%BeltSound.stop()
				play_state = PlayState.SIZING_CLOTHING

		PlayState.MOVE_ANIMAL_OUT:
			if %BeltSound.playing == false:
				%BeltSound.play()
			current_animal.position.x += BELT_SPEED
			if current_animal.position.x > SCREEN_WIDTH_PX + OFF_SCREEN_DISTANCE_PX:
				set_animal_to_start()


func grow_shrink_clothing():
	if play_state != PlayState.SIZING_CLOTHING:
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
		play_state = PlayState.WEARING_CLOTHING
		incr_score(1)


func wear_clothing():
	if play_state == PlayState.WEARING_CLOTHING:
		var goal = alpaca_clothing_anchor.global_position
		current_clothing.position = current_clothing.position.lerp(goal, 0.1)
		if current_clothing.position.distance_to(goal) < 1:
			play_state = PlayState.MOVE_ANIMAL_OUT

	elif play_state == PlayState.MOVE_ANIMAL_OUT:
		current_clothing.position = alpaca_clothing_anchor.global_position


func _process(_delta):
	move_animal_on_belt()
	grow_shrink_clothing()
	wear_clothing()
