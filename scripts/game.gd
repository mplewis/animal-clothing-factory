class_name Game
extends Node2D

enum PlayState { MOVE_ANIMAL_IN, SIZING_CLOTHING, GETTING_DRESSED, MOVE_ANIMAL_OUT }

## Width of the game window, in pixels
const SCREEN_WIDTH_PX := 1920
## How far off-screen to start/end the animal motion, in pixels
const OFF_SCREEN_ANIMAL_DISTANCE_PX := 300
## How far off-screen to start/end the grabber arm, in pixels. Must be large enough to handle tall items of clothing.
const OFF_SCREEN_GRABBER_DISTANCE_PX := 500
## Speed of belt that moves animals in/out, in px/tick
const BELT_SPEED := 20
## Speed of grabber arm moving up/down, in px/tick. Must be fast enough to load the clothing before the belt stops.
const GRABBER_SPEED := 20
## How long to wait for the animal to wear the clothing before moving them along
const GETTING_DRESSED_DELAY_SEC := 0.4
## The X coord for the center of the screen. This is where the animal stops.
const SCREEN_CENTER_X := SCREEN_WIDTH_PX * 1.0 / 2

## How fast to grow/shrink clothing when the player holds the button
const GROW_SHRINK_RATE := 0.01
## degrees in either direction to wiggle the tool during a grow/shrink operation
const GROW_SHAKE_MAX_ROT := 10

## Max scale of clothing when growing
const CLOTHING_MAX_SCALE := 2.0
## Min scale of clothing when shrinking
const CLOTHING_MIN_SCALE := 0.2

## How fast the feedback label floats up
const FEEDBACK_RISE_SPEED := 2
## How fast the feedback label fades out
const FEEDBACK_FADE_SPEED := 0.01

## Emitted when the player starts using the shrink tool
signal shrink_sound_start
## Emitted when the player stops using the shrink tool
signal shrink_sound_stop

## The position where new clothing should be placed
@export var new_clothing_anchor_node: Node2D
## The object creator that makes new animals and clothing
@export var object_creator: ObjectCreator
## The Y level of the belt surface, where animals stand
@export var belt_height: Node2D

# TODO: Implement game over screen in this screen
@export var dressed_animal_anchor: Node2D

## How long the game lasts, in seconds
@export var GAME_DURATION_SECS: float = 45

## The time remaining in the game
@onready var time_remaining_secs := GAME_DURATION_SECS
## The current state of the interactive player elements
var play_state := PlayState.MOVE_ANIMAL_IN
## If true, the player is currently holding down a "resize" key
var resizing := false
## When to allow the animal to move after dressing them
var move_animal_at := 0

## Stores all the animals that we've dressed so we can show them in the end screen
var dressed_animals: Array[Animal] = []

## The current animal to dress
@onready var current_animal: Animal
## The current clothing to resize
@onready var current_clothing: Clothing

## The grabber arm that holds clothing
@onready var grabber: Node2D = $Gameplay/Grabber
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
## The sound of the grow ray firing
@onready var grow_sound: AudioStreamPlayer2D = $Audio/Grow
## the sound of the claw going down
@onready var claw_down_sound: AudioStreamPlayer2D = $Audio/ClawDown
## the sound of the claw going up
@onready var claw_up_sound: AudioStreamPlayer2D = $Audio/ClawUp
## clothing foley sound
@onready var clothing_sound: AudioStreamPlayer = $Audio/Clothing

# TODO: Add 2d spatial sound for belt, grow, shrink

## The initial position of the feedback label
@onready var feedback_label_start_position: Vector2 = feedback_label.position
## The initial position of the grabber arm
@onready var grabber_start_position: Vector2 = grabber.position
## The timer that ticks once a second
@onready var timer: Timer = $SecTimer


func _ready() -> void:
	Global.score = 0
	set_animal_to_start()
	set_hints()
	timer_label.text = str(time_remaining_secs)
	timer.timeout.connect(_on_sec_tick)


func _process(_delta) -> void:
	check_exit()
	move_animal_on_belt()
	move_grabber_arm()
	grow_shrink_clothing()
	wait_to_wear_clothing()
	move_and_fade_feedback()


## Tick the timer down every second
func _on_sec_tick() -> void:
	time_remaining_secs -= 1
	timer_label.text = str(time_remaining_secs)
	if time_remaining_secs <= 0:
		timer.stop()
		end_game()


## Check if the player wants to exit the game
func check_exit() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")


## Game over - load the Game Over scene
func end_game() -> void:
	# TODO: Implement game over screen in this screen
	# var persistNode = get_node("/root/DontDestroyOnLoad")
	# self.dressed_animal_anchor.reparent(persistNode)
	# DontDestroyOnLoad.layout_animals(self.dressed_animal_anchor)
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")


## Create a new animal and position them
func set_animal_to_start() -> void:
	current_animal = object_creator.create_random_animal()
	var new_scale = randf_range(0.8, 1.2)
	current_animal.scale = Vector2(new_scale, new_scale)
	current_animal.position.x = -OFF_SCREEN_ANIMAL_DISTANCE_PX
	current_animal.global_position.y = belt_height.global_position.y
	grabber.position.y = grabber_start_position.y - OFF_SCREEN_GRABBER_DISTANCE_PX
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
	current_clothing = object_creator.create_random_clothing()
	current_clothing.global_position = new_clothing_anchor_node.global_position

	var pct_change := randf_range(1.25, 1.75)
	if randf() > 0.5:
		current_clothing.scale = Vector2(pct_change, pct_change)  # larger
	else:
		current_clothing.scale = Vector2(1.0 / pct_change, 1.0 / pct_change)  # smaller


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
			if current_animal.position.x > SCREEN_WIDTH_PX + OFF_SCREEN_ANIMAL_DISTANCE_PX:
				#disable current animal for now
				current_animal.hide()
				# TODO: Implement game over screen
				# current_animal.reparent(self.dressed_animal_anchor)
				dressed_animals.push_back(current_animal)
				set_animal_to_start()


## Move the grabber arm up or down if necessary.
func move_grabber_arm() -> void:
	match play_state:
		PlayState.MOVE_ANIMAL_IN:
			if grabber.position.y < grabber_start_position.y:
				if claw_down_sound.playing == false:
					claw_down_sound.play()
				grabber.position.y += GRABBER_SPEED
				current_clothing.global_position = new_clothing_anchor_node.global_position

		PlayState.MOVE_ANIMAL_OUT:
			if grabber.position.y > grabber_start_position.y - OFF_SCREEN_GRABBER_DISTANCE_PX:
				if claw_up_sound.playing == false:
					claw_up_sound.play()
				grabber.position.y -= GRABBER_SPEED


## Score the player's clothing sizing and move the animal to the right.
func score_fitting(sizing: SizeResult) -> void:
	var expected := sizing.expected_size
	var actual := sizing.actual_size

	# score = % away from perfect
	var score: float = abs(expected - actual) * 1.0 / expected

	var stars = 0
	if score < 0.075:
		stars = 5
	elif score < 0.15:
		stars = 3
	elif score < 0.25:
		stars = 1

	show_feedback(stars, expected, actual)
	incr_score(stars)


## Indicate to the player how many stars they earned.
func show_feedback(stars: int, expected: int, actual: int) -> void:
	var too_big_sm := ""
	if expected < actual:
		too_big_sm = " (too big)"
	elif expected > actual:
		too_big_sm = " (too small)"

	var feedback := one_of(
		["Aw, man...", "No good.", "This doesn't fit.", "Not quite right.", "Can you fix it?"]
	)
	var sfx := score_bad_sound
	match stars:
		5:
			feedback = one_of(
				[
					"So comfy!",
					"Amazing!",
					"Wow!",
					"I love it!",
					"So cute!",
					"Perfect fit!",
					"My new fave!"
				]
			)
			too_big_sm = ""
			sfx = score_great_sound
		3:
			feedback = one_of(
				["I like it.", "Nice!", "Thank you!", "Fits OK.", "Not bad.", "Looks good."]
			)
			too_big_sm = too_big_sm.replace("too", "a bit")
			sfx = score_good_sound
		1:
			feedback = one_of(
				[
					"Hmm...",
					"Not quite...",
					"Almost...",
					"It's OK, but...",
					"Well...",
					"Not my favorite.",
				]
			)
			sfx = score_ok_sound

	var star_s = one_of(["💔", "😭", "😖", "☹️", "😡", "🥴", "🤨"])
	if stars > 0:
		star_s = ""
		for i in range(stars):
			star_s += "⭐️"

	feedback_label.text = '"%s"%s' % [feedback, too_big_sm]
	feedback_stars_label.text = star_s
	feedback_label.visible = true
	sfx.play()


## Return a random string from the given options.
func one_of(array: Array[String]) -> String:
	return array[randi() % array.size()]


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
		if grow_sound.playing == false:
			grow_sound.play()
		if current_clothing.scale.x >= CLOTHING_MAX_SCALE:
			grow = false  # stop at max
		else:
			current_clothing.scale += Vector2(GROW_SHRINK_RATE, GROW_SHRINK_RATE)
			grow_tool.rotation_degrees = randf_range(-GROW_SHAKE_MAX_ROT, GROW_SHAKE_MAX_ROT)

	if shrink && !grow:
		if not resizing:
			shrink_sound_start.emit()
		resizing = true
		if current_clothing.scale.x <= CLOTHING_MIN_SCALE:
			shrink = false  # stop at min
			shrink_sound_stop.emit()
		else:
			current_clothing.scale -= Vector2(GROW_SHRINK_RATE, GROW_SHRINK_RATE)
			shrink_tool.rotation_degrees = randf_range(-GROW_SHAKE_MAX_ROT, GROW_SHAKE_MAX_ROT)

	if resizing && !grow && !shrink:  # player released the key
		grow_sound.stop()
		shrink_sound_stop.emit()
		if not clothing_sound.playing:
			clothing_sound.play()
		resizing = false
		grow_tool.rotation_degrees = 0
		shrink_tool.rotation_degrees = 0

		move_animal_at = Time.get_ticks_msec() + int(GETTING_DRESSED_DELAY_SEC * 1000)
		play_state = PlayState.GETTING_DRESSED
		var sizing = self.current_animal.attach_clothing(self.current_clothing)
		score_fitting(sizing)


## Wait for the animal to wear the clothing before moving them along.
func wait_to_wear_clothing() -> void:
	if play_state != PlayState.GETTING_DRESSED:
		return

	if Time.get_ticks_msec() > move_animal_at:
		play_state = PlayState.MOVE_ANIMAL_OUT
