extends AnimatedSprite2D

var perfect = false
var good = false
var okay = false
var current_note = null

var areaHit = 0 # -2 is miss, 1 2 3 4 5 are areas from top to bottom

@export var input = ""
@export var player_num: int = 0
@onready var perfect_area: Area2D = $PerfectArea
@onready var good_area: Area2D = $GoodArea
@onready var good_area_lower: Area2D = $GoodAreaLower
@onready var okay_area: Area2D = $OkayArea
@onready var okay_area_below: Area2D = $OkayAreaBelow

func update_player(road_num):
	player_num = road_num
	input += str(road_num)
	if player_num == 1:
		perfect_area.collision_mask = 0b0010
		good_area.collision_mask = 0b0010
		okay_area.collision_mask = 0b0010
		good_area_lower.collision_mask = 0b0010
		okay_area_below.collision_mask = 0b0010
		

func _physics_process(delta):
	if Input.is_action_just_pressed(input):
		if current_note != null:
			if (player_num == 1):
				get_parent().get_parent().set_player1hit(areaHit)
			else:
				get_parent().get_parent().set_player2hit(areaHit)
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
		areaHit = 3


func _on_PerfectArea_area_exited(area):
	if current_note != null and area == current_note:
		perfect = false
		areaHit = 4


func _on_GoodArea_area_entered(area):
	if current_note != null and area == current_note:
		good = true
		areaHit = 2


func _on_GoodArea_area_exited(area):
	if current_note != null and area == current_note:
		good = false


func _on_good_area_lower_area_exited(area: Area2D) -> void:
	if current_note != null and area == current_note:
		good = true
		areaHit = 5


func _on_good_area_lower_area_entered(area: Area2D) -> void:
	if current_note != null and area == current_note:
		good = false


func _on_OkayArea_area_entered(area):
	if area.is_in_group("note"):
		okay = true
		current_note = area
		areaHit = 1


func _on_OkayArea_area_exited(area):
	if current_note != null and area == current_note:
		okay = false


func _on_okay_area_below_area_entered(area: Area2D) -> void:
	if area.is_in_group("note"):
		okay = true
		current_note = area


func _on_okay_area_below_area_exited(area: Area2D) -> void:
	if current_note != null and area == current_note:
		okay = false
		areaHit = 0
		current_note = null


func _on_PushTimer_timeout():
	frame = 0


func _reset():
	current_note = null
	perfect = false
	good = false
	okay = false
