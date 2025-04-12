extends Area2D

const BASE_DISTANCE = 240
const DESPAWN_DISTANCE = 32

var speed = 0
var target_y
var hit = false
var held = false
var has_trail = false

var player_num: Global.PlayerEnum = Global.PlayerEnum.PLAYER_1

@onready var head_sprite: AnimatedSprite2D = $HoldHeadSprite
@onready var head_collision: CollisionShape2D = $HoldHeadCollision
@onready var tail_sprite: AnimatedSprite2D = $HoldTailSprite
@onready var tail_collision: CollisionShape2D = $HoldTailCollision
@onready var score_label: Label = $ScoreLabel/Label
@onready var trail: Line2D = $HoldTrail


func _physics_process(delta):
	if held:
		tail_sprite.position.y += speed * delta
		trail.set_point_position(1, tail_sprite.position)
		if tail_sprite.position.y > DESPAWN_DISTANCE:
			# TODO: miss logic
			queue_free()
	elif not hit:
		position.y += speed * delta
		if position.y > target_y + DESPAWN_DISTANCE:
			# TODO: use signals for below
			#if (player_num == 1):
				#get_parent().get_parent().get_parent().set_player1hit(-2)
			#else:
				#get_parent().get_parent().get_parent().set_player2hit(-2)
			#dance_bar1.value -= 10
			#dance_bar2.value += 10
			Global.dance_bar_change.emit(-10)
			# get_parent().get_parent().get_parent().reset_combo()
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
		tail_sprite.position.y -= (duration - 2) * sec_per_beat * speed
		trail.add_point(Vector2.ZERO)
		trail.add_point(tail_sprite.position)
		has_trail = true
	else:
		head_collision.set_deferred("disabled", true)

func set_direction(direction):
	position = Vector2(-60 + direction * 40, target_y - speed * 2)
	if direction == Global.Direction.LEFT:
		head_sprite.frame = 0
		tail_sprite.frame = 0
	elif direction == Global.Direction.DOWN:
		# TODO: replace with unique asset
		head_sprite.frame = 1
		head_sprite.rotation = PI
		tail_sprite.frame = 1
		tail_sprite.rotation = PI
	elif direction == Global.Direction.UP:
		head_sprite.frame = 1
		tail_sprite.frame = 1
	elif direction == Global.Direction.RIGHT:
		head_sprite.frame = 2
		tail_sprite.frame = 2
	else:
		printerr("Invalid direction set for note: " + str(direction))
		return


func handle_input(score: Global.ScoreEnum):
	if !has_trail or held:
		destroy(score)
	else:
		hold(score)

func destroy(score: Global.ScoreEnum):
	$CPUParticles2D.emitting = true
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
