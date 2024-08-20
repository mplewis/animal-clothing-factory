class_name Conveyor
extends Node2D

## Rate of tread motion
const ADVANCE_TREAD_FRAME_EVERY_N_FRAMES = 4
## Rate of gear rotation
const EVERY_FRAME_ROTATE_GEAR_DEGS = 5

@onready var treads_1: Sprite2D = $Treads1
@onready var treads_2: Sprite2D = $Treads2
@onready var treads_3: Sprite2D = $Treads3
@onready var treads_4: Sprite2D = $Treads4
@onready var gear_1: Sprite2D = $Gear1
@onready var gear_2: Sprite2D = $Gear2
@onready var gear_3: Sprite2D = $Gear3
@onready var gear_4: Sprite2D = $Gear4
@onready var gear_5: Sprite2D = $Gear5
@onready var gear_6: Sprite2D = $Gear6
@onready var gear_7: Sprite2D = $Gear7

@onready var tread_frames = [treads_4, treads_3, treads_2, treads_1]
@onready var gears = [gear_1, gear_2, gear_3, gear_4, gear_5, gear_6, gear_7]

var frame = 0
var current_tread_frame = 0
var playing = false


func _process(delta):
	if !playing:
		return

	for x in range(round(delta * 60)):
		frame += 1

		for gear in gears:
			gear.rotation_degrees += EVERY_FRAME_ROTATE_GEAR_DEGS

		if frame % ADVANCE_TREAD_FRAME_EVERY_N_FRAMES == 0:
			current_tread_frame = (current_tread_frame + 1) % tread_frames.size()
			for i in range(tread_frames.size()):
				tread_frames[i].visible = i == current_tread_frame
