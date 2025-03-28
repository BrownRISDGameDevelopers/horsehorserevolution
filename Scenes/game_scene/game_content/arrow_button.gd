extends AnimatedSprite2D

var perfect = false
var good = false
var okay = false
var current_note = null

@export var input = ""
@export var player_num: int = 0
@onready var perfect_area: Area2D = $PerfectArea
@onready var good_area: Area2D = $GoodArea
@onready var okay_area: Area2D = $OkayArea

func update_player(road_num):
	player_num = road_num
	input += str(road_num)
	if player_num == 1:
		perfect_area.collision_mask = 0b0010
		good_area.collision_mask = 0b0010
		okay_area.collision_mask = 0b0010
		

func _physics_process(delta):
	if Input.is_action_just_pressed(input):
		if current_note != null:
			if perfect:
				get_parent().get_parent().increment_score(3)
				current_note.handle_input(3)
			elif good:
				get_parent().get_parent().increment_score(2)
				current_note.handle_input(2)
			elif okay:
				get_parent().get_parent().increment_score(1)
				current_note.handle_input(1)
			if !current_note.held:
				_reset()
		else:
			get_parent().get_parent().increment_score(0)
		frame = 1

	if Input.is_action_just_released(input):
		if current_note != null:
			if perfect:
				get_parent().get_parent().increment_score(3)
				current_note.handle_input(3)
			elif good:
				get_parent().get_parent().increment_score(2)
				current_note.handle_input(2)
			elif okay:
				get_parent().get_parent().increment_score(1)
				current_note.handle_input(1)
			_reset()
		$PushTimer.start()


func _on_PerfectArea_area_entered(area):
	if current_note != null and area == current_note:
		perfect = true


func _on_PerfectArea_area_exited(area):
	if current_note != null and area == current_note:
		perfect = false


func _on_GoodArea_area_entered(area):
	if current_note != null and area == current_note:
		good = true


func _on_GoodArea_area_exited(area):
	if current_note != null and area == current_note:
		good = false


func _on_OkayArea_area_entered(area):
	if area.is_in_group("note"):
		okay = true
		current_note = area


func _on_OkayArea_area_exited(area):
	if current_note != null and area == current_note:
		okay = false
		current_note = null


func _on_PushTimer_timeout():
	frame = 0


func _reset():
	current_note = null
	perfect = false
	good = false
	okay = false
