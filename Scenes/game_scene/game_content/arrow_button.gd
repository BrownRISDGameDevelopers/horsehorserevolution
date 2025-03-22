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

func _ready():
	if player_num == 2:
		perfect_area.collision_mask = 0b0010
		good_area.collision_mask = 0b0010
		okay_area.collision_mask = 0b0010
		

func _unhandled_input(event):
	if event.is_action(input):
		if event.is_action_pressed(input, false):
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
		if event.is_action_pressed(input):
			frame = 1
		if event.is_action_released(input):
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
	if area.is_in_group("note"):
		perfect = true


func _on_PerfectArea_area_exited(area):
	if area.is_in_group("note"):
		perfect = false


func _on_GoodArea_area_entered(area):
	if area.is_in_group("note"):
		good = true


func _on_GoodArea_area_exited(area):
	if area.is_in_group("note"):
		good = false


func _on_OkayArea_area_entered(area):
	if area.is_in_group("note"):
		okay = true
		current_note = area


func _on_OkayArea_area_exited(area):
	if area.is_in_group("note"):
		okay = false
		current_note = null


func _on_PushTimer_timeout():
	frame = 0


func _reset():
	current_note = null
	perfect = false
	good = false
	okay = false
