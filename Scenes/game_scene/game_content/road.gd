extends Sprite2D

@export var road_num: int
var distanceFromCenter = 80
var bpm = 120
var sync_phase: bool = false

var note = load("res://scenes/game_scene/game_content/note.tscn")
var dance_bar1: TextureProgressBar
var dance_bar2: TextureProgressBar

@onready var tween = get_tree().create_tween()

@onready var left = $ArrowLeft
@onready var down = $ArrowDown
@onready var up = $ArrowUp
@onready var right = $ArrowRight

func _ready():
	if (road_num == 1):
		distanceFromCenter *= -1
	left.update_player(road_num)
	down.update_player(road_num)
	up.update_player(road_num)
	right.update_player(road_num)
	# enter_sync()
	# exit_sync()

func enter_sync():
	tween.tween_property(self, "position", Vector2(position.x + distanceFromCenter, position.y), 2)
	
func exit_sync():
	tween.tween_property(self, "position", Vector2(position.x, position.y), 2)

func initialize(new_bpm, db1, db2):
	bpm = new_bpm
	dance_bar1 = db1
	dance_bar2 = db2

func spawn_note(direction, duration):
	var instance = note.instantiate()
	add_child(instance)
	instance.initialize(duration, bpm, road_num, dance_bar1, dance_bar2, left.position.y)
	instance.set_direction(direction)

func reset_combo():
	get_parent().reset_combo()