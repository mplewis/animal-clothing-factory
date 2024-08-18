class_name Game
extends Node2D

enum PlayState { MOVE_ANIMAL_IN, SIZING_CLOTHING, WEARING_CLOTHING, MOVE_ANIMAL_OUT }

## Width of the game window, in pixels
const SCREEN_WIDTH_PX := 1920
## How far off-screen to start/end the animal motion, in pixels
const OFF_SCREEN_DISTANCE_PX := 300
## Speed of belt that moves animals in/out, in px/tick
const BELT_SPEED := 20
## The X coord for the center of the screen. This is where the animal stops.
const SCREEN_CENTER_X := SCREEN_WIDTH_PX * 1.0 / 2

## How long the game lasts, in seconds
const GAME_DURATION_SECS = 45

## How fast to grow/shrink clothing when the player holds the button
const GROW_SHRINK_RATE := 0.01
## degrees in either direction to wiggle the tool during a grow/shrink operation
const GROW_SHAKE_MAX_ROT := 10

## Max scale of clothing when growing
const CLOTHING_MAX_SCALE := 2.0
## Min scale of clothing when shrinking
const CLOTHING_MIN_SCALE := 0.5
## The perfectly-sized clothing scale
const CLOTHING_PERFECT_SCALE := 0.66

## How fast the feedback label floats up
const FEEDBACK_RISE_SPEED := 2
## How fast the feedback label fades out
const FEEDBACK_FADE_SPEED := 0.02

## The time remaining in the game
var time_remaining_secs := GAME_DURATION_SECS
## The current state of the interactive player elements
var play_state := PlayState.MOVE_ANIMAL_IN
## If true, the player is currently holding down a "resize" key
var resizing := false

## The current animal to dress
@onready var current_animal: Node2D = $Gameplay/CurrentAnimal
## Where the shirt sits on the alpaca
@onready var alpaca_clothing_anchor: Node2D = $Gameplay/CurrentAnimal/Alpaca/ClothingAnchor
## The current clothing to resize
@onready var current_clothing: Node2D = $Gameplay/CurrentClothing

## The tool used to grow clothing
@onready var grow_tool: Node2D = $Gameplay/GrowTool
## The tool used to shrink clothing
@onready var shrink_tool: Node2D = $Gameplay/ShrinkTool

## The label showing the time remaining in the game
@onready var timer_label: Label = $UI/ClockLabel/TimerLabel
## The label showing the player's score
@onready var score_label: Label = $UI/StarLabel/ScoreLabel

## The label giving the player scoring feedback (text)
@onready var feedback_label: Label = $UI/FeedbackLabel
## The label giving the player scoring feedback (stars)
@onready var feedback_stars_label: Label = $UI/FeedbackLabel/StarsLabel

## The label indicating the key for Grow
@onready var grow_label: Label = $UI/HintGrow/KeyLabel
## The label indicating the key for Shrink
@onready var shrink_label: Label = $UI/HintShrink/KeyLabel

## The sound of the belt moving
@onready var belt_move_sound: AudioStreamPlayer2D = $Audio/BeltMove
## The sound of the score feedback SFX for Bad
@onready var score_bad_sound: AudioStreamPlayer2D = $Audio/Score/Bad
## The sound of the score feedback SFX for OK
@onready var score_ok_sound: AudioStreamPlayer2D = $Audio/Score/OK
## The sound of the score feedback SFX for Good
@onready var score_good_sound: AudioStreamPlayer2D = $Audio/Score/Good
## The sound of the score feedback SFX for Great
@onready var score_great_sound: AudioStreamPlayer2D = $Audio/Score/Great

## The initial position of the feedback label
@onready var feedback_label_start_position: Vector2 = feedback_label.position
## The position where new clothing should be placed
@onready var new_clothing_position: Vector2 = current_clothing.position
## The timer that ticks once a second
@onready var timer: Timer = $SecTimer


func _ready() -> void:
	set_animal_to_start()
	set_hints()
	timer_label.text = str(time_remaining_secs)
	timer.timeout.connect(_on_sec_tick)


func _process(_delta) -> void:
	move_animal_on_belt()
	grow_shrink_clothing()
	wear_clothing()
	move_and_fade_feedback()


## Tick the timer down every second
func _on_sec_tick() -> void:
	time_remaining_secs -= 1
	timer_label.text = str(time_remaining_secs)
	if time_remaining_secs <= 0:
		timer.stop()
		end_game()


## Game over - load the Game Over scene
func end_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")


## Move the animal off-screen to the left to get them ready to get dressed.
func set_animal_to_start() -> void:
	current_animal.position.x = -OFF_SCREEN_DISTANCE_PX
	play_state = PlayState.MOVE_ANIMAL_IN
	reset_clothing()


## Get the human-readable key label for the given action
func label_for_action(action: String) -> String:
	var event := InputMap.action_get_events(action)[0]
	var label := DisplayServer.keyboard_get_label_from_physical(event.physical_keycode)
	var kc_str := OS.get_keycode_string(label)
	if kc_str == "Slash":
		return "/"
	return kc_str


## Set the hint labels to show the correct keys for the grow and shrink tools
func set_hints() -> void:
	grow_label.text = label_for_action("ui_grow")
	shrink_label.text = label_for_action("ui_shrink")


## Reset the current piece of clothing to sit in the grabber arm.
func reset_clothing() -> void:
	current_clothing.scale = Vector2(1, 1)
	current_clothing.position = new_clothing_position


## Increment the player's score by the given number of points.
func incr_score(points: int) -> void:
	Global.score += points
	score_label.text = str(Global.score)


## Move the animal along the belt if necessary.
func move_animal_on_belt() -> void:
	match play_state:
		PlayState.MOVE_ANIMAL_IN:
			if belt_move_sound.playing == false:
				belt_move_sound.play()
			current_animal.position.x += BELT_SPEED
			if current_animal.position.x > SCREEN_CENTER_X:
				belt_move_sound.stop()
				play_state = PlayState.SIZING_CLOTHING

		PlayState.MOVE_ANIMAL_OUT:
			if belt_move_sound.playing == false:
				belt_move_sound.play()
			current_animal.position.x += BELT_SPEED
			if current_animal.position.x > SCREEN_WIDTH_PX + OFF_SCREEN_DISTANCE_PX:
				set_animal_to_start()


## Score the player's clothing sizing and move the animal to the right.
func score_and_exit() -> void:
	var piece_scale = current_clothing.scale.x

	# piece score = % away from perfect
	var piece_score = abs(CLOTHING_PERFECT_SCALE - piece_scale) / CLOTHING_PERFECT_SCALE

	var stars = 0
	if piece_score < 0.1:
		stars = 5
	elif piece_score < 0.2:
		stars = 3
	elif piece_score < 0.3:
		stars = 1

	show_feedback(stars)
	incr_score(stars)
	play_state = PlayState.MOVE_ANIMAL_OUT


## Indicate to the player how many stars they earned.
func show_feedback(stars) -> void:
	var feedback := "Try again..."
	var sfx := score_bad_sound
	match stars:
		5:
			feedback = "Perfect!!"
			sfx = score_great_sound
		3:
			feedback = "Great!"
			sfx = score_good_sound
		1:
			feedback = "Just OK"
			sfx = score_ok_sound
	feedback_label.text = feedback
	var star_s = ""
	for i in range(stars):
		star_s += "⭐️"
	feedback_stars_label.text = star_s
	feedback_label.visible = true
	sfx.play()


## Move the feedback label up and fade it out, if it's currently visible.
func move_and_fade_feedback() -> void:
	if !feedback_label.visible:
		return

	feedback_label.position.y -= FEEDBACK_RISE_SPEED
	feedback_label.modulate.a -= FEEDBACK_FADE_SPEED

	if feedback_label.modulate.a <= 0:
		feedback_label.visible = false
		feedback_label.position = feedback_label_start_position
		feedback_label.modulate.a = 1.0


## Handle the player growing or shrinking the clothing by holding down the button.
func grow_shrink_clothing() -> void:
	if play_state != PlayState.SIZING_CLOTHING:
		return

	var grow = Input.is_action_pressed("ui_grow")
	var shrink = Input.is_action_pressed("ui_shrink")

	if grow && !shrink:
		resizing = true
		if %GrowSound.playing == false:
			%GrowSound.play()
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
		%GrowSound.stop()
		resizing = false
		grow_tool.rotation_degrees = 0
		shrink_tool.rotation_degrees = 0
		play_state = PlayState.WEARING_CLOTHING


## Move the resized clothing onto the animal.
func wear_clothing() -> void:
	if play_state == PlayState.WEARING_CLOTHING:
		var goal = alpaca_clothing_anchor.global_position
		current_clothing.position = current_clothing.position.lerp(goal, 0.1)
		if current_clothing.position.distance_to(goal) < 1:
			score_and_exit()

	elif play_state == PlayState.MOVE_ANIMAL_OUT:
		current_clothing.position = alpaca_clothing_anchor.global_position
