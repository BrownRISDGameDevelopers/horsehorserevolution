extends Area2D

const TARGET_Y = 164
const SPAWN_Y = -16
const DIST_TO_TARGET = TARGET_Y - SPAWN_Y

const LEFT_LANE_SPAWN_1 = Vector2(20, SPAWN_Y)
const DOWN_LANE_SPAWN_1 = Vector2(60, SPAWN_Y)
const UP_LANE_SPAWN_1 = Vector2(100, SPAWN_Y)
const RIGHT_LANE_SPAWN_1 = Vector2(140, SPAWN_Y)

const LEFT_LANE_SPAWN_2 = Vector2(180, SPAWN_Y)
const DOWN_LANE_SPAWN_2 = Vector2(220, SPAWN_Y)
const UP_LANE_SPAWN_2 = Vector2(260, SPAWN_Y)
const RIGHT_LANE_SPAWN_2 = Vector2(300, SPAWN_Y)

const SYNC_LANE_OFFSET = 80

var speed = 0
var hit = false
var held = false
var has_trail = false

var dance_bar1: TextureProgressBar
var dance_bar2: TextureProgressBar

@onready var head_sprite: AnimatedSprite2D = $HoldHeadSprite
@onready var head_collision: CollisionShape2D = $HoldHeadCollision
@onready var tail_sprite: AnimatedSprite2D = $HoldTailSprite
@onready var score_label: Label = $ScoreLabel/Label
@onready var trail: Line2D = $HoldTrail


func _physics_process(delta):
	if held:
		tail_sprite.position.y += speed * delta
		trail.set_point_position(1, tail_sprite.position)
	elif !hit:
		position.y += speed * delta
		if position.y > 200:
			dance_bar1.value -= 10
			dance_bar2.value += 10
			queue_free()
			get_parent().reset_combo()
	else:
		score_label.position.y -= speed * delta


func initialize(lane, duration, sec_per_beat):
	var offset = 0
	if get_parent().sync_phase:
		offset = SYNC_LANE_OFFSET
	if lane == 0:
		head_sprite.frame = 0
		tail_sprite.frame = 0
		position = LEFT_LANE_SPAWN_1 + Vector2(offset, 0)
	elif lane == 1:
		# TODO: replace with unique asset
		head_sprite.frame = 1
		head_sprite.rotation = PI
		tail_sprite.frame = 1
		tail_sprite.rotation = PI
		position = DOWN_LANE_SPAWN_1 + Vector2(offset, 0)
	elif lane == 2:
		head_sprite.frame = 1
		tail_sprite.frame = 1
		position = UP_LANE_SPAWN_1 + Vector2(offset, 0)
	elif lane == 3:
		head_sprite.frame = 2
		tail_sprite.frame = 2
		position = RIGHT_LANE_SPAWN_1 + Vector2(offset, 0)
	elif lane == 4:
		head_sprite.frame = 0
		tail_sprite.frame = 0
		position = LEFT_LANE_SPAWN_2 - Vector2(offset, 0)
	elif lane == 5:
		head_sprite.frame = 1
		head_sprite.rotation = PI
		tail_sprite.frame = 1
		tail_sprite.rotation = PI
		position = DOWN_LANE_SPAWN_2 - Vector2(offset, 0)
	elif lane == 6:
		head_sprite.frame = 1
		tail_sprite.frame = 1
		position = UP_LANE_SPAWN_2 - Vector2(offset, 0)
	elif lane == 7:
		head_sprite.frame = 2
		tail_sprite.frame = 2
		position = RIGHT_LANE_SPAWN_2 - Vector2(offset, 0)
	else:
		printerr("Invalid lane set for note: " + str(lane))
		return

	speed = DIST_TO_TARGET / 2.0

	if duration > 1:
		tail_sprite.position.y -= (duration - 1) * sec_per_beat * speed
		trail.add_point(Vector2.ZERO)
		trail.add_point(tail_sprite.position)
		has_trail = true
	else:
		head_collision.disabled = true

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
