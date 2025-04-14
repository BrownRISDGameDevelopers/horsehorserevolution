extends Area2D

const BASE_DISTANCE = 240
const DESPAWN_DISTANCE = 32

var speed = 0
var target_y = 0
var hit = false
var held = false
var has_trail = false
var horseshoe_head_adjust = Vector2(0, -8)
var default_shader = load("res://scenes/game_scene/game_content/note.gdshader")
var down_shader = load("res://scenes/game_scene/game_content/note_down.gdshader")

var player_num: Global.PlayerEnum = Global.PlayerEnum.PLAYER_1

var arrow_colors = {Global.Direction.LEFT: "6dd2f9",
					Global.Direction.DOWN: "ed6eb3",
					Global.Direction.UP: "f6db62",
					Global.Direction.RIGHT: "6fee48"}

@onready var head_sprite: Sprite2D = $HoldHeadSprite
@onready var head_collision: CollisionShape2D = $HoldHeadCollision
@onready var tail_sprite: Sprite2D = $HoldTailSprite
@onready var tail_collision: CollisionShape2D = $HoldTailCollision
@onready var score_label: Label = $ScoreLabel/Label
@onready var trail: Line2D = $HoldTrail


func _physics_process(delta):
	if held:
		tail_sprite.position.y += speed * delta
		trail.set_point_position(0, Vector2(0, target_y - position.y))
		var trail_end = min(tail_sprite.position.y, target_y - position.y)
		trail.set_point_position(1, Vector2(0, trail_end))
		if tail_sprite.position.y > DESPAWN_DISTANCE:
			Global.note_hit.emit(player_num, Global.AreaHit.MISS, Global.ScoreEnum.MISS)
			queue_free()
	elif not hit:
		position.y += speed * delta
		if position.y > target_y + DESPAWN_DISTANCE:
			Global.note_hit.emit(player_num, Global.AreaHit.MISS, Global.ScoreEnum.MISS)
			Global.dance_bar_change.emit(-10)
			queue_free()
	else:
		score_label.position.y -= speed * delta


func initialize(duration, bpm, road_num, end_y):
	player_num = road_num
	if road_num == 1:
		collision_layer = 0b0010
	target_y = end_y

	var DIST_TO_TARGET = BASE_DISTANCE * bpm / 120
	speed = DIST_TO_TARGET / 2.0

	head_collision.shape.set_size(Vector2(8, 8 * (bpm / 120)))
	tail_collision.shape.set_size(Vector2(8, 8 * (bpm / 120)))

	var sec_per_beat = 60.0 / bpm
	if duration > 1:
		tail_sprite.position.y -= (duration - 1) * sec_per_beat * speed
		tail_sprite.visible = false
		trail.add_point(horseshoe_head_adjust)
		trail.add_point(tail_sprite.position)
		has_trail = true
		# TODO: resize an area for hold notes to be released in
		# tail_collision.shape.set_size(Vector2(8, 8 * (bpm / 120)))
	else:
		head_collision.set_deferred("disabled", true)

func set_direction(direction):
	position = Vector2(-60 + direction * 40, target_y - speed * 2)
	if direction == Global.Direction.LEFT:
		head_sprite.rotation = - PI / 2
		tail_sprite.rotation = - PI / 2
	if direction == Global.Direction.DOWN:
		head_sprite.rotation = PI
		tail_sprite.rotation = PI
		trail.material.shader = down_shader
	if direction == Global.Direction.UP:
		pass
	if direction == Global.Direction.RIGHT:
		head_sprite.rotation = PI / 2
		tail_sprite.rotation = PI / 2
	head_sprite.modulate = arrow_colors[direction]
	tail_sprite.modulate = arrow_colors[direction]
	trail.default_color = arrow_colors[direction]

func handle_input(score: Global.ScoreEnum):
	# TODO: hold note logic	
	if !has_trail or held:
		destroy(score)
	else:
		hold(score)

func destroy(score: Global.ScoreEnum):
	# $CPUParticles2D.emitting = true
	$Timer.start()
	head_sprite.visible = false
	tail_sprite.visible = false
	held = false
	hit = true
	if score == Global.ScoreEnum.PERFECT:
		score_label.text = "GREAT"
		score_label.modulate = Color("f6d6bd")
	if score == Global.ScoreEnum.GOOD:
		score_label.text = "GOOD"
		score_label.modulate = Color("c3a38a")
	if score == Global.ScoreEnum.OKAY:
		score_label.text = "OKAY"
		score_label.modulate = Color("997577")


func hold(score: Global.ScoreEnum):
	trail.material.shader = default_shader
	head_sprite.visible = false
	head_collision.disabled = true
	held = true
	if score == Global.ScoreEnum.PERFECT:
		score_label.text = "GREAT"
		score_label.modulate = Color("f6d6bd")
	if score == Global.ScoreEnum.GOOD:
		score_label.text = "GOOD"
		score_label.modulate = Color("c3a38a")
	if score == Global.ScoreEnum.OKAY:
		score_label.text = "OKAY"
		score_label.modulate = Color("997577")


func _on_Timer_timeout():
	queue_free()
