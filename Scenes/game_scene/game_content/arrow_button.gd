extends Node2D

var current_score: Global.ScoreEnum
var current_area: Global.AreaHit = Global.AreaHit.MISS

var current_note = null

@export var input = ""
@export var player_num: Global.PlayerEnum = Global.PlayerEnum.PLAYER_1
@export var frames: SpriteFrames
@onready var perfect_area: Area2D = $PerfectArea
@onready var good_area_upper: Area2D = $GoodAreaUpper
@onready var good_area_lower: Area2D = $GoodAreaLower
@onready var okay_area_upper: Area2D = $OkayAreaUpper
@onready var okay_area_lower: Area2D = $OkayAreaLower

func _ready():
	$ArrowSprite.sprite_frames = frames

func update_player(road_num):
	player_num = road_num
	input += str(road_num)
	if player_num == Global.PlayerEnum.PLAYER_2:
		okay_area_upper.collision_mask = 0b0010
		good_area_upper.collision_mask = 0b0010
		perfect_area.collision_mask = 0b0010
		good_area_lower.collision_mask = 0b0010
		okay_area_lower.collision_mask = 0b0010
	# game_object = game_reference
		

func _physics_process(_delta):
	if Input.is_action_just_pressed(input):
		if current_note != null:
			Global.note_hit.emit(player_num, current_area, current_score)
			current_note.handle_input(current_score)
			if !current_note.held:
				_reset()
		else:
			Global.note_hit.emit(player_num, Global.AreaHit.MISS, Global.ScoreEnum.MISS)
		$ArrowSprite.frame = 1

	if Input.is_action_just_released(input):
		if current_note != null and current_note.held:
			current_note.handle_input(current_score)
			_reset()
		$PushTimer.start()


func _on_okay_area_upper_entered(area):
	if area.is_in_group("note"):
		current_note = area
		current_score = Global.ScoreEnum.OKAY
		current_area = Global.AreaHit.OKAY_UPPER


func _on_good_area_upper_entered(area):
	if current_note != null and area == current_note:
		current_score = Global.ScoreEnum.GOOD
		current_area = Global.AreaHit.GOOD_UPPER


func _on_perfect_area_entered(area):
	if current_note != null and area == current_note:
		current_score = Global.ScoreEnum.PERFECT
		current_area = Global.AreaHit.PERFECT


func _on_perfect_area_exited(area):
	if current_note != null and area == current_note:
		current_score = Global.ScoreEnum.GOOD
		current_area = Global.AreaHit.GOOD_LOWER


func _on_good_area_lower_exited(area):
	if current_note != null and area == current_note:
		current_score = Global.ScoreEnum.OKAY
		current_area = Global.AreaHit.OKAY_LOWER


func _on_okay_area_lower_exited(area):
	if current_note != null and area == current_note:
		current_area = Global.AreaHit.MISS
		current_note = null


func _on_push_timer_timeout():
	$ArrowSprite.frame = 0


func _reset():
	current_note = null
	current_area = Global.AreaHit.MISS
