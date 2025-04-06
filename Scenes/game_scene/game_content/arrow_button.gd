extends AnimatedSprite2D

enum AREA_HIT {OKAY_UPPER, GOOD_UPPER, PERFECT, GOOD_LOWER, OKAY_LOWER, MISS = 7}
var current_score: Global.ScoreEnum
var current_area: AREA_HIT = AREA_HIT.MISS

var current_note = null

@export var input = ""
@export var player_num: Global.PlayerEnum = Global.PlayerEnum.PLAYER_1
@onready var perfect_area: Area2D = $PerfectArea
@onready var good_area_upper: Area2D = $GoodAreaUpper
@onready var good_area_lower: Area2D = $GoodAreaLower
@onready var okay_area_upper: Area2D = $OkayAreaUpper
@onready var okay_area_lower: Area2D = $OkayAreaLower

func update_player(road_num):
	player_num = road_num
	input += str(road_num)
	if player_num == 1:
		okay_area_upper.collision_mask = 0b0010
		good_area_upper.collision_mask = 0b0010
		perfect_area.collision_mask = 0b0010
		good_area_lower.collision_mask = 0b0010
		okay_area_lower.collision_mask = 0b0010
	# game_object = game_reference
		

func _physics_process(delta):
	if Input.is_action_just_pressed(input):
		if current_note != null:
			# if (player_num == 1):
			# 	game_object.set_player1hit(areaHit)
			# else:
			# 	game_object.set_player2hit(areaHit)
			current_note.handle_input(current_score)
			if !current_note.held:
				_reset()
		# else:
			# game_object.increment_score(0)
		frame = 1

	if Input.is_action_just_released(input):
		if current_note != null:
			current_note.handle_input(current_score)
			_reset()
		$PushTimer.start()


func _on_okay_area_upper_entered(area):
	if area.is_in_group("note"):
		current_note = area
		current_score = Global.ScoreEnum.OKAY
		current_area = AREA_HIT.OKAY_UPPER


func _on_good_area_upper_entered(area):
	if current_note != null and area == current_note:
		current_score = Global.ScoreEnum.GOOD
		current_area = AREA_HIT.GOOD_UPPER


func _on_perfect_area_entered(area):
	if current_note != null and area == current_note:
		current_score = Global.ScoreEnum.PERFECT
		current_area = AREA_HIT.PERFECT
	# TODO: do below with signals
	# game_object.enemy_strike_pose()


func _on_perfect_area_exited(area):
	if current_note != null and area == current_note:
		current_score = Global.ScoreEnum.GOOD
		current_area = AREA_HIT.GOOD_LOWER


func _on_good_area_lower_exited(area):
	if current_note != null and area == current_note:
		current_score = Global.ScoreEnum.OKAY
		current_area = AREA_HIT.OKAY_LOWER


func _on_okay_area_lower_exited(area):
	if current_note != null and area == current_note:
		current_area = AREA_HIT.MISS
		current_note = null
		# TODO: do below with signals
		# if (player_num == 1):
		# 	game_object.set_player1hit(areaHit)
		# else:
		# 	game_object.set_player2hit(areaHit)


func _on_push_timer_timeout():
	frame = 0


func _reset():
	current_note = null
	current_area = AREA_HIT.MISS
