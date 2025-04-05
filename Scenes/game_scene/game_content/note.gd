extends Area2D

const BASE_DISTANCE = 240
const SYNC_LANE_OFFSET = 80
const DESPAWN_DISTANCE = 32

var speed = 0
var target_y
var hit = false
var held = false
var has_trail = false

var playerNum = 0

var dance_bar1: TextureProgressBar
var dance_bar2: TextureProgressBar

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
			queue_free()
	elif !hit:
		position.y += speed * delta
		if position.y > target_y + DESPAWN_DISTANCE:
			if (playerNum == 1):
				get_parent().get_parent().set_player1hit(-2)
			else:
				get_parent().get_parent().set_player2hit(-2)
			dance_bar1.value -= 10
			dance_bar2.value += 10
			queue_free()
			get_parent().reset_combo()
	else:
		score_label.position.y -= speed * delta

func initialize(duration, bpm, road_num, db1, db2, end_y):
	playerNum = road_num
	if road_num == 1:
		collision_layer = 0b0010
	dance_bar1 = db1
	dance_bar2 = db2
	target_y = end_y

	var DIST_TO_TARGET = BASE_DISTANCE * bpm / 120
	speed = DIST_TO_TARGET / 2.0

	head_collision.shape.set_size(Vector2(8, 8 * (bpm / 120)))
	tail_collision.shape.set_size(Vector2(8, 8 * (bpm / 120)))

	var sec_per_beat = 60.0 / bpm
	if duration > 1:
		tail_sprite.position.y -= (duration - 1) * sec_per_beat * speed
		trail.add_point(Vector2.ZERO)
		trail.add_point(tail_sprite.position)
		has_trail = true
	else:
		head_collision.set_deferred("disabled", true)

func set_direction(direction):
	var offset = Vector2.ZERO
	if get_parent().sync_phase:
		offset.x = SYNC_LANE_OFFSET
	position = Vector2(-60 + direction * 40, target_y - speed * 2) + offset
	if direction == 0:
		head_sprite.frame = 0
		tail_sprite.frame = 0
	elif direction == 1:
		# TODO: replace with unique asset
		head_sprite.frame = 1
		head_sprite.rotation = PI
		tail_sprite.frame = 1
		tail_sprite.rotation = PI
	elif direction == 2:
		head_sprite.frame = 1
		tail_sprite.frame = 1
	elif direction == 3:
		head_sprite.frame = 2
		tail_sprite.frame = 2
	else:
		printerr("Invalid direction set for note: " + str(direction))
		return


func handle_input(score):
	if !has_trail or held:
		destroy(score)
	else:
		hold(score)

func destroy(score):
	$CPUParticles2D.emitting = true
	$Timer.start()
	head_sprite.visible = false
	tail_sprite.visible = false
	held = false
	hit = true
	if score == 3:
		score_label.text = "GREAT"
		score_label.modulate = Color("f6d6bd")
	elif score == 2:
		score_label.text = "GOOD"
		score_label.modulate = Color("c3a38a")
	elif score == 1:
		score_label.text = "OKAY"
		score_label.modulate = Color("997577")


func hold(score):
	head_sprite.visible = false
	head_collision.disabled = true
	held = true
	if score == 3:
		score_label.text = "GREAT"
		score_label.modulate = Color("f6d6bd")
	elif score == 2:
		score_label.text = "GOOD"
		score_label.modulate = Color("c3a38a")
	elif score == 1:
		score_label.text = "OKAY"
		score_label.modulate = Color("997577")


func _on_Timer_timeout():
	queue_free()
